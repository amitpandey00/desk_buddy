import 'package:desk_buddy/app/providers.dart';
import 'package:desk_buddy/app/theme.dart';
import 'package:desk_buddy/features/analytics/ui/analytics_page.dart';
import 'package:desk_buddy/features/character/ui/character_page.dart';
import 'package:desk_buddy/features/dashboard/ui/dashboard_page.dart';
import 'package:desk_buddy/features/reminders/ui/reminders_page.dart';
import 'package:desk_buddy/features/settings/domain/app_settings.dart';
import 'package:desk_buddy/features/settings/ui/settings_page.dart';
import 'package:desk_buddy/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_app.g.dart';

enum DashboardSection {
  dashboard('🏠', Strings.navDashboard),
  reminders('⏰', Strings.navReminders),
  character('🧑', Strings.navCharacter),
  analytics('📊', Strings.navAnalytics),
  settings('⚙️', Strings.navSettings);

  const DashboardSection(this.emoji, this.label);
  final String emoji;
  final String label;
}

@Riverpod(keepAlive: true)
class CurrentSection extends _$CurrentSection {
  @override
  DashboardSection build() => DashboardSection.dashboard;

  // Riverpod notifiers expose actions as methods, not setters.
  // ignore: use_setters_to_change_properties
  void go(DashboardSection section) => state = section;
}

class DashboardApp extends ConsumerWidget {
  const DashboardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pref =
        ref.watch(settingsProvider).value?.themeMode ?? ThemePreference.system;
    return MaterialApp(
      title: Strings.appName,
      debugShowCheckedModeBanner: false,
      theme: deskTheme(Brightness.light),
      darkTheme: deskTheme(Brightness.dark),
      themeMode: switch (pref) {
        ThemePreference.system => ThemeMode.system,
        ThemePreference.light => ThemeMode.light,
        ThemePreference.dark => ThemeMode.dark,
      },
      home: const DashboardShell(),
    );
  }
}

class DashboardShell extends ConsumerWidget {
  const DashboardShell({super.key});

  static Widget pageFor(DashboardSection s) => switch (s) {
    DashboardSection.dashboard => const DashboardPage(),
    DashboardSection.reminders => const RemindersPage(),
    DashboardSection.character => const CharacterPage(),
    DashboardSection.analytics => const AnalyticsPage(),
    DashboardSection.settings => const SettingsPage(),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch(currentSectionProvider);
    final page = Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 60),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: FocusTraversalGroup(child: pageFor(section)),
        ),
      ),
    );
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth >= 860;
          final rail = _Rail(current: section, vertical: wide);
          return wide
              ? Row(
                  children: [
                    rail,
                    Expanded(child: page),
                  ],
                )
              : Column(
                  children: [
                    rail,
                    Expanded(child: page),
                  ],
                );
        },
      ),
    );
  }
}

class _Rail extends ConsumerWidget {
  const _Rail({required this.current, required this.vertical});

  final DashboardSection current;
  final bool vertical;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.desk;
    final brand = Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, vertical ? 18 : 0),
      child: Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: '👋 ${Strings.brandA}'),
            TextSpan(
              text: Strings.brandB,
              style: TextStyle(color: c.accent),
            ),
          ],
        ),
        style: TextStyle(
          fontFamily: displayFont,
          fontWeight: FontWeight.w800,
          fontSize: vertical ? 26 : 22,
          color: c.ink,
        ),
      ),
    );
    final items = [
      for (final s in DashboardSection.values)
        _NavButton(
          section: s,
          selected: s == current,
          onTap: () => ref.read(currentSectionProvider.notifier).go(s),
        ),
    ];
    return Semantics(
      container: true,
      label: Strings.sections,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.panel,
          border: Border(
            right: vertical ? BorderSide(color: c.line) : BorderSide.none,
            bottom: vertical ? BorderSide.none : BorderSide(color: c.line),
          ),
        ),
        child: vertical
            ? SizedBox(
                width: 220,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 22, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      brand,
                      ...items,
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          Strings.railFoot,
                          style: TextStyle(color: c.muted, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(10),
                child: Row(children: [brand, ...items]),
              ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.section,
    required this.selected,
    required this.onTap,
  });

  final DashboardSection section;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    return Semantics(
      selected: selected,
      button: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4, right: 4),
        child: Material(
          color: selected ? c.ink : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                '${section.emoji}  ${section.label}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? c.panel : c.muted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
