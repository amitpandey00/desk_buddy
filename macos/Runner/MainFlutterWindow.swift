import Cocoa
import FlutterMacOS
import ServiceManagement
import desktop_multi_window

// UNVERIFIED: written on Windows without a Mac. Run through
// docs/macos-verification.md before relying on it.

/// The overlay: a borderless, transparent, always-on-top panel that never
/// steals focus (non-activating), shown on every Space and over full-screen
/// apps. The dashboard is a separate window created by desktop_multi_window.
class MainFlutterWindow: NSPanel {
  private var overlay: OverlayChannel?

  // AppKit only fully honours .nonactivatingPanel when it's set at creation,
  // so force the overlay style here rather than only in awakeFromNib.
  override init(
    contentRect: NSRect, styleMask style: NSWindow.StyleMask,
    backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool
  ) {
    super.init(
      contentRect: contentRect, styleMask: [.borderless, .nonactivatingPanel],
      backing: backingStoreType, defer: flag)
  }

  // Required alongside a custom designated init (NSResponder: NSCoding).
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    styleMask = [.borderless, .nonactivatingPanel]
    isOpaque = false
    backgroundColor = .clear
    hasShadow = false
    // isFloatingPanel resets the level to .floating, so set it first.
    isFloatingPanel = true
    level = .statusBar
    collectionBehavior = [
      .canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle,
    ]
    hidesOnDeactivate = false
    becomesKeyOnlyIfNeeded = true
    flutterViewController.backgroundColor = .clear

    RegisterGeneratedPlugins(registry: flutterViewController)

    // The dashboard window runs its own engine: give it the plugins too.
    FlutterMultiWindowPlugin.setOnWindowCreatedCallback { controller in
      RegisterGeneratedPlugins(registry: controller)
    }

    let messenger = flutterViewController.engine.binaryMessenger
    overlay = OverlayChannel(window: self, messenger: messenger)
    LaunchAtLoginChannel.register(messenger: messenger)

    // Opening the app again (Finder, Spotlight, Launchpad) shows the
    // dashboard, like a second launch on Windows. Handled via the Apple
    // event, which doesn't depend on FlutterAppDelegate's method set.
    NSAppleEventManager.shared().setEventHandler(
      self, andSelector: #selector(handleReopen(_:withReply:)),
      forEventClass: AEEventClass(kCoreEventClass),
      andEventID: AEEventID(kAEReopenApplication))

    super.awakeFromNib()
  }

  // Borderless panels can't become key by default; a pop-up needs to when
  // "Focus pop-ups" is on or VoiceOver is running (focusForAlert).
  override var canBecomeKey: Bool { true }

  @objc private func handleReopen(
    _ event: NSAppleEventDescriptor, withReply reply: NSAppleEventDescriptor
  ) {
    overlay?.requestActivate()
  }
}

/// Native side of `desk_buddy/overlay` (see windows/runner/overlay_channel.cpp
/// for the contract). Coordinates are Cocoa points flipped to a top-left
/// origin at the primary screen, so Dart sees the same shape of data as on
/// Windows; `scale` is 1 because Flutter's logical pixels are points here.
final class OverlayChannel {
  private let window: NSWindow
  private let channel: FlutterMethodChannel
  private var previousApp: NSRunningApplication?

  init(window: NSWindow, messenger: FlutterBinaryMessenger) {
    self.window = window
    channel = FlutterMethodChannel(
      name: "desk_buddy/overlay", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else { return result(nil) }
      self.handle(call, result)
    }
    NotificationCenter.default.addObserver(
      forName: NSApplication.didChangeScreenParametersNotification,
      object: nil, queue: .main
    ) { [weak self] _ in
      self?.channel.invokeMethod("displaysChanged", arguments: nil)
    }
    NSWorkspace.shared.notificationCenter.addObserver(
      forName: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification,
      object: nil, queue: .main
    ) { [weak self] _ in
      self?.channel.invokeMethod("accessibilityChanged", arguments: nil)
    }
  }

  func requestActivate() {
    channel.invokeMethod("activateRequested", arguments: nil)
  }

  private var primaryTop: CGFloat { NSScreen.screens.first?.frame.maxY ?? 0 }

  /// Cocoa rect (bottom-left origin) → [left, top, right, bottom].
  private func flip(_ r: NSRect) -> [Int] {
    [Int(r.minX), Int(primaryTop - r.maxY), Int(r.maxX), Int(primaryTop - r.minY)]
  }

  private func handle(_ call: FlutterMethodCall, _ result: FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]
    switch call.method {
    case "getDisplays":
      let primary = NSScreen.screens.first
      result(NSScreen.screens.map { s -> [String: Any] in
        let number = s.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")]
        return [
          "id": (number as? NSNumber)?.intValue ?? 0,
          "bounds": flip(s.frame),
          "work": flip(s.visibleFrame),  // excludes menu bar and Dock
          "scale": 1.0,
          "primary": s == primary,
        ]
      })
    case "getCursor":
      let p = NSEvent.mouseLocation
      let cursor: [Any] = [
        Int(p.x), Int(primaryTop - p.y), NSEvent.pressedMouseButtons & 1 == 1,
      ]
      result(cursor)
    case "getWindowRect":
      result(flip(window.frame))
    case "setFrame":
      let current = window.frame
      let w = (args["w"] as? NSNumber).map { CGFloat(truncating: $0) } ?? current.width
      let h = (args["h"] as? NSNumber).map { CGFloat(truncating: $0) } ?? current.height
      let x = (args["x"] as? NSNumber).map { CGFloat(truncating: $0) } ?? current.minX
      let top = (args["y"] as? NSNumber).map { CGFloat(truncating: $0) }
        ?? (primaryTop - current.maxY)
      window.setFrame(
        NSRect(x: x, y: primaryTop - top - h, width: w, height: h),
        display: true, animate: false)
      result(nil)
    case "raise":
      window.orderFrontRegardless()
      result(nil)
    case "setVisible":
      if args["visible"] as? Bool ?? true {
        window.orderFrontRegardless()
      } else {
        window.orderOut(nil)
      }
      result(nil)
    case "setClickThrough":
      window.ignoresMouseEvents = args["enabled"] as? Bool ?? false
      result(nil)
    case "cpuTimes":
      var usage = rusage()
      getrusage(RUSAGE_SELF, &usage)
      let micros =
        Int(usage.ru_utime.tv_sec) * 1_000_000 + Int(usage.ru_utime.tv_usec)
        + Int(usage.ru_stime.tv_sec) * 1_000_000 + Int(usage.ru_stime.tv_usec)
      result([micros, ProcessInfo.processInfo.activeProcessorCount])
    case "getAccessibility":
      result([
        "reduceMotion": NSWorkspace.shared.accessibilityDisplayShouldReduceMotion,
        "screenReader": NSWorkspace.shared.isVoiceOverEnabled,
      ])
    case "focusForAlert":
      let front = NSWorkspace.shared.frontmostApplication
      if front != NSRunningApplication.current { previousApp = front }
      NSApp.activate(ignoringOtherApps: true)
      window.makeKeyAndOrderFront(nil)
      result(window.isKeyWindow)
    case "releaseFocus":
      previousApp?.activate(options: [])  // the no-argument form is macOS 14+
      previousApp = nil
      result(nil)
    default:
      // setHitRegion (strategy C) has no macOS equivalent: use A or B.
      result(FlutterMethodNotImplemented)
    }
  }
}

/// The `launch_at_startup` plugin's macOS channel, implemented with
/// SMAppService (macOS 13+) instead of the LaunchAtLogin package, so no
/// Xcode steps are needed. Older macOS: reports off, can't enable.
enum LaunchAtLoginChannel {
  static func register(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "launch_at_startup", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      guard #available(macOS 13.0, *) else {
        result(call.method == "launchAtStartupIsEnabled" ? false : nil)
        return
      }
      switch call.method {
      case "launchAtStartupIsEnabled":
        result(SMAppService.mainApp.status == .enabled)
      case "launchAtStartupSetEnabled":
        let on = (call.arguments as? [String: Any])?["setEnabledValue"] as? Bool ?? false
        do {
          if on {
            try SMAppService.mainApp.register()
          } else {
            try SMAppService.mainApp.unregister()
          }
          result(nil)
        } catch {
          result(FlutterError(
            code: "login_item", message: error.localizedDescription, details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
