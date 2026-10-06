import 'dart:async';
import 'dart:io';

import 'package:desk_buddy/core/db/app_data.dart';
import 'package:desk_buddy/features/settings/domain/app_settings.dart';
import 'package:desk_buddy/shared/strings.dart';
import 'package:tray_manager/tray_manager.dart';

/// The tray / menu-bar icon and its menu (spec §6). Lives in the overlay.
class TrayController with TrayListener {
  TrayController(
    this._data, {
    required this.openDashboard,
    required this.snoozeAll,
    required this.quit,
  });

  static const snoozeAllMinutes = 30;

  final AppData _data;
  final Future<void> Function() openDashboard;
  final Future<void> Function(int minutes) snoozeAll;
  final Future<void> Function() quit;
  StreamSubscription<AppSettings>? _sub;
  AppSettings _settings = const AppSettings();

  Future<void> start() async {
    await trayManager.setIcon(
      Platform.isWindows
          ? 'assets/tray/tray.ico'
          : 'assets/tray/tray_template.png',
      isTemplate: Platform.isMacOS,
    );
    if (!Platform.isLinux) await trayManager.setToolTip(Strings.trayTooltip);
    trayManager.addListener(this);
    _settings = await _data.settings.get();
    await _rebuildMenu();
    // The menu's labels and check marks follow the settings, whoever
    // changes them (tray, dashboard).
    _sub = _data.settings.watch().listen((s) {
      final changed =
          s.buddyVisible != _settings.buddyVisible ||
          s.buddyAlwaysOn != _settings.buddyAlwaysOn ||
          s.doNotDisturb != _settings.doNotDisturb;
      _settings = s;
      if (changed) unawaited(_rebuildMenu());
    });
  }

  Future<void> _rebuildMenu() => trayManager.setContextMenu(
    Menu(
      items: [
        MenuItem(key: 'open', label: Strings.trayOpenDashboard),
        MenuItem.separator(),
        MenuItem(
          key: 'visible',
          label: _settings.buddyVisible
              ? Strings.trayHideBuddy
              : Strings.trayShowBuddy,
        ),
        MenuItem.checkbox(
          key: 'always',
          label: Strings.trayAlwaysOn,
          checked: _settings.buddyAlwaysOn,
        ),
        MenuItem.checkbox(
          key: 'dnd',
          label: Strings.trayDnd,
          checked: _settings.doNotDisturb,
        ),
        MenuItem(
          key: 'snooze',
          label: Strings.traySnoozeAll(snoozeAllMinutes),
        ),
        MenuItem.separator(),
        MenuItem(key: 'quit', label: Strings.trayQuit),
      ],
    ),
  );

  // Windows: left click opens the dashboard, right click shows the menu.
  // macOS: any click shows the menu, as menu-bar items do.
  @override
  void onTrayIconMouseDown() {
    if (Platform.isMacOS) {
      unawaited(trayManager.popUpContextMenu());
    } else {
      unawaited(openDashboard());
    }
  }

  @override
  void onTrayIconRightMouseDown() => unawaited(
    trayManager.popUpContextMenu(
      // Win32 menus only close on an outside click if the owner window is
      // in front; a tray click is allowed to take the foreground. (Marked
      // deprecated in tray_manager 0.5, but still the only way on Windows.)
      // ignore: deprecated_member_use
      bringAppToFront: Platform.isWindows,
    ),
  );

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    unawaited(switch (menuItem.key) {
      'open' => openDashboard(),
      'visible' => _data.settings.update(
        (s) => s.copyWith(buddyVisible: !s.buddyVisible),
      ),
      'always' => _data.settings.update(
        (s) => s.copyWith(buddyAlwaysOn: !s.buddyAlwaysOn),
      ),
      'dnd' => _data.settings.update(
        (s) => s.copyWith(doNotDisturb: !s.doNotDisturb),
      ),
      'snooze' => snoozeAll(snoozeAllMinutes),
      'quit' => quit(),
      _ => Future<void>.value(),
    });
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    trayManager.removeListener(this);
    await trayManager.destroy();
  }
}
