import 'dart:io';

import 'package:clock/clock.dart';
import 'package:desk_buddy/core/db/app_data.dart';
import 'package:desk_buddy/core/db/app_database.dart';
import 'package:desk_buddy/core/db/seed/seed_data.dart';
import 'package:desk_buddy/features/reminders/domain/reminder.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

/// Tuesday 2026-10-06 10:00 local.
final testNow = DateTime(2026, 10, 6, 10);

/// Reads assets straight from the project folder.
Future<String> fileAsset(String path) => File(path).readAsString();

Future<SeedData> realSeed() => SeedData.load(fileAsset);

/// A fresh in-memory database with default rows (not seeded).
Future<AppData> memoryData({DateTime? now}) async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final data = AppData(
    AppDatabase(NativeDatabase.memory()),
    clock: Clock.fixed(now ?? testNow),
  );
  await data.settings.ensureRows();
  return data;
}

Reminder reminder(
  String id,
  String categoryId, {
  String title = 'Test',
  int createdAt = 0,
}) => Reminder(
  id: id,
  title: title,
  categoryId: categoryId,
  createdAt: createdAt,
  updatedAt: createdAt,
);
