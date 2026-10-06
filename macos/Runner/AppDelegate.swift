import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  // A menu-bar app: closing the dashboard must not quit (Quit is in the
  // menu-bar menu). Reopening the app is handled in MainFlutterWindow.
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
