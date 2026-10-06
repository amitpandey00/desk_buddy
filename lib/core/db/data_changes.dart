import 'dart:async';

/// What changed, at table granularity.
enum DataTopic { categories, reminders, log, settings, look }

/// Every repository write announces itself here. Within one window, drift's
/// own query streams already update; this exists for the *other* window,
/// which has its own connection and can't see those streams. Phase 5 forwards
/// it over the multi-window channel as `dataChanged`.
class DataChanges {
  final _controller = StreamController<Set<DataTopic>>.broadcast(sync: true);

  Stream<Set<DataTopic>> get stream => _controller.stream;

  void notify(Set<DataTopic> topics) {
    if (topics.isNotEmpty) _controller.add(Set.unmodifiable(topics));
  }

  Future<void> dispose() => _controller.close();
}
