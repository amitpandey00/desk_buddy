import 'package:desk_buddy/core/db/app_database.dart';
import 'package:desk_buddy/core/db/data_changes.dart';
import 'package:desk_buddy/features/buddy/domain/buddy_look.dart';
import 'package:desk_buddy/features/settings/domain/app_settings.dart';
import 'package:drift/drift.dart';

/// The two single-row tables: settings and the buddy's look.
class SettingsRepository {
  SettingsRepository(this._db, this._changes);

  final AppDatabase _db;
  final DataChanges _changes;

  static const BuddyLook defaultLook = LookPresets.classic;

  /// Inserts default rows if they're missing (first launch, or a damaged
  /// import). Never overwrites existing values.
  Future<void> ensureRows() async {
    await _db.batch((b) {
      b
        ..insert(
          _db.settingsTable,
          _settingsRow(const AppSettings()),
          mode: InsertMode.insertOrIgnore,
        )
        ..insert(
          _db.buddyLooks,
          _lookRow(defaultLook),
          mode: InsertMode.insertOrIgnore,
        );
    });
  }

  // ---- settings ----

  Stream<AppSettings> watch() => _db
      .select(_db.settingsTable)
      .watchSingleOrNull()
      .map((r) => r == null ? const AppSettings() : _settings(r));

  Future<AppSettings> get() async {
    final r = await _db.select(_db.settingsTable).getSingleOrNull();
    return r == null ? const AppSettings() : _settings(r);
  }

  // `toCompanion(false)`: an upsert must write nulls too (a data class
  // alone treats null as "leave unchanged" on the update path).
  /// Replaces the settings (normalized into valid ranges).
  Future<AppSettings> save(AppSettings settings) async {
    final s = settings.normalized();
    await _db
        .into(_db.settingsTable)
        .insertOnConflictUpdate(_settingsRow(s).toCompanion(false));
    _changes.notify({DataTopic.settings});
    return s;
  }

  /// Read-modify-write in one transaction.
  Future<AppSettings> update(AppSettings Function(AppSettings) change) async {
    final s = await _db.transaction(() async {
      final next = change(await get()).normalized();
      await _db
          .into(_db.settingsTable)
          .insertOnConflictUpdate(_settingsRow(next).toCompanion(false));
      return next;
    });
    _changes.notify({DataTopic.settings});
    return s;
  }

  /// Writes only the position columns: the overlay saves this often, and it
  /// must never overwrite a setting the dashboard just changed.
  Future<void> saveBuddyPosition(double? x, double? y) async {
    await _db
        .update(_db.settingsTable)
        .write(
          SettingsTableCompanion(buddyX: Value(x), buddyY: Value(y)),
        );
    // Not announced: nothing else displays the position.
  }

  // ---- look ----

  Stream<BuddyLook> watchLook() => _db
      .select(_db.buddyLooks)
      .watchSingleOrNull()
      .map((r) => r == null ? defaultLook : _look(r));

  Future<BuddyLook> getLook() async {
    final r = await _db.select(_db.buddyLooks).getSingleOrNull();
    return r == null ? defaultLook : _look(r);
  }

  /// Read-modify-write of the look in one transaction (never save a copy of
  /// a widget's snapshot — the other window may have changed it, D22).
  Future<BuddyLook> updateLook(BuddyLook Function(BuddyLook) change) async {
    final next = await _db.transaction(() async {
      final l = change(await getLook());
      await _db
          .into(_db.buddyLooks)
          .insertOnConflictUpdate(_lookRow(l).toCompanion(false));
      return l;
    });
    _changes.notify({DataTopic.look});
    return next;
  }

  Future<void> saveLook(BuddyLook look) async {
    await _db
        .into(_db.buddyLooks)
        .insertOnConflictUpdate(_lookRow(look).toCompanion(false));
    _changes.notify({DataTopic.look});
  }

  // ---- mapping ----

  static AppSettings _settings(SettingsRow r) => AppSettings(
    userName: r.userName,
    buddySize: r.buddySize,
    walkSpeed: r.walkSpeed,
    walkEnabled: r.walkEnabled,
    buddyVisible: r.buddyVisible,
    soundEnabled: r.soundEnabled,
    snoozeMinutes: r.snoozeMinutes,
    autoMissMinutes: r.autoMissMinutes,
    doNotDisturb: r.doNotDisturb,
    themeMode: r.themeMode,
    launchAtLogin: r.launchAtLogin,
    focusPopups: r.focusPopups,
    buddyAlwaysOn: r.buddyAlwaysOn,
    buddyX: r.buddyX,
    buddyY: r.buddyY,
  );

  static SettingsRow _settingsRow(AppSettings s) => SettingsRow(
    id: 1,
    userName: s.userName,
    buddySize: s.buddySize,
    walkSpeed: s.walkSpeed,
    walkEnabled: s.walkEnabled,
    buddyVisible: s.buddyVisible,
    soundEnabled: s.soundEnabled,
    snoozeMinutes: s.snoozeMinutes,
    autoMissMinutes: s.autoMissMinutes,
    doNotDisturb: s.doNotDisturb,
    themeMode: s.themeMode,
    launchAtLogin: s.launchAtLogin,
    focusPopups: s.focusPopups,
    buddyAlwaysOn: s.buddyAlwaysOn,
    buddyX: s.buddyX,
    buddyY: s.buddyY,
  );

  static BuddyLook _look(BuddyLookRow r) => BuddyLook(
    skinHex: r.skinHex,
    hairHex: r.hairHex,
    jacketHex: r.jacketHex,
    shirtHex: r.shirtHex,
    pantsHex: r.pantsHex,
    shoesHex: r.shoesHex,
    hairStyle: r.hairStyle,
    hat: r.hat,
    spectacles: r.spectacles,
    defaultPropId: r.defaultPropId,
  );

  static BuddyLookRow _lookRow(BuddyLook l) => BuddyLookRow(
    id: 1,
    skinHex: l.skinHex,
    hairHex: l.hairHex,
    jacketHex: l.jacketHex,
    shirtHex: l.shirtHex,
    pantsHex: l.pantsHex,
    shoesHex: l.shoesHex,
    hairStyle: l.hairStyle,
    hat: l.hat,
    spectacles: l.spectacles,
    defaultPropId: l.defaultPropId,
  );
}
