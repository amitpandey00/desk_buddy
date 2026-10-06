import 'dart:async';
import 'dart:io';

import 'package:desk_buddy/features/settings/data/settings_repository.dart';
import 'package:desk_buddy/features/settings/domain/app_settings.dart';
import 'package:desk_buddy/shared/strings.dart';
import 'package:launch_at_startup/launch_at_startup.dart';

/// Must match `msix_config.identity_name` in pubspec.yaml: under MSIX the
/// install path contains it, which is how `launch_at_startup` tells.
const msixIdentityName = 'com.deskbuddy.deskbuddy';

/// The OS "start at login" switch.
abstract interface class LoginItem {
  Future<bool> isEnabled();
  Future<void> setEnabled({required bool enabled});
}

/// `launch_at_startup`: the Run registry key on Windows (a StartupTask once
/// packaged as MSIX — Phase 7 passes the package name), a login item on
/// macOS.
class PluginLoginItem implements LoginItem {
  PluginLoginItem({String? msixPackageName}) {
    launchAtStartup.setup(
      appName: Strings.appName,
      appPath: Platform.resolvedExecutable,
      packageName: msixPackageName,
    );
  }

  @override
  Future<bool> isEnabled() => launchAtStartup.isEnabled();

  @override
  Future<void> setEnabled({required bool enabled}) async {
    if (enabled) {
      await launchAtStartup.enable();
    } else {
      await launchAtStartup.disable();
    }
  }
}

/// Keeps the `launchAtLogin` setting and the OS in agreement. On start the
/// OS wins (the user may have turned it off in Windows' Startup apps); after
/// that, the setting drives the OS. Runs in the overlay only.
class LaunchAtLoginSync {
  LaunchAtLoginSync(this._settings, this._item);

  final SettingsRepository _settings;
  final LoginItem _item;
  StreamSubscription<AppSettings>? _sub;
  bool? _applied;

  Future<void> start() async {
    final os = await _item.isEnabled();
    _applied = os;
    if ((await _settings.get()).launchAtLogin != os) {
      await _settings.update((s) => s.copyWith(launchAtLogin: os));
    }
    _sub = _settings.watch().listen((s) {
      // One change at a time, in order: a slow or failing earlier change
      // must not overwrite a newer choice.
      _queue = _queue.then((_) => _apply(s.launchAtLogin));
    });
  }

  Future<void> _queue = Future.value();

  Future<void> _apply(bool wanted) async {
    if (wanted == _applied) return;
    _applied = wanted;
    try {
      await _item.setEnabled(enabled: wanted);
    } on Object {
      // Blocked by policy etc.: reflect reality back into the setting.
      try {
        final actual = await _item.isEnabled();
        _applied = actual;
        await _settings.update((x) => x.copyWith(launchAtLogin: actual));
      } on Object {
        _applied = null; // unknown; retry on the next change
      }
    }
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    await _queue;
  }
}
