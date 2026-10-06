import 'package:clock/clock.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock_provider.g.dart';

/// The only source of "now". Override with `Clock.fixed(...)` in tests.
/// (`const Clock()` reads `DateTime.now()`, which is why this folder is the
/// one place the guard test allows it.)
@Riverpod(keepAlive: true)
Clock appClock(Ref ref) => const Clock();
