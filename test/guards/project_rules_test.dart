import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Enforces the project rules from CLAUDE.md on every `flutter test`.
void main() {
  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.endsWith('.g.dart'))
      .where((f) => !f.path.endsWith('.freezed.dart'))
      .toList();

  String rel(File f) => f.path.replaceAll(r'\', '/');

  List<String> offenders(RegExp pattern, {bool Function(String)? skip}) => [
    for (final f in files)
      if (!(skip?.call(rel(f)) ?? false))
        for (final (i, line) in f.readAsLinesSync().indexed)
          // `// guard-ok: <reason>` marks a reviewed exception on that line.
          if (pattern.hasMatch(line) && !line.contains('// guard-ok:'))
            '${rel(f)}:${i + 1}: ${line.trim()}',
  ];

  test('no reminder-specific words in lib/ (seed data lives in assets)', () {
    expect(
      offenders(
        RegExp(r'\b(water|drinks?|glass(es)?|sips?)\b', caseSensitive: false),
      ),
      isEmpty,
    );
  });

  test('no DateTime.now() outside the clock provider', () {
    expect(
      offenders(
        RegExp(r'DateTime\.now\('),
        skip: (p) => p.startsWith('lib/core/clock/'),
      ),
      isEmpty,
    );
  });

  test('pure-Dart engines do not import Flutter', () {
    bool isPure(String p) =>
        p.startsWith('lib/features/scheduler/engine/') ||
        p.startsWith('lib/features/buddy/movement/') ||
        p.startsWith('lib/shared/template/');
    expect(
      offenders(
        RegExp(r'''import\s+['"](package:flutter/|dart:ui)'''),
        skip: (p) => !isPure(p),
      ),
      isEmpty,
    );
  });
}
