import 'package:clock/clock.dart';
import 'package:desk_buddy/app/dashboard_app.dart';
import 'package:desk_buddy/app/providers.dart';
import 'package:desk_buddy/core/clock/clock_provider.dart';
import 'package:desk_buddy/core/db/app_data.dart';
import 'package:desk_buddy/core/db/providers.dart';
import 'package:desk_buddy/core/window/window_bus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_data.dart';

/// Records what the dashboard asks the overlay to do.
class RecordingBus implements BusTransport {
  final calls = <(String, Object?)>[];
  @override
  Future<void> send(String method, Object? arguments) async =>
      calls.add((method, arguments));
  @override
  Future<void> listen(Future<Object?> Function(String, Object?) h) async {}
  @override
  Future<void> close() async {}
}

class DashboardHarness {
  DashboardHarness._(this.data, this.bus);

  final AppData data;
  final RecordingBus bus;

  /// A seeded in-memory database (prepared outside the fake-async zone).
  static Future<DashboardHarness> create(WidgetTester tester) async {
    late AppData data;
    await tester.runAsync(() async {
      data = await memoryData();
      await data.prepare(await realSeed());
    });
    return DashboardHarness._(data, RecordingBus());
  }

  /// Runs real async database work from inside a widget test.
  Future<T> db<T>(WidgetTester tester, Future<T> Function(AppData d) f) async {
    late T out;
    await tester.runAsync(() async => out = await f(data));
    return out;
  }

  Future<void> pump(
    WidgetTester tester, {
    Size size = const Size(1280, 900),
    DashboardSection section = DashboardSection.dashboard,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final seed = await tester.runAsync(realSeed);
    final container = ProviderContainer(
      overrides: [
        appDataProvider.overrideWithValue(data),
        seedDataProvider.overrideWithValue(seed!),
        windowBusProvider.overrideWithValue(WindowBus(data, bus)),
        appClockProvider.overrideWithValue(Clock.fixed(testNow)),
        nowProvider.overrideWith(
          (ref) => Stream.value(testNow.millisecondsSinceEpoch),
        ),
      ],
    );
    container.read(currentSectionProvider.notifier).go(section);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const DashboardApp(),
      ),
    );
    await settle(tester);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await tester.runAsync(data.close);
    });
  }

  /// Lets drift queries complete and the UI rebuild.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 50));
    }
  }
}
