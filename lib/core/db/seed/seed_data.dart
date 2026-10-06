import 'dart:convert';

import 'package:desk_buddy/features/reminders/domain/starter.dart';

typedef AssetLoader = Future<String> Function(String path);

const defaultCategoriesAsset = 'assets/seed/default_categories.json';
const startersAsset = 'assets/seed/starters.json';

class SeedCategory {
  const SeedCategory({
    required this.name,
    required this.emoji,
    required this.colorHex,
  });

  factory SeedCategory.fromJson(Map<String, dynamic> json) => SeedCategory(
    name: json['name'] as String,
    emoji: json['emoji'] as String,
    colorHex: json['colorHex'] as String,
  );

  final String name;
  final String emoji;
  final String colorHex;
}

/// Everything first launch inserts, read from `assets/seed/`.
class SeedData {
  const SeedData({required this.categories, required this.starters});

  final List<SeedCategory> categories;

  /// All templates; the Reminders screen offers every one as a chip.
  final List<Starter> starters;

  static Future<SeedData> load(AssetLoader loadAsset) async {
    List<Map<String, dynamic>> list(String s) =>
        (jsonDecode(s) as List<dynamic>).cast<Map<String, dynamic>>();
    return SeedData(
      categories: list(
        await loadAsset(defaultCategoriesAsset),
      ).map(SeedCategory.fromJson).toList(),
      starters: list(
        await loadAsset(startersAsset),
      ).map(Starter.fromJson).toList(),
    );
  }
}
