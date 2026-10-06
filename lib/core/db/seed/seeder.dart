import 'package:clock/clock.dart';
import 'package:desk_buddy/core/db/app_database.dart';
import 'package:desk_buddy/core/db/seed/seed_data.dart';
import 'package:desk_buddy/features/categories/data/category_repository.dart';
import 'package:desk_buddy/features/reminders/data/reminder_repository.dart';
import 'package:desk_buddy/features/reminders/domain/reminder.dart';
import 'package:desk_buddy/features/reminders/domain/starter.dart';

/// How many starters become real reminders on first launch (spec: the first
/// three); the rest stay one-tap templates.
const initialStarterCount = 3;

class Seeder {
  Seeder(
    this._db,
    this._categories,
    this._reminders, {
    this._clock = const Clock(),
  });

  final AppDatabase _db;
  final CategoryRepository _categories;
  final ReminderRepository _reminders;
  final Clock _clock;

  /// Seeds an empty database (no categories yet). Returns whether it did.
  ///
  /// Seeded reminders have `nextDueAt == null`; the scheduler computes it
  /// on start for every enabled reminder that has none.
  Future<bool> seedIfEmpty(SeedData data) => _db.transaction(() async {
    if ((await _categories.all()).isNotEmpty) return false;
    for (final c in data.categories) {
      await _categories.create(
        name: c.name,
        emoji: c.emoji,
        colorHex: c.colorHex,
      );
    }
    final now = _clock.now().millisecondsSinceEpoch;
    final reminders = <Reminder>[];
    for (final (i, s) in data.starters.take(initialStarterCount).indexed) {
      // Distinct createdAt keeps the starter order stable in the list.
      reminders.add(await reminderFromStarter(s, now: now + i));
    }
    await _reminders.saveAll(reminders);
    return true;
  });

  /// A reminder built from [starter], its category resolved by name (and
  /// created if it doesn't exist). Not saved, not scheduled.
  Future<Reminder> reminderFromStarter(Starter starter, {int? now}) async {
    final category = await _categories.findOrCreateByName(starter.category);
    return starter.toReminder(
      id: _reminders.newId(),
      categoryId: category.id,
      now: now ?? _clock.now().millisecondsSinceEpoch,
    );
  }
}
