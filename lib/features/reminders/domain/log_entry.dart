import 'package:freezed_annotation/freezed_annotation.dart';

part 'log_entry.freezed.dart';
part 'log_entry.g.dart';

enum LogAction { done, snoozed, missed }

/// One response to a reminder. Kept when its reminder is deleted.
@freezed
abstract class LogEntry with _$LogEntry {
  const factory LogEntry({
    required String id,

    /// Epoch ms.
    required int at,
    required LogAction action,
    String? reminderId,

    /// Snapshot of the reminder's category when this was logged.
    String? categoryId,

    /// From pop-up to response.
    @Default(0) int responseSeconds,

    /// Logged with "+1" rather than answering a pop-up.
    @Default(false) bool manual,

    /// Generated history (debug builds only), removable in one go.
    @Default(false) bool sample,
  }) = _LogEntry;

  factory LogEntry.fromJson(Map<String, dynamic> json) =>
      _$LogEntryFromJson(json);
}
