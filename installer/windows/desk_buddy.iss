; Desk Buddy — Windows installer (Inno Setup 6).
; Build the app first:   flutter build windows --release
; Then compile this:     iscc installer\windows\desk_buddy.iss
; Output:                build\installer\DeskBuddy-Setup-<version>.exe
; See docs/release-windows.md (signing with signtool).

#define AppName "Desk Buddy"
#define AppVersion GetVersionNumbersString("..\..\build\windows\x64\runner\Release\desk_buddy.exe")
#define AppExe "desk_buddy.exe"

[Setup]
; Never change AppId: it's how upgrades find the existing install.
AppId={{6B7F3D52-9C1A-4E7B-9D0F-2A4C5E8B1D63}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppName}
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
; Per-user install by default (no admin prompt); the app writes only to the
; user's AppData and HKCU.
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
OutputDir=..\..\build\installer
OutputBaseFilename=DeskBuddy-Setup-{#AppVersion}
SetupIconFile=..\..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#AppExe}
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
; Same name as the app's single-instance mutex (windows/runner/
; overlay_channel.h): the installer asks the running app to close first.
AppMutex=Local\DeskBuddy.SingleInstance
CloseApplications=yes
RestartApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppExe}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExe}"; Tasks: desktopicon

[Registry]
; "Launch at login" is written by the app itself (launch_at_startup); make
; sure uninstalling doesn't leave it behind.
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: none; ValueName: "{#AppName}"; Flags: uninsdeletevalue dontcreatekey
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run"; ValueType: none; ValueName: "{#AppName}"; Flags: uninsdeletevalue dontcreatekey

[Run]
Filename: "{app}\{#AppExe}"; Description: "{cm:LaunchProgram,{#AppName}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
; Reminders, history and settings live in %APPDATA%\Desk Buddy\Desk Buddy
; (path_provider builds it from CompanyName\ProductName in Runner.rc). Kept
; on uninstall unless the user opts in below.

[Code]
var
  RemoveData: Boolean;

function InitializeUninstall(): Boolean;
begin
  RemoveData := (not UninstallSilent()) and
    (MsgBox('Also delete your reminders, history and settings?',
      mbConfirmation, MB_YESNO or MB_DEFBUTTON2) = IDYES);
  Result := True;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if (CurUninstallStep = usPostUninstall) and RemoveData then
    DelTree(ExpandConstant('{userappdata}\Desk Buddy\Desk Buddy'), True, True, True);
end;
