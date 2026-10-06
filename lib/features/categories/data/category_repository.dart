import 'package:desk_buddy/core/db/app_database.dart';
import 'package:desk_buddy/core/db/data_changes.dart';
import 'package:desk_buddy/features/categories/domain/category.dart';
import 'package:desk_buddy/shared/strings.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

class CategoryRepository {
  CategoryRepository(this._db, this._changes, {String Function()? newId})
    : _newId = newId ?? const Uuid().v4;

  final AppDatabase _db;
  final DataChanges _changes;
  final String Function() _newId;

  static const fallbackColor = '#64748B';

  SimpleSelectStatement<$CategoriesTable, CategoryRow> _ordered() =>
      _db.select(_db.categories)..orderBy([
        (c) => OrderingTerm(expression: c.sortOrder),
        (c) => OrderingTerm(expression: c.name),
      ]);

  Stream<List<Category>> watchAll() =>
      _ordered().watch().map((rows) => rows.map(_toModel).toList());

  Future<List<Category>> all() async =>
      (await _ordered().get()).map(_toModel).toList();

  Future<Category?> byId(String id) async {
    final row = await (_db.select(
      _db.categories,
    )..where((c) => c.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  /// Adds a category at the end of the list.
  Future<Category> create({
    String name = Strings.newCategoryName,
    String emoji = Strings.defaultCategoryEmoji,
    String colorHex = fallbackColor,
  }) async {
    final category = await _db.transaction(() async {
      final max = _db.categories.sortOrder.max();
      final top = await (_db.selectOnly(
        _db.categories,
      )..addColumns([max])).map((r) => r.read(max)).getSingle();
      final c = Category(
        id: _newId(),
        name: name,
        emoji: emoji,
        colorHex: colorHex,
        sortOrder: (top ?? -1) + 1,
      );
      await _db.into(_db.categories).insert(_toRow(c));
      return c;
    });
    _changes.notify({DataTopic.categories});
    return category;
  }

  Future<void> update(Category category) async {
    await _db.update(_db.categories).replace(_toRow(category));
    _changes.notify({DataTopic.categories});
  }

  /// Read-modify-write of one category in a transaction, so editing one
  /// field never writes back stale values of the others (D22). No-op if
  /// the category is gone.
  Future<void> updateWith(String id, Category Function(Category) change) async {
    final changed = await _db.transaction(() async {
      final current = await byId(id);
      if (current == null) return false;
      await _db.update(_db.categories).replace(_toRow(change(current)));
      return true;
    });
    if (changed) _changes.notify({DataTopic.categories});
  }

  /// Inserts categories as they are, ids included (backup restore).
  Future<void> insertAll(Iterable<Category> categories) async {
    await _db.batch(
      (b) => b.insertAll(_db.categories, categories.map(_toRow).toList()),
    );
    _changes.notify({DataTopic.categories});
  }

  /// The category named [name] (case-insensitive), created if missing.
  /// Starters reference categories by name.
  Future<Category> findOrCreateByName(
    String name, {
    String emoji = Strings.defaultCategoryEmoji,
    String colorHex = fallbackColor,
  }) async {
    final wanted = name.trim().toLowerCase();
    for (final c in await all()) {
      if (c.name.trim().toLowerCase() == wanted) return c;
    }
    return create(name: name.trim(), emoji: emoji, colorHex: colorHex);
  }

  /// Deletes [id], first moving its reminders to the first remaining
  /// category. Throws [LastCategoryException] for the last one.
  Future<void> delete(String id) async {
    await _db.transaction(() async {
      final rest = (await all()).where((c) => c.id != id).toList();
      if (rest.isEmpty) throw const LastCategoryException();
      await (_db.update(_db.reminders)..where((r) => r.categoryId.equals(id)))
          .write(RemindersCompanion(categoryId: Value(rest.first.id)));
      await (_db.delete(_db.categories)..where((c) => c.id.equals(id))).go();
    });
    _changes.notify({DataTopic.categories, DataTopic.reminders});
  }

  static Category _toModel(CategoryRow r) => Category(
    id: r.id,
    name: r.name,
    emoji: r.emoji,
    colorHex: r.colorHex,
    sortOrder: r.sortOrder,
  );

  static CategoryRow _toRow(Category c) => CategoryRow(
    id: c.id,
    name: c.name,
    emoji: c.emoji,
    colorHex: c.colorHex,
    sortOrder: c.sortOrder,
  );
}
