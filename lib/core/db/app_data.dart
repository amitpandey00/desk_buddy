import 'dart:io';

import 'package:clock/clock.dart';
import 'package:desk_buddy/core/db/app_database.dart';
import 'package:desk_buddy/core/db/data_changes.dart';
import 'package:desk_buddy/core/db/open_database.dart';
import 'package:desk_buddy/core/db/seed/seed_data.dart';
import 'package:desk_buddy/core/db/seed/seeder.dart';
import 'package:desk_buddy/features/categories/data/category_repository.dart';
import 'package:desk_buddy/features/reminders/data/log_repository.dart';
import 'package:desk_buddy/features/reminders/data/reminder_repository.dart';
import 'package:desk_buddy/features/settings/data/settings_repository.dart';

/// The database plus every repository built on it, for one window.
class AppData {
  AppData(this.db, {Clock clock = const Clock(), DataChanges? changes})
    : changes = changes ?? DataChanges(),
      _clock = clock {
    categories = CategoryRepository(db, this.changes);
    reminders = ReminderRepository(db, this.changes, clock: clock);
    log = LogRepository(db, this.changes);
    settings = SettingsRepository(db, this.changes);
    seeder = Seeder(db, categories, reminders, clock: clock);
  }

  final AppDatabase db;
  final DataChanges changes;
  final Clock _clock;

  /// The clock every repository here uses.
  Clock get clock => _clock;
  late final CategoryRepository categories;
  late final ReminderRepository reminders;
  late final LogRepository log;
  late final SettingsRepository settings;
  late final Seeder seeder;

  /// Startup housekeeping every window runs: default rows, first-launch
  /// seed, and log retention. Safe to run repeatedly and from both windows.
  Future<void> prepare(SeedData seed) async {
    await settings.ensureRows();
    await seeder.seedIfEmpty(seed);
    await log.pruneBefore(retentionCutoff(_clock.now()));
  }

  /// Settings → "Reset everything": deletes reminders, history and
  /// categories, restores default settings and look, and seeds again.
  Future<void> resetEverything(SeedData seed) async {
    await db.transaction(() async {
      await db.delete(db.logEntries).go();
      await db.delete(db.reminders).go();
      await db.delete(db.categories).go();
      await db.delete(db.settingsTable).go();
      await db.delete(db.buddyLooks).go();
      await settings.ensureRows();
      await seeder.seedIfEmpty(seed);
    });
    changes.notify(DataTopic.values.toSet());
  }

  Future<void> close() async {
    await changes.dispose();
    await db.close();
  }
}

/// Local midnight [logRetentionDays] days before [now]. Built from calendar
/// fields so a DST change can't shift it by an hour.
int retentionCutoff(DateTime now) => DateTime(
  now.year,
  now.month,
  now.day - logRetentionDays,
).millisecondsSinceEpoch;

/// Opens the shared database and prepares it.
Future<AppData> openAppData({
  required SeedData seed,
  File? file,
  Clock clock = const Clock(),
}) async {
  final data = AppData(await openAppDatabase(file: file), clock: clock);
  await data.prepare(seed);
  return data;
}
