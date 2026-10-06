import 'package:desk_buddy/core/db/app_data.dart';
import 'package:desk_buddy/core/db/data_changes.dart';
import 'package:desk_buddy/features/buddy/domain/buddy_look.dart';
import 'package:desk_buddy/features/categories/domain/category.dart';
import 'package:desk_buddy/features/reminders/domain/log_entry.dart';
import 'package:desk_buddy/features/reminders/domain/reminder.dart';
import 'package:desk_buddy/features/settings/domain/app_settings.dart';
import 'package:desk_buddy/shared/strings.dart';

const backupFormat = 'desk-buddy-backup';

/// Bump when the JSON shape changes incompatibly; [BackupService.parse]
/// accepts versions up to this.
const backupVersion = 1;

class BackupException implements Exception {
  const BackupException(this.message);
  final String message;

  @override
  String toString() => 'BackupException: $message';
}

/// A validated backup, ready to show in the confirmation dialog.
class Backup {
  const Backup({
    required this.categories,
    required this.reminders,
    required this.log,
    required this.settings,
    required this.look,
    this.exportedAt,
  });

  final List<Category> categories;
  final List<Reminder> reminders;
  final List<LogEntry> log;
  final AppSettings settings;
  final BuddyLook look;
  final String? exportedAt;
}

/// Settings → Export / Import (spec §7). Everything travels: categories,
/// reminders, history, settings and look.
class BackupService {
  BackupService(this._data);

  final AppData _data;

  Future<Map<String, Object?>> export() async {
    final settings = await _data.settings.get();
    return {
      'format': backupFormat,
      'version': backupVersion,
      'schemaVersion': _data.db.schemaVersion,
      'exportedAt': _data.clock.now().toIso8601String(),
      'categories': [
        for (final c in await _data.categories.all()) c.toJson(),
      ],
      'reminders': [for (final r in await _data.reminders.all()) r.toJson()],
      'log': [for (final l in await _data.log.since(0)) l.toJson()],
      // Screen coordinates mean nothing on another machine.
      'settings': settings.copyWith(buddyX: null, buddyY: null).toJson(),
      'look': (await _data.settings.getLook()).toJson(),
    };
  }

  /// Validates [json] without touching the database.
  static Backup parse(Object? json) {
    if (json is! Map<String, dynamic> || json['format'] != backupFormat) {
      throw const BackupException(Strings.backupNotOurs);
    }
    final version = json['version'];
    if (version is! int || version > backupVersion) {
      throw const BackupException(Strings.backupTooNew);
    }
    List<T> list<T>(String key, T Function(Map<String, dynamic>) f) =>
        ((json[key] as List<dynamic>?) ?? const [])
            .cast<Map<String, dynamic>>()
            .map(f)
            .toList();
    try {
      final categories = list('categories', Category.fromJson);
      if (categories.isEmpty) {
        throw const BackupException(Strings.backupNoCategories);
      }
      final known = {for (final c in categories) c.id};
      final reminderList = list('reminders', Reminder.fromJson);
      final logList = list('log', LogEntry.fromJson);
      bool unique(Iterable<String> ids) => ids.toSet().length == ids.length;
      // A merged or hand-edited file could repeat ids; restoring it would
      // fail half-way (UNIQUE constraint), so reject it up front.
      if (!unique(known.isEmpty ? const [] : categories.map((c) => c.id)) ||
          !unique(reminderList.map((r) => r.id)) ||
          !unique(logList.map((l) => l.id))) {
        throw const BackupException(Strings.backupDamaged);
      }
      final reminders = [
        for (final r in reminderList)
          r.copyWith(
            // Keep every reminder reachable even if its category is gone.
            categoryId: known.contains(r.categoryId)
                ? r.categoryId
                : categories.first.id,
            // Re-planned from "now" by the scheduler after import.
            nextDueAt: null,
            everyMinutes: r.everyMinutes < 1 ? 1 : r.everyMinutes,
            dailyGoal: r.dailyGoal < 0 ? 0 : r.dailyGoal,
          ),
      ];
      return Backup(
        categories: categories,
        reminders: reminders,
        log: logList,
        settings: AppSettings.fromJson(
          (json['settings'] as Map<String, dynamic>?) ?? const {},
        ).normalized(),
        look: json['look'] == null
            ? LookPresets.classic
            : BuddyLook.fromJson(json['look']! as Map<String, dynamic>),
        exportedAt: json['exportedAt'] as String?,
      );
    } on BackupException {
      rethrow;
    } on Object {
      throw const BackupException(Strings.backupDamaged);
    }
  }

  /// Replaces everything with [backup] in one transaction. Machine-specific
  /// settings are kept: the buddy's position, and launch at login (importing
  /// another PC's backup must not register this one to start at login).
  /// Throws (and rolls back) if the database rejects anything.
  Future<void> restore(Backup backup) async {
    final db = _data.db;
    final here = await _data.settings.get();
    await db.transaction(() async {
      await db.delete(db.logEntries).go();
      await db.delete(db.reminders).go();
      await db.delete(db.categories).go();
      await _data.categories.insertAll(backup.categories);
      await _data.reminders.saveAll(backup.reminders);
      await _data.log.addAll(backup.log);
      await _data.settings.save(
        backup.settings.copyWith(
          buddyX: here.buddyX,
          buddyY: here.buddyY,
          launchAtLogin: here.launchAtLogin,
        ),
      );
      await _data.settings.saveLook(backup.look);
    });
    _data.changes.notify(DataTopic.values.toSet());
  }
}
