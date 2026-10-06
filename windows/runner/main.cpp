#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "overlay_channel.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // One buddy per user session. A second launch (Start menu while already
  // running at login, a double-click…) asks the running copy to open its
  // dashboard instead. The installer uses the same mutex name (AppMutex)
  // to close the app before upgrading.
  HANDLE instance_mutex =
      ::CreateMutex(nullptr, TRUE, OverlayChannel::kInstanceMutexName);
  if (instance_mutex && ::GetLastError() == ERROR_ALREADY_EXISTS) {
    ::PostMessage(HWND_BROADCAST, OverlayChannel::ActivateMessage(), 0, 0);
    ::CloseHandle(instance_mutex);
    return EXIT_SUCCESS;
  }

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(140, 250);
  if (!window.Create(L"Desk Buddy", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  if (instance_mutex) ::CloseHandle(instance_mutex);
  return EXIT_SUCCESS;
}
