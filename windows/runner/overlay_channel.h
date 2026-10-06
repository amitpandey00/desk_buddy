#ifndef RUNNER_OVERLAY_CHANNEL_H_
#define RUNNER_OVERLAY_CHANNEL_H_

#include <flutter/binary_messenger.h>
#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>
#include <windows.h>

#include <memory>
#include <optional>

// Native side of the `desk_buddy/overlay` channel.
//
// Everything here works in *physical* pixels (virtual-screen coordinates), so
// mixed-DPI multi-monitor setups stay consistent. The plugins we evaluated
// (window_manager, screen_retriever) convert per call with a single scale
// factor, and window_manager's setPosition activates the window, which would
// steal focus from the user's app on every walking step.
class OverlayChannel {
 public:
  OverlayChannel(flutter::BinaryMessenger* messenger, HWND window);

  // Named mutex guarding a single running instance (also the installer's
  // AppMutex).
  static constexpr const wchar_t* kInstanceMutexName =
      L"Local\\DeskBuddy.SingleInstance";

  // Broadcast by a second launch: "open your dashboard".
  static UINT ActivateMessage();

  // Applies per-pixel transparency to the top-level window.
  void MakeTransparent();

  // Called from the top-level window proc; forwards display/work-area
  // changes to Dart. Returns a result when the message was fully handled.
  std::optional<LRESULT> HandleMessage(UINT message, WPARAM wparam,
                                       LPARAM lparam);

 private:
  void HandleCall(
      const flutter::MethodCall<flutter::EncodableValue>& call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  HWND window_;
  bool click_through_ = false;

  // The app that had focus before a pop-up took it (focusForAlert).
  HWND previous_foreground_ = nullptr;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_;
};

#endif  // RUNNER_OVERLAY_CHANNEL_H_
