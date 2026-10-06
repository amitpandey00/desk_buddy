import 'dart:async';

import 'package:flutter/services.dart';

/// A monitor, in physical virtual-screen pixels.
class NativeDisplay {
  const NativeDisplay({
    required this.id,
    required this.bounds,
    required this.work,
    required this.scale,
    required this.primary,
  });

  final int id;
  final Rect bounds;

  /// The visible frame: excludes the taskbar wherever it is docked.
  final Rect work;
  final double scale;
  final bool primary;
}

class CursorState {
  const CursorState(this.position, {required this.buttonDown});
  final Offset position;
  final bool buttonDown;
}

/// Dart side of the runner's `desk_buddy/overlay` channel (Windows).
/// All coordinates are physical pixels.
class OverlayNative {
  OverlayNative() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'displaysChanged':
          onDisplaysChanged?.call();
        case 'accessibilityChanged':
          onAccessibilityChanged?.call();
        case 'activateRequested':
          onActivateRequested?.call();
      }
    });
  }

  static const _channel = MethodChannel('desk_buddy/overlay');

  void Function()? onDisplaysChanged;
  void Function()? onAccessibilityChanged;

  /// Someone launched the app again: show the dashboard.
  void Function()? onActivateRequested;

  /// Round-trip time of every call, for the benchmark.
  final latenciesMicros = <int>[];
  int calls = 0;

  Future<T?> _call<T>(String method, [Object? args]) async {
    final sw = Stopwatch()..start();
    final result = await _channel.invokeMethod<T>(method, args);
    latenciesMicros.add(sw.elapsedMicroseconds);
    calls++;
    return result;
  }

  static Rect _rect(Object? v) {
    final l = (v! as List<Object?>).cast<int>();
    return Rect.fromLTRB(
      l[0].toDouble(),
      l[1].toDouble(),
      l[2].toDouble(),
      l[3].toDouble(),
    );
  }

  Future<List<NativeDisplay>> displays() async {
    final raw = await _call<List<Object?>>('getDisplays') ?? const [];
    return [
      for (final d in raw.cast<Map<Object?, Object?>>())
        NativeDisplay(
          id: d['id']! as int,
          bounds: _rect(d['bounds']),
          work: _rect(d['work']),
          scale: d['scale']! as double,
          primary: d['primary']! as bool,
        ),
    ];
  }

  Future<CursorState> cursor() async {
    final l = (await _call<List<Object?>>('getCursor'))!;
    return CursorState(
      Offset((l[0]! as int).toDouble(), (l[1]! as int).toDouble()),
      buttonDown: l[2]! as bool,
    );
  }

  Future<void> setFrame({Offset? position, Size? size}) =>
      _call<void>('setFrame', {
        if (position != null) ...{
          'x': position.dx.round(),
          'y': position.dy.round(),
        },
        if (size != null) ...{
          'w': size.width.round(),
          'h': size.height.round(),
        },
      });

  /// OS accessibility state: (reduce motion, screen reader running).
  Future<({bool reduceMotion, bool screenReader})> accessibility() async {
    final m = (await _call<Map<Object?, Object?>>('getAccessibility'))!;
    return (
      reduceMotion: m['reduceMotion']! as bool,
      screenReader: m['screenReader']! as bool,
    );
  }

  /// Takes keyboard focus for a pop-up; true if Windows granted it.
  Future<bool> focusForAlert() async =>
      await _call<bool>('focusForAlert') ?? false;

  /// Gives focus back to whichever app had it before [focusForAlert].
  Future<void> releaseFocus() => _call<void>('releaseFocus');

  /// Shows (without activating) or hides the overlay window.
  Future<void> setVisible({required bool visible}) =>
      _call<void>('setVisible', {'visible': visible});

  Future<void> setClickThrough({required bool enabled}) =>
      _call<void>('setClickThrough', {'enabled': enabled});

  /// Client-relative physical rects; `null` makes the whole window hittable.
  Future<void> setHitRegion(List<Rect>? rects) => _call<void>('setHitRegion', {
    'rects': rects
        ?.map(
          (r) => [
            r.left.floor(),
            r.top.floor(),
            r.right.ceil(),
            r.bottom.ceil(),
          ],
        )
        .toList(),
  });

  /// Total process CPU time in microseconds, and the logical core count.
  Future<(int, int)> cpuTimes() async {
    final l = (await _channel.invokeMethod<List<Object?>>('cpuTimes'))!;
    return (l[0]! as int, l[1]! as int);
  }
}
