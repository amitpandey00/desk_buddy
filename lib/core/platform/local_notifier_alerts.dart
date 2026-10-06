import 'package:desk_buddy/features/scheduler/application/alert_view.dart';
import 'package:desk_buddy/shared/strings.dart';
import 'package:local_notifier/local_notifier.dart';

/// System notification fallback for when the buddy is hidden. Windows toasts
/// show both buttons; on macOS the action buttons depend on the user's
/// notification style, and clicking the notification counts as nothing (the
/// pop-up then auto-misses like an unanswered bubble).
class LocalNotifierAlerts implements AlertNotifier {
  LocalNotification? _shown;

  /// Call once at startup (registers the app with the OS notifier).
  static Future<void> setup() => localNotifier.setup(appName: Strings.appName);

  @override
  Future<void> show(
    AlertView alert, {
    required void Function() onDone,
    required void Function() onSnooze,
  }) async {
    await dismiss();
    final n = LocalNotification(
      title: '${alert.emoji} ${alert.reminder.title}',
      body: [alert.message, ?alert.progress].join('\n'),
      actions: [
        LocalNotificationAction(text: alert.doneLabel),
        LocalNotificationAction(text: alert.snoozeLabel),
      ],
    )..onClickAction = (i) => i == 0 ? onDone() : onSnooze();
    _shown = n;
    await n.show(); // may throw (notifications off): the scheduler reports it
  }

  @override
  Future<void> dismiss() async {
    final n = _shown;
    _shown = null;
    if (n != null) {
      try {
        await n.close();
      } on Object {
        // Already dismissed by the user or the OS.
      }
    }
  }
}
