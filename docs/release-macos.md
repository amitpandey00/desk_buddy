# Releasing on macOS

Must be done on a Mac. Distribution is outside the Mac App Store:
**Developer ID** signing + **notarization**, shipped as a `.dmg`.

> First time on a Mac? Do `docs/macos-verification.md` before releasing.
> The macOS runner code was written without a Mac.

## What you need (once)

- A Mac with Xcode (latest stable) and its command-line tools, and Flutter
  stable with the macOS desktop target (`flutter doctor`).
- An **Apple Developer Program** membership (paid).
- A **Developer ID Application** certificate in your login keychain
  (Xcode → Settings → Accounts → Manage Certificates → + → Developer ID
  Application).
- An app-specific password for notarization (appleid.apple.com → Sign-In
  and Security → App-Specific Passwords), stored once:

  ```sh
  xcrun notarytool store-credentials desk-buddy-notary \
    --apple-id you@example.com --team-id TEAMID1234 \
    --password abcd-efgh-ijkl-mnop
  ```

- `create-dmg` (`brew install create-dmg`).

## App settings already in the repo

| What | Where | Value |
|---|---|---|
| Bundle id | `macos/Runner/Configs/AppInfo.xcconfig` | `com.deskbuddy.deskBuddy` (change `PRODUCT_BUNDLE_IDENTIFIER` to your own before the first release, and never again) |
| Name | same file | `PRODUCT_NAME = desk_buddy` → change to `Desk Buddy` for a nice `.app` name |
| No Dock icon | `macos/Runner/Info.plist` | `LSUIElement = true` |
| Sandbox | `Release.entitlements` | on, plus user-selected file read/write (export/import) |
| Login item | `MainFlutterWindow.swift` | `SMAppService` (macOS 13+) |
| Minimum macOS | Xcode project | 10.15 (launch at login needs 13) |

Set your team once: open `macos/Runner.xcworkspace` in Xcode → Runner
target → Signing & Capabilities → Team = your team; Signing Certificate =
Developer ID Application; enable **Hardened Runtime**.

## 1. Build

```sh
flutter clean && flutter pub get
dart run build_runner build
flutter test
flutter build macos --release
APP="build/macos/Build/Products/Release/Desk Buddy.app"   # or desk_buddy.app
```

## 2. Sign (hardened runtime, deep)

Flutter's build signs with your Xcode settings. Verify, and re-sign if
needed:

```sh
codesign --force --deep --options runtime --timestamp \
  --entitlements macos/Runner/Release.entitlements \
  --sign "Developer ID Application: Your Name (TEAMID1234)" "$APP"
codesign --verify --deep --strict --verbose=2 "$APP"
spctl --assess --type execute --verbose "$APP"   # "rejected" until notarized
```

The `rive_native` and `sqlite3` libraries inside `Contents/Frameworks` must
be signed too (`--deep` covers them; `codesign --verify` will complain if
not).

## 3. Package

```sh
create-dmg --volname "Desk Buddy" --window-size 540 360 \
  --icon-size 120 --icon "Desk Buddy.app" 140 170 \
  --app-drop-link 400 170 \
  "build/DeskBuddy-<version>.dmg" "$APP"
codesign --sign "Developer ID Application: Your Name (TEAMID1234)" \
  --timestamp "build/DeskBuddy-<version>.dmg"
```

## 4. Notarize and staple

```sh
xcrun notarytool submit "build/DeskBuddy-<version>.dmg" \
  --keychain-profile desk-buddy-notary --wait
xcrun stapler staple "build/DeskBuddy-<version>.dmg"
spctl --assess --type open --context context:primary-signature -v \
  "build/DeskBuddy-<version>.dmg"            # "accepted, source=Notarized Developer ID"
```

If notarization fails: `xcrun notarytool log <submission-id>
--keychain-profile desk-buddy-notary` lists each problem (usually an
unsigned nested binary or a missing hardened runtime).

## 5. Smoke test (another Mac or a fresh user)

- [ ] Opening the DMG and dragging to Applications works; first launch shows no "unidentified developer" warning
- [ ] No Dock icon; menu-bar icon present; buddy walks above the Dock
- [ ] Opening the app again from Launchpad shows the dashboard
- [ ] Export / Import save and open files
- [ ] Launch at login (macOS 13+): appears in System Settings → General → Login Items
