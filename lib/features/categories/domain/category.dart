import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

/// A user-defined group of reminders. Only drives colors and grouping —
/// no code path ever branches on a category's name.
@freezed
abstract class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    required String emoji,

    /// `#RRGGBB`.
    required String colorHex,
    @Default(0) int sortOrder,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}

/// Thrown when deleting the only remaining category.
class LastCategoryException implements Exception {
  const LastCategoryException();

  @override
  String toString() =>
      'LastCategoryException: at least one category must exist';
}
