# macOS verification pass

All macOS native code was written on Windows and has **never been compiled**:
`macos/Runner/MainFlutterWindow.swift`, `AppDelegate.swift`, `Info.plist`,
entitlements. Run this once on a Mac and report what fails.

```sh
flutter pub get && dart run build_runner build
flutter run -d macos --dart-define=SPIKE=A --dart-define=DEMO_FIRE_IN=20
```

## Build

- [ ] Compiles. If `FlutterMultiWindowPlugin` / `import desktop_multi_window` fails, check the plugin's Swift module name in the generated package.
- [ ] If a plugin needs a newer macOS (build error naming a deployment target), raise `MACOSX_DEPLOYMENT_TARGET` in the Xcode project (all three configurations) and note it in `docs/decisions.md`.

## Overlay window (Phase 1 / D2 equivalents)

- [ ] Background fully transparent; no title bar, no shadow box
- [ ] No Dock icon (LSUIElement); a menu-bar icon instead
- [ ] Buddy walks along the bottom **above the Dock**, on the screen with the menu bar
- [ ] Typing in another app while the buddy walks: focus is never taken. **Risk:** `.nonactivatingPanel` is set in `awakeFromNib`, not at creation. If clicking the buddy activates the app (the menu bar switches to "desk_buddy"), set the window's class to NSPanel with "Non Activating" in `MainMenu.xib`.
- [ ] Clicking the buddy shows the peek; dragging moves it, including to a second display
- [ ] Shows over a full-screen app and on every Space (switch Spaces with Ctrl-→)
- [ ] Strategy B (`--dart-define=SPIKE=B`): clicks pass through to windows behind except on the buddy and bubble (`ignoresMouseEvents`). Strategy C isn't supported on macOS (no window regions).
- [ ] Benchmark A vs B: `--dart-define=BENCH=30 --dart-define=OUT=/tmp/a.json` in release mode; compare CPU (spec target < 2% on an M1)

## Coordinates

- [ ] `getDisplays`: with the Dock on the left or right, the buddy stays inside the visible frame
- [ ] Two displays at different heights: dragging between them keeps the buddy under the cursor (top-left flip uses the primary screen's height)

## Reminders and the dashboard

- [ ] A pop-up appears ~20 s after launch with the chime; Done / Remind me work
- [ ] Menu-bar menu: Open Dashboard opens a normal window; DND / Show-Hide work and their checks update
- [ ] Opening the app again from Finder/Spotlight shows the dashboard (`applicationShouldHandleReopen`)
- [ ] Closing the dashboard doesn't quit; Quit does
- [ ] Settings changes in the dashboard reach the buddy (size, look, walking)

## Accessibility (D24, D26)

- [ ] System Settings → Accessibility → Display → Reduce motion: limbs stop, buddy still walks (live, no restart)
- [ ] Settings → Focus pop-ups on: a pop-up becomes key; Return answers it; focus returns to the previous app
- [ ] VoiceOver on: pop-ups are announced and take focus without the setting

## Platform services

- [ ] Launch at login (macOS 13+): appears in Login Items; turning it off there is reflected after the next start
- [ ] Export / Import panels open (sandbox entitlement)
- [ ] Hidden buddy: a notification shows instead, with buttons where the notification style allows
