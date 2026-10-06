import 'package:desk_buddy/core/db/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;

/// Guards the schema against accidental changes and, from v2 on, checks every
/// migration step. When bumping `schemaVersion`:
///   1. add the migration step in `AppDatabase.migration`
///   2. `dart run drift_dev make-migrations` (dumps the new schema, generates
///      step tests and helpers under test/drift/app/)
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test(
    'the code schema is exactly the dumped schema of the current version',
    () async {
      final db = AppDatabase(await verifier.startAt(1));
      addTearDown(db.close);
      // Opens a v1 database, runs any migrations up to the current version,
      // and compares the result with what the current code would create.
      await verifier.migrateAndValidate(db, db.schemaVersion);
    },
  );

  test('schema version matches the newest dumped schema', () {
    expect(GeneratedHelper.versions.last, 3);
  });

  test('v2 → v3 keeps settings and adds buddyAlwaysOn = false', () async {
    await verifier.testWithDataIntegrity(
      oldVersion: 2,
      newVersion: 3,
      createOld: v2.DatabaseAtV2.new,
      createNew: v3.DatabaseAtV3.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insert(
          oldDb.settings,
          v2.SettingsCompanion.insert(
            userName: 'Sam',
            buddySize: 150,
            walkSpeed: 60,
            walkEnabled: 1,
            buddyVisible: 1,
            soundEnabled: 1,
            snoozeMinutes: 10,
            autoMissMinutes: 5,
            doNotDisturb: 0,
            themeMode: 'system',
            launchAtLogin: 0,
          ),
        );
      },
      validateItems: (newDb) async {
        final s = await newDb.select(newDb.settings).getSingle();
        expect(s.userName, 'Sam');
        expect(s.buddyAlwaysOn, 0);
      },
    );
  });

  test('v1 → v2 keeps every row and adds focusPopups = false', () async {
    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch
          ..insert(
            oldDb.categories,
            v1.CategoriesCompanion.insert(
              id: 'c',
              name: 'Health',
              emoji: 'h',
              colorHex: '#1FA97F',
            ),
          )
          ..insert(
            oldDb.settings,
            v1.SettingsCompanion.insert(
              userName: 'Sam',
              buddySize: 150,
              walkSpeed: 60,
              walkEnabled: 1,
              buddyVisible: 1,
              soundEnabled: 0,
              snoozeMinutes: 15,
              autoMissMinutes: 5,
              doNotDisturb: 0,
              themeMode: 'dark',
              launchAtLogin: 1,
            ),
          );
      },
      validateItems: (newDb) async {
        final s = await newDb.select(newDb.settings).getSingle();
        expect(s.userName, 'Sam');
        expect(s.buddySize, 150);
        expect(s.themeMode, 'dark');
        expect(s.focusPopups, 0);
        expect(await newDb.select(newDb.categories).get(), hasLength(1));
      },
    );
  });
}
