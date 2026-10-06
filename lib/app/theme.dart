import 'package:flutter/material.dart';

/// The spec's design tokens (§7), available as `context.desk`.
@immutable
class DeskColors extends ThemeExtension<DeskColors> {
  const DeskColors({
    required this.bg,
    required this.panel,
    required this.panel2,
    required this.ink,
    required this.muted,
    required this.line,
    required this.accent,
    this.coral = const Color(0xFFE8473A),
    this.mint = const Color(0xFF1FA97F),
    this.sun = const Color(0xFFFFCB2E),
  });

  static const light = DeskColors(
    bg: Color(0xFFEAF1F6),
    panel: Color(0xFFFFFFFF),
    panel2: Color(0xFFF4F8FB),
    ink: Color(0xFF1C2733),
    muted: Color(0xFF5E6D7C),
    line: Color(0xFFD5E0E9),
    accent: Color(0xFF2F7DE1),
  );

  static const dark = DeskColors(
    bg: Color(0xFF121920),
    panel: Color(0xFF1B242E),
    panel2: Color(0xFF222D38),
    ink: Color(0xFFE7EEF4),
    muted: Color(0xFF93A3B3),
    line: Color(0xFF2E3B48),
    accent: Color(0xFF5A9CF0),
  );

  final Color bg;
  final Color panel;
  final Color panel2;
  final Color ink;
  final Color muted;
  final Color line;
  final Color accent;
  final Color coral;
  final Color mint;
  final Color sun;

  @override
  DeskColors copyWith({
    Color? bg,
    Color? panel,
    Color? panel2,
    Color? ink,
    Color? muted,
    Color? line,
    Color? accent,
    Color? coral,
    Color? mint,
    Color? sun,
  }) => DeskColors(
    bg: bg ?? this.bg,
    panel: panel ?? this.panel,
    panel2: panel2 ?? this.panel2,
    ink: ink ?? this.ink,
    muted: muted ?? this.muted,
    line: line ?? this.line,
    accent: accent ?? this.accent,
    coral: coral ?? this.coral,
    mint: mint ?? this.mint,
    sun: sun ?? this.sun,
  );

  @override
  DeskColors lerp(DeskColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return DeskColors(
      bg: l(bg, other.bg),
      panel: l(panel, other.panel),
      panel2: l(panel2, other.panel2),
      ink: l(ink, other.ink),
      muted: l(muted, other.muted),
      line: l(line, other.line),
      accent: l(accent, other.accent),
      coral: l(coral, other.coral),
      mint: l(mint, other.mint),
      sun: l(sun, other.sun),
    );
  }
}

extension DeskTheme on BuildContext {
  DeskColors get desk => Theme.of(this).extension<DeskColors>()!;
}

const displayFont = 'Baloo2';
const bodyFont = 'Figtree';

ThemeData deskTheme(Brightness brightness) {
  final c = brightness == Brightness.light ? DeskColors.light : DeskColors.dark;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: c.accent,
    onPrimary: Colors.white,
    secondary: c.mint,
    onSecondary: Colors.white,
    error: c.coral,
    onError: Colors.white,
    surface: c.panel,
    onSurface: c.ink,
    surfaceContainerLowest: c.bg,
    surfaceContainerLow: c.panel2,
    surfaceContainer: c.panel2,
    surfaceContainerHigh: c.panel2,
    surfaceContainerHighest: c.panel2,
    onSurfaceVariant: c.muted,
    outline: c.line,
    outlineVariant: c.line,
  );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: bodyFont,
    scaffoldBackgroundColor: c.bg,
    extensions: [c],
  );
  TextStyle display(double size, FontWeight w) => TextStyle(
    fontFamily: displayFont,
    fontSize: size,
    fontWeight: w,
    height: 1.1,
    color: c.ink,
  );
  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      displaySmall: display(40, FontWeight.w800),
      headlineSmall: display(22, FontWeight.w700),
      titleMedium: TextStyle(
        fontFamily: bodyFont,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: c.ink,
      ),
      bodyMedium: TextStyle(fontFamily: bodyFont, fontSize: 15, color: c.ink),
      bodySmall: TextStyle(fontFamily: bodyFont, fontSize: 13, color: c.muted),
      labelLarge: const TextStyle(
        fontFamily: bodyFont,
        fontWeight: FontWeight.w600,
      ),
    ),
    dividerTheme: DividerThemeData(color: c.line, space: 1, thickness: 1),
    cardTheme: CardThemeData(
      color: c.panel,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: c.line),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.panel2,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide(color: c.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide(color: c.line),
      ),
      labelStyle: TextStyle(
        fontFamily: bodyFont,
        color: c.muted,
        fontWeight: FontWeight.w600,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: c.ink,
        side: BorderSide(color: c.line),
        backgroundColor: c.panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: c.panel2,
      selectedColor: c.ink,
      side: BorderSide(color: c.line),
      shape: const StadiumBorder(),
      // Component text styles replace (not extend) the theme's, so each
      // one names the font family itself.
      labelStyle: TextStyle(
        fontFamily: bodyFont,
        color: c.ink,
        fontWeight: FontWeight.w600,
      ),
      secondaryLabelStyle: TextStyle(
        fontFamily: bodyFont,
        color: c.panel,
        fontWeight: FontWeight.w600,
      ),
      checkmarkColor: c.panel,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: c.panel,
      indicatorColor: c.ink,
      selectedIconTheme: IconThemeData(color: c.panel),
      selectedLabelTextStyle: TextStyle(
        fontFamily: bodyFont,
        color: c.ink,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelTextStyle: TextStyle(
        fontFamily: bodyFont,
        color: c.muted,
        fontWeight: FontWeight.w600,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: c.ink,
      contentTextStyle: TextStyle(
        fontFamily: bodyFont,
        color: c.panel,
        fontWeight: FontWeight.w600,
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
