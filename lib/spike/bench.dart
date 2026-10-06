import 'dart:convert';
import 'dart:io';

import 'package:desk_buddy/spike/overlay_native.dart';
import 'package:flutter/scheduler.dart';

/// Records frame timings, native-call latency and process CPU for one phase.
class PhaseRecorder {
  PhaseRecorder(this.name, this.native);

  final String name;
  final OverlayNative native;
  final _build = <int>[];
  final _raster = <int>[];
  late int _cpuStart;
  late int _calls0;
  late int _lat0;
  final _wall = Stopwatch();

  void _onTimings(List<FrameTiming> timings) {
    for (final t in timings) {
      _build.add(t.buildDuration.inMicroseconds);
      _raster.add(t.rasterDuration.inMicroseconds);
    }
  }

  Future<void> start() async {
    _cpuStart = (await native.cpuTimes()).$1;
    _calls0 = native.calls;
    _lat0 = native.latenciesMicros.length;
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
    _wall.start();
  }

  Future<Map<String, Object?>> stop() async {
    _wall.stop();
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
    final (cpu, cores) = await native.cpuTimes();
    final secs = _wall.elapsedMicroseconds / 1e6;
    final oneCore = (cpu - _cpuStart) / _wall.elapsedMicroseconds * 100;
    final lat = native.latenciesMicros.sublist(_lat0);
    return {
      'phase': name,
      'seconds': double.parse(secs.toStringAsFixed(1)),
      'cpuPctOfOneCore': double.parse(oneCore.toStringAsFixed(2)),
      'cpuPctOfMachine': double.parse((oneCore / cores).toStringAsFixed(2)),
      'fps': double.parse((_build.length / secs).toStringAsFixed(1)),
      'buildMs': _pct(_build),
      'rasterMs': _pct(_raster),
      'nativeCallsPerSec': double.parse(
        ((native.calls - _calls0) / secs).toStringAsFixed(1),
      ),
      'nativeLatencyMs': _pct(lat),
    };
  }

  static Map<String, double> _pct(List<int> micros) {
    if (micros.isEmpty) return const {};
    final s = [...micros]..sort();
    double at(double p) => s[((s.length - 1) * p).round()] / 1000;
    double r(double v) => double.parse(v.toStringAsFixed(2));
    return {'p50': r(at(.5)), 'p90': r(at(.9)), 'p99': r(at(.99))};
  }
}

void writeResults(String path, Map<String, Object?> results) {
  File(path).writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(results),
  );
}
