#include "overlay_channel.h"

#include <dwmapi.h>
#include <flutter/standard_method_codec.h>
#include <flutter_windows.h>

#include <optional>
#include <vector>

namespace {

using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;

int64_t AsInt(const EncodableValue& v) {
  if (auto* i = std::get_if<int32_t>(&v)) return *i;
  if (auto* l = std::get_if<int64_t>(&v)) return *l;
  if (auto* d = std::get_if<double>(&v)) return static_cast<int64_t>(*d);
  return 0;
}

const EncodableValue* Arg(const EncodableMap& m, const char* key) {
  auto it = m.find(EncodableValue(key));
  if (it == m.end() || it->second.IsNull()) return nullptr;
  return &it->second;
}

EncodableValue RectValue(const RECT& r) {
  return EncodableValue(EncodableList{
      EncodableValue(static_cast<int64_t>(r.left)),
      EncodableValue(static_cast<int64_t>(r.top)),
      EncodableValue(static_cast<int64_t>(r.right)),
      EncodableValue(static_cast<int64_t>(r.bottom))});
}

BOOL CALLBACK CollectMonitor(HMONITOR monitor, HDC, LPRECT, LPARAM data) {
  auto* out = reinterpret_cast<EncodableList*>(data);
  MONITORINFO info{sizeof(MONITORINFO)};
  if (!GetMonitorInfo(monitor, &info)) return TRUE;
  const double scale = FlutterDesktopGetDpiForMonitor(monitor) / 96.0;
  out->push_back(EncodableValue(EncodableMap{
      {EncodableValue("id"),
       EncodableValue(reinterpret_cast<int64_t>(monitor))},
      {EncodableValue("bounds"), RectValue(info.rcMonitor)},
      {EncodableValue("work"), RectValue(info.rcWork)},
      {EncodableValue("scale"), EncodableValue(scale)},
      {EncodableValue("primary"),
       EncodableValue((info.dwFlags & MONITORINFOF_PRIMARY) != 0)}}));
  return TRUE;
}

int64_t FileTimeMicros(const FILETIME& ft) {
  ULARGE_INTEGER u;
  u.LowPart = ft.dwLowDateTime;
  u.HighPart = ft.dwHighDateTime;
  return static_cast<int64_t>(u.QuadPart / 10);
}

}  // namespace

UINT OverlayChannel::ActivateMessage() {
  static const UINT message =
      RegisterWindowMessage(L"DeskBuddy.ActivateRequested");
  return message;
}

OverlayChannel::OverlayChannel(flutter::BinaryMessenger* messenger,
                               HWND window)
    : window_(window) {
  channel_ = std::make_unique<flutter::MethodChannel<EncodableValue>>(
      messenger, "desk_buddy/overlay",
      &flutter::StandardMethodCodec::GetInstance());
  channel_->SetMethodCallHandler([this](const auto& call, auto result) {
    HandleCall(call, std::move(result));
  });
}

void OverlayChannel::MakeTransparent() {
  // Extend the (invisible) frame over the whole client area so DWM
  // composites the Flutter surface with its per-pixel alpha.
  MARGINS margins = {-1, -1, -1, -1};
  DwmExtendFrameIntoClientArea(window_, &margins);

  // Same undocumented accent policy window_manager uses for a fully
  // transparent background on Windows 10/11.
  struct AccentPolicy {
    int state, flags, color, animation;
  };
  struct CompositionData {
    int attribute;
    PVOID data;
    ULONG size;
  };
  using SetCompositionFn = BOOL(WINAPI*)(HWND, CompositionData*);
  if (HMODULE user32 = GetModuleHandle(L"user32.dll")) {
    auto set_composition = reinterpret_cast<SetCompositionFn>(
        GetProcAddress(user32, "SetWindowCompositionAttribute"));
    if (set_composition) {
      AccentPolicy policy = {2 /* TRANSPARENTGRADIENT */, 2, 0, 0};
      CompositionData data = {19 /* WCA_ACCENT_POLICY */, &policy,
                              sizeof(policy)};
      set_composition(window_, &data);
    }
  }
}

std::optional<LRESULT> OverlayChannel::HandleMessage(UINT message,
                                                     WPARAM wparam,
                                                     LPARAM lparam) {
  if (message == ActivateMessage()) {
    channel_->InvokeMethod("activateRequested", nullptr);
    return 0;
  }
  switch (message) {
    case WM_MOUSEACTIVATE:
      // Clicking the buddy must not pull focus away from the user's app.
      return MA_NOACTIVATE;
    case WM_DISPLAYCHANGE:
    case WM_DPICHANGED:
      channel_->InvokeMethod("displaysChanged", nullptr);
      break;
    case WM_SETTINGCHANGE:
      if (wparam == SPI_SETWORKAREA) {
        channel_->InvokeMethod("displaysChanged", nullptr);
      } else if (wparam == SPI_SETCLIENTAREAANIMATION ||
                 wparam == SPI_SETSCREENREADER) {
        channel_->InvokeMethod("accessibilityChanged", nullptr);
      }
      break;
  }
  return std::nullopt;
}

void OverlayChannel::HandleCall(
    const flutter::MethodCall<EncodableValue>& call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  const std::string& name = call.method_name();
  static const EncodableMap kEmpty;
  const auto* args_ptr = std::get_if<EncodableMap>(call.arguments());
  const EncodableMap& args = args_ptr ? *args_ptr : kEmpty;

  if (name == "getDisplays") {
    EncodableList displays;
    EnumDisplayMonitors(nullptr, nullptr, CollectMonitor,
                        reinterpret_cast<LPARAM>(&displays));
    result->Success(EncodableValue(displays));
  } else if (name == "getCursor") {
    POINT p;
    GetCursorPos(&p);
    const int button =
        GetSystemMetrics(SM_SWAPBUTTON) ? VK_RBUTTON : VK_LBUTTON;
    const bool down = (GetAsyncKeyState(button) & 0x8000) != 0;
    result->Success(EncodableValue(EncodableList{
        EncodableValue(static_cast<int64_t>(p.x)),
        EncodableValue(static_cast<int64_t>(p.y)), EncodableValue(down)}));
  } else if (name == "getWindowRect") {
    RECT r;
    GetWindowRect(window_, &r);
    result->Success(RectValue(r));
  } else if (name == "setFrame") {
    const auto* x = Arg(args, "x");
    const auto* y = Arg(args, "y");
    const auto* w = Arg(args, "w");
    const auto* h = Arg(args, "h");
    UINT flags = SWP_NOACTIVATE | SWP_NOZORDER | SWP_NOOWNERZORDER;
    if (!x || !y) flags |= SWP_NOMOVE;
    if (!w || !h) flags |= SWP_NOSIZE;
    SetWindowPos(window_, nullptr, x ? static_cast<int>(AsInt(*x)) : 0,
                 y ? static_cast<int>(AsInt(*y)) : 0,
                 w ? static_cast<int>(AsInt(*w)) : 0,
                 h ? static_cast<int>(AsInt(*h)) : 0, flags);
    result->Success();
  } else if (name == "setVisible") {
    const auto* visible = Arg(args, "visible");
    ShowWindow(window_, visible && std::get<bool>(*visible) ? SW_SHOWNOACTIVATE
                                                           : SW_HIDE);
    result->Success();
  } else if (name == "getAccessibility") {
    // "Animation effects" off in Settings → Accessibility = reduce motion.
    BOOL animations = TRUE;
    SystemParametersInfo(SPI_GETCLIENTAREAANIMATION, 0, &animations, 0);
    BOOL screen_reader = FALSE;
    SystemParametersInfo(SPI_GETSCREENREADER, 0, &screen_reader, 0);
    result->Success(EncodableValue(EncodableMap{
        {EncodableValue("reduceMotion"), EncodableValue(!animations)},
        {EncodableValue("screenReader"), EncodableValue(screen_reader != 0)},
    }));
  } else if (name == "focusForAlert") {
    // Let the overlay take keyboard focus for a pop-up, remembering who had
    // it. Windows only grants foreground to the active process, so a
    // synthetic Alt tap is the documented way to be allowed to take it.
    HWND current = GetForegroundWindow();
    if (current != window_) previous_foreground_ = current;
    SetWindowLong(window_, GWL_EXSTYLE,
                  GetWindowLong(window_, GWL_EXSTYLE) & ~WS_EX_NOACTIVATE);
    // Alt held while taking the foreground, then released: the user's app
    // never sees a complete Alt tap (which would open its menu bar).
    INPUT alt = {};
    alt.type = INPUT_KEYBOARD;
    alt.ki.wVk = VK_MENU;
    SendInput(1, &alt, sizeof(INPUT));
    SetForegroundWindow(window_);
    alt.ki.dwFlags = KEYEVENTF_KEYUP;
    SendInput(1, &alt, sizeof(INPUT));
    result->Success(EncodableValue(GetForegroundWindow() == window_));
  } else if (name == "releaseFocus") {
    SetWindowLong(window_, GWL_EXSTYLE,
                  GetWindowLong(window_, GWL_EXSTYLE) | WS_EX_NOACTIVATE);
    if (GetForegroundWindow() == window_ && previous_foreground_ &&
        IsWindow(previous_foreground_)) {
      SetForegroundWindow(previous_foreground_);
    }
    previous_foreground_ = nullptr;
    result->Success();
  } else if (name == "raise") {
    SetWindowPos(window_, HWND_TOPMOST, 0, 0, 0, 0,
                 SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
    result->Success();
  } else if (name == "setClickThrough") {
    const auto* enabled = Arg(args, "enabled");
    const bool on = enabled && std::get<bool>(*enabled);
    if (on != click_through_) {
      click_through_ = on;
      LONG ex = GetWindowLong(window_, GWL_EXSTYLE);
      if (on) {
        // WS_EX_TRANSPARENT only passes clicks through across processes on
        // a layered window; full alpha keeps it looking unchanged.
        SetWindowLong(window_, GWL_EXSTYLE,
                      ex | WS_EX_LAYERED | WS_EX_TRANSPARENT);
        SetLayeredWindowAttributes(window_, 0, 255, LWA_ALPHA);
      } else {
        SetWindowLong(window_, GWL_EXSTYLE,
                      ex & ~(WS_EX_LAYERED | WS_EX_TRANSPARENT));
      }
    }
    result->Success();
  } else if (name == "setHitRegion") {
    // Client-relative physical rects; null clears the region.
    const auto* rects = Arg(args, "rects");
    if (!rects) {
      SetWindowRgn(window_, nullptr, TRUE);
    } else {
      HRGN region = CreateRectRgn(0, 0, 0, 0);
      for (const auto& item : std::get<EncodableList>(*rects)) {
        const auto& r = std::get<EncodableList>(item);
        HRGN part =
            CreateRectRgn(static_cast<int>(AsInt(r[0])),
                          static_cast<int>(AsInt(r[1])),
                          static_cast<int>(AsInt(r[2])),
                          static_cast<int>(AsInt(r[3])));
        CombineRgn(region, region, part, RGN_OR);
        DeleteObject(part);
      }
      // The system owns the region after this call.
      SetWindowRgn(window_, region, TRUE);
    }
    result->Success();
  } else if (name == "cpuTimes") {
    FILETIME created, exited, kernel, user;
    GetProcessTimes(GetCurrentProcess(), &created, &exited, &kernel, &user);
    SYSTEM_INFO info;
    GetSystemInfo(&info);
    result->Success(EncodableValue(EncodableList{
        EncodableValue(FileTimeMicros(kernel) + FileTimeMicros(user)),
        EncodableValue(static_cast<int64_t>(info.dwNumberOfProcessors))}));
  } else {
    result->NotImplemented();
  }
}
