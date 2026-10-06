# Releasing on Windows

Two ways to ship, from the same release build:

| | Inno Setup installer (**recommended**) | MSIX |
|---|---|---|
| Output | `DeskBuddy-Setup-<version>.exe` | `desk_buddy.msix` |
| Install | Per-user, no admin prompt | Per-user (App Installer) |
| Launch at login | Registry Run key (what the app writes) | Startup-folder shortcut (launch_at_startup's MSIX mode); test it before shipping |
| Upgrades | Same `AppId`; closes the running app first (`AppMutex`) | Higher `msix_version` |
| Signing | Optional but strongly advised (SmartScreen) | **Required** (an untrusted MSIX won't install) |

## Prerequisites (once)

- Flutter (stable) with the Visual Studio **Desktop development with C++**
  workload (`flutter doctor` must be green for Windows).
- For the installer: [Inno Setup 6](https://jrsoftware.org/isinfo.php)
  (`iscc` on PATH).
- For signing: a code-signing certificate (`.pfx`) and `signtool` from the
  Windows SDK. An OV/EV certificate builds SmartScreen reputation; for
  internal testing a self-signed one works (see the end of this file).

## 1. Version

Bump `version:` in `pubspec.yaml` (`1.2.0+5` → file/product version
1.2.0.5). Both packages read it.

## 2. Build

```powershell
flutter clean
flutter pub get
dart run build_runner build
flutter test
flutter build windows --release
```

Output: `build\windows\x64\runner\Release\` (exe, DLLs, `data\`).

## 3a. Installer (recommended)

```powershell
# Sign the app first, so the installed exe is signed too.
signtool sign /fd SHA256 /tr http://timestamp.digicert.com /td SHA256 `
  /f path\to\cert.pfx /p $env:CERT_PASSWORD `
  build\windows\x64\runner\Release\desk_buddy.exe

iscc installer\windows\desk_buddy.iss

signtool sign /fd SHA256 /tr http://timestamp.digicert.com /td SHA256 `
  /f path\to\cert.pfx /p $env:CERT_PASSWORD `
  build\installer\DeskBuddy-Setup-*.exe
```

What the installer does (see `installer/windows/desk_buddy.iss`):
- installs per user to `%LOCALAPPDATA%\Programs\Desk Buddy` (or Program
  Files when elevated), with a Start-menu entry and an optional desktop icon
- closes a running Desk Buddy before upgrading (same mutex as the app's
  single-instance guard) and offers to launch it when done
- on uninstall, removes the launch-at-login entry, and only deletes
  reminders and history (`%APPDATA%\Desk Buddy\Desk Buddy`) if the user
  says yes

## 3b. MSIX

`msix_config` in `pubspec.yaml` holds the identity. `publisher` must equal
your certificate's Subject exactly (e.g. `CN=Your Company, O=…, C=…`), and
`identity_name` must equal `msixIdentityName` in
`lib/core/platform/launch_at_login.dart`.

```powershell
dart run msix:create --certificate-path path\to\cert.pfx `
  --certificate-password $env:CERT_PASSWORD
```

Output: `build\windows\x64\runner\Release\desk_buddy.msix`.

## 4. Smoke test on a clean machine (or a fresh Windows user)

- [ ] Installs without an admin prompt; Start menu entry has the buddy icon
- [ ] First launch: the buddy appears above the taskbar; the tray icon is there; no taskbar button for the overlay
- [ ] Launching again from the Start menu opens the dashboard (no second buddy)
- [ ] Settings → Launch at login on → sign out and in → it starts
- [ ] Upgrade with a newer installer while running: it closes, upgrades, keeps reminders
- [ ] Uninstall: launch-at-login entry gone; data kept unless chosen

## Self-signed certificate (testing only)

```powershell
$cert = New-SelfSignedCertificate -Type CodeSigningCert `
  -Subject "CN=Desk Buddy" -CertStoreLocation Cert:\CurrentUser\My
$pwd = ConvertTo-SecureString -String "change-me" -Force -AsPlainText
Export-PfxCertificate -Cert $cert -FilePath desk-buddy-test.pfx -Password $pwd
```

To install a self-signed MSIX, testers must first trust the certificate
(Local Machine → Trusted People). Never commit the `.pfx`.
