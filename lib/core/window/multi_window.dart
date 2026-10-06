import 'package:desk_buddy/core/window/window_bus.dart';
import 'package:desk_buddy/core/window/window_role.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/services.dart';

/// The bus over a `desktop_multi_window` channel shared by the two engines.
class MultiWindowTransport implements BusTransport {
  final _channel = const WindowMethodChannel('desk_buddy/bus');

  @override
  Future<void> send(String method, Object? arguments) async {
    try {
      await _channel.invokeMethod<Object?>(method, arguments);
    } on PlatformException {
      // The other window isn't open — nothing to keep in step.
    } on MissingPluginException {
      // Same, on platforms that report it this way.
    }
  }

  @override
  Future<void> listen(
    Future<Object?> Function(String, Object?) handler,
  ) => _channel.setMethodCallHandler(
    (call) => handler(call.method, call.arguments),
  );

  @override
  Future<void> close() => _channel.setMethodCallHandler(null);
}

/// Shows the dashboard, creating it the first time.
Future<void> openDashboard() async {
  for (final c in await WindowController.getAll()) {
    if (WindowRole.parse(c.arguments) == WindowRole.dashboard) {
      await c.show();
      return;
    }
  }
  final c = await WindowController.create(
    WindowConfiguration(
      arguments: WindowRole.dashboard.encode(),
    ),
  );
  await c.show();
}
