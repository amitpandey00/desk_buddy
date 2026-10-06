// drift declares column CHECKs by referring to the column getter itself.
// ignore_for_file: recursive_getters

import 'dart:convert';

import 'package:desk_buddy/features/buddy/domain/buddy_look.dart';
import 'package:desk_buddy/features/reminders/domain/log_entry.dart';
import 'package:desk_buddy/features/reminders/domain/reminder.dart';
import 'package:desk_buddy/features/settings/domain/app_settings.dart';
import 'package:drift/drift.dart';

// Row classes are suffixed `Row` so they never clash with the freezed domain
// models; repositories map between the two.
//
// Ids are UUID strings; timestamps are UTC epoch milliseconds.

@DataClassName('CategoryRow')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get emoji => text()();
  TextColumn get colorHex => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ReminderRow')
class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get emoji => text()();
  TextColumn get messageTemplate => text()();

  // No cascade: deleting a category first moves its reminders (repository).
  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get scheduleType => textEnum<ScheduleType>()();
  IntColumn get everyMinutes =>
      integer().check(everyMinutes.isBiggerOrEqualValue(1))();
  TextColumn get activeFrom => text().nullable()();
  TextColumn get activeTo => text().nullable()();
  TextColumn get timeOfDay => text()();
  TextColumn get daysOfWeek => text().map(const IntListConverter())();
  TextColumn get date => text().nullable()();
  IntColumn get dailyGoal =>
      integer().check(dailyGoal.isBiggerOrEqualValue(0))();
  TextColumn get goalUnit => text()();
  TextColumn get propId => text()();
  TextColumn get doneLabel => text()();
  BoolColumn get enabled => boolean()();
  IntColumn get nextDueAt => integer().nullable()();
  TextColumn get source => text().withDefault(const Constant('local'))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('LogEntryRow')
@TableIndex(name: 'log_entries_at', columns: {#at})
@TableIndex(name: 'log_entries_reminder_at', columns: {#reminderId, #at})
class LogEntries extends Table {
  TextColumn get id => text()();

  // Not a foreign key: history outlives the reminder.
  TextColumn get reminderId => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  IntColumn get at => integer()();
  TextColumn get action => textEnum<LogAction>()();
  IntColumn get responseSeconds => integer().withDefault(const Constant(0))();
  BoolColumn get manual => boolean().withDefault(const Constant(false))();
  BoolColumn get sample => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Single row (`id = 1`).
@DataClassName('BuddyLookRow')
class BuddyLooks extends Table {
  IntColumn get id =>
      integer().check(id.equals(1)).withDefault(const Constant(1))();
  TextColumn get skinHex => text()();
  TextColumn get hairHex => text()();
  TextColumn get jacketHex => text()();
  TextColumn get shirtHex => text()();
  TextColumn get pantsHex => text()();
  TextColumn get shoesHex => text()();
  TextColumn get hairStyle => textEnum<HairStyle>()();
  TextColumn get hat => textEnum<HatStyle>()();
  BoolColumn get spectacles => boolean()();
  TextColumn get defaultPropId => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Single row (`id = 1`).
@DataClassName('SettingsRow')
class SettingsTable extends Table {
  @override
  String get tableName => 'settings';

  IntColumn get id =>
      integer().check(id.equals(1)).withDefault(const Constant(1))();
  TextColumn get userName => text()();
  IntColumn get buddySize => integer()();
  IntColumn get walkSpeed => integer()();
  BoolColumn get walkEnabled => boolean()();
  BoolColumn get buddyVisible => boolean()();
  BoolColumn get soundEnabled => boolean()();
  IntColumn get snoozeMinutes => integer()();
  IntColumn get autoMissMinutes => integer()();
  BoolColumn get doNotDisturb => boolean()();
  TextColumn get themeMode => textEnum<ThemePreference>()();
  BoolColumn get launchAtLogin => boolean()();

  /// Added in schema v2.
  BoolColumn get focusPopups => boolean().withDefault(const Constant(false))();
  RealColumn get buddyX => real().nullable()();
  RealColumn get buddyY => real().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// `List<int>` ↔ JSON text, e.g. `[1,2,3]`.
class IntListConverter extends TypeConverter<List<int>, String> {
  const IntListConverter();

  @override
  List<int> fromSql(String fromDb) =>
      (jsonDecode(fromDb) as List<dynamic>).cast<int>();

  @override
  String toSql(List<int> value) => jsonEncode(value);
}
