import 'package:desk_buddy/features/reminders/domain/reminder.dart';
import 'package:desk_buddy/shared/strings.dart';

/// Everything the bubble (or the fallback notification) shows for a pop-up.
class AlertView {
  const AlertView({
    required this.reminder,
    required this.message,
    required this.doneLabel,
    required this.snoozeLabel,
    required this.firedAt,
    required this.test,
    this.progress,
  });

  final Reminder reminder;

  /// The filled message template.
  final String message;

  /// "3 / 8 … today" when the reminder has a goal.
  final String? progress;
  final String doneLabel;
  final String snoozeLabel;

  /// The "No" button (didn't do it).
  String get skipLabel => Strings.bubbleNo;
  final int firedAt;

  /// A "Test" / "Preview" pop-up: answering it logs nothing.
  final bool test;

  String get emoji => reminder.emoji;
  String get propId => reminder.propId;
}

/// Plays the reminder chime.
typedef PlayChime = Future<void> Function();

Future<void> silentChime() async {}

/// Shows a pop-up as a system notification when the buddy is hidden.
abstract interface class AlertNotifier {
  Future<void> show(
    AlertView alert, {
    required void Function() onDone,
    required void Function() onSkip,
    required void Function() onSnooze,
  });

  Future<void> dismiss();
}

class NoAlertNotifier implements AlertNotifier {
  const NoAlertNotifier();
  @override
  Future<void> show(
    AlertView alert, {
    required void Function() onDone,
    required void Function() onSkip,
    required void Function() onSnooze,
  }) async {}
  @override
  Future<void> dismiss() async {}
}
