import 'package:desk_buddy/core/db/app_database.steps.dart';
import 'package:desk_buddy/core/db/tables.dart';
import 'package:desk_buddy/features/buddy/domain/buddy_look.dart';
import 'package:desk_buddy/features/reminders/domain/log_entry.dart';
import 'package:desk_buddy/features/reminders/domain/reminder.dart';
import 'package:desk_buddy/features/settings/domain/app_settings.dart';
import 'package:drift/drift.dart';

part 'app_database.g.dart';

/// The one SQLite database both windows share (WAL mode, see
/// `open_database.dart`). Features talk to repositories, never to this.
@DriftDatabase(
  tables: [Categories, Reminders, LogEntries, BuddyLooks, SettingsTable],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Bump with every schema change, add a step to [migration], and run
  /// `dart run drift_dev make-migrations` (see CLAUDE.md).
  @override
  int get schemaVersion => 3;

  // Note: drift's native executor opens every transaction with
  // `BEGIN IMMEDIATE`, so a read-then-write transaction holds the write lock
  // from the start; the other window's writers wait on busy_timeout instead
  // of hitting SQLITE_BUSY_SNAPSHOT (tested in database_file_test.dart).

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: stepByStep(
      // v2: Settings → "Focus pop-ups" (keyboard / screen-reader access).
      from1To2: (m, schema) async {
        await m.addColumn(schema.settings, schema.settings.focusPopups);
      },
      // v3: Settings → "Always on screen" (off = buddy only for reminders).
      from2To3: (m, schema) async {
        await m.addColumn(schema.settings, schema.settings.buddyAlwaysOn);
      },
    ),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
