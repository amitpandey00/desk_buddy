import 'dart:async';
import 'dart:io';

import 'package:desk_buddy/app/dashboard_app.dart';
import 'package:desk_buddy/app/providers.dart';
import 'package:desk_buddy/core/db/app_data.dart';
import 'package:desk_buddy/core/db/providers.dart';
import 'package:desk_buddy/core/db/seed/seed_data.dart';
import 'package:desk_buddy/core/platform/audioplayers_chime.dart';
import 'package:desk_buddy/core/platform/launch_at_login.dart';
import 'package:desk_buddy/core/platform/local_notifier_alerts.dart';
import 'package:desk_buddy/core/tray/tray_controller.dart';
import 'package:desk_buddy/core/window/multi_window.dart';
import 'package:desk_buddy/core/window/window_bus.dart';
import 'package:desk_buddy/core/window/window_role.dart';
import 'package:desk_buddy/features/scheduler/application/scheduler_service.dart';
import 'package:desk_buddy/shared/strings.dart';
import 'package:desk_buddy/spike/spike_app.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

/// Debug aid: `--dart-define=DEMO_FIRE_IN=20` makes the first enabled
/// reminder due 20 s after launch, to see a real pop-up without waiting.
int _demoFireIn() => const int.fromEnvironment('DEMO_FIRE_IN');
const bool _benchmark = int.fromEnvironment('BENCH') > 0;

/// Every window runs this; `desktop_multi_window` says which one we are.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final window = await WindowController.fromCurrentEngine();
  final seed = await SeedData.load(rootBundle.loadString);
  final data = await openAppData(seed: seed);
  switch (WindowRole.parse(window.arguments)) {
    case WindowRole.overlay:
      await _runOverlay(data);
    case WindowRole.dashboard:
      await _runDashboard(data, seed);
  }
}

// ---------------------------------------------------------------- overlay

/// The always-on-top buddy: scheduler, tray, and the bus to the dashboard.
/// (Still hosted by the Phase 1 spike shell: `--dart-define=SPIKE=A|B|C`.)
Future<void> _runOverlay(AppData data) async {
  if (kDebugMode && _demoFireIn() > 0) await _makeFirstReminderDueSoon(data);

  await LocalNotifierAlerts.setup();
  final chime = AudioplayersChime();
  final scheduler = SchedulerService(
    data,
    clock: data.clock,
    chime: chime.play,
    notifier: LocalNotifierAlerts(),
  );
  // Benchmarks measure the buddy alone; a pop-up would skew them.
  if (!_benchmark) await scheduler.start();

  final bus = WindowBus(
    data,
    MultiWindowTransport(),
    onTestReminder: scheduler.testFire,
  );
  await bus.start();

  final login = LaunchAtLoginSync(
    data.settings,
    PluginLoginItem(msixPackageName: msixIdentityName),
  );
  Future<void> Function()? beforeQuit;
  late final TrayController tray;
  tray = TrayController(
    data,
    openDashboard: openDashboard,
    snoozeAll: scheduler.snoozeAll,
    quit: () async {
      await beforeQuit?.call();
      await login.dispose();
      await tray.dispose();
      await bus.dispose();
      await scheduler.dispose();
      await chime.dispose();
      await data.close();
      exit(0);
    },
  );
  if (!_benchmark) await tray.start();

  if (!_benchmark) await login.start();

  runApp(
    SpikeApp(
      data: data,
      scheduler: scheduler,
      onActivateRequested: () => unawaited(openDashboard()),
      registerQuitHook: (hook) => beforeQuit = hook,
    ),
  );
}

Future<void> _makeFirstReminderDueSoon(AppData data) async {
  final first = (await data.reminders.all())
      .where((r) => r.enabled)
      .firstOrNull;
  if (first == null) return;
  final due = data.clock.now().add(Duration(seconds: _demoFireIn()));
  // A full save bumps updatedAt, so the scheduler adopts this time.
  await data.reminders.save(
    first.copyWith(nextDueAt: due.millisecondsSinceEpoch),
  );
}

// -------------------------------------------------------------- dashboard

/// The normal window opened from the tray, with its own engine and its own
/// connection to the shared database.
Future<void> _runDashboard(AppData data, SeedData seed) async {
  final bus = WindowBus(data, MultiWindowTransport());
  await bus.start();

  try {
    await windowManager.ensureInitialized();
    await windowManager.waitUntilReadyToShow(
      const WindowOptions(
        title: Strings.appName,
        size: Size(1180, 820),
        minimumSize: Size(720, 560),
        center: true,
      ),
      () async {
        await windowManager.show();
        await windowManager.focus();
      },
    );
  } on Object {
    // Window styling is cosmetic; the plugin's own show() still applies.
  }

  runApp(
    ProviderScope(
      overrides: [
        appDataProvider.overrideWithValue(data),
        seedDataProvider.overrideWithValue(seed),
        windowBusProvider.overrideWithValue(bus),
      ],
      child: const DashboardApp(),
    ),
  );
}
