/// Values a reminder message can reference.
class TemplateContext {
  const TemplateContext({
    required this.name,
    required this.title,
    required this.count,
    required this.goal,
    required this.unit,
    required this.category,
  });

  final String name;
  final String title;

  /// Times done today, including manual "+1"s.
  final int count;

  /// 0 = no goal (renders as empty).
  final int goal;
  final String unit;
  final String category;
}

final _token = RegExp(r'\{(\w+)\}');

/// Replaces `{name} {title} {count} {goal} {unit} {category}`. Unknown tokens
/// stay exactly as written, so a typo is visible rather than silently eaten.
String fillTemplate(String template, TemplateContext c) =>
    template.replaceAllMapped(_token, (m) {
      return switch (m.group(1)) {
            'name' => c.name,
            'title' => c.title,
            'count' => '${c.count}',
            'goal' => c.goal > 0 ? '${c.goal}' : '',
            'unit' => c.unit,
            'category' => c.category,
            _ => null,
          } ??
          m.group(0)!;
    });
