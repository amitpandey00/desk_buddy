import 'package:desk_buddy/app/providers.dart';
import 'package:desk_buddy/app/theme.dart';
import 'package:desk_buddy/core/db/providers.dart';
import 'package:desk_buddy/features/buddy/domain/buddy_look.dart';
import 'package:desk_buddy/features/buddy/movement/buddy_pose.dart';
import 'package:desk_buddy/features/buddy/render/props.dart';
import 'package:desk_buddy/features/buddy/ui/buddy_character.dart';
import 'package:desk_buddy/shared/strings.dart';
import 'package:desk_buddy/shared/widgets/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CharacterPage extends ConsumerWidget {
  const CharacterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final look = ref.watch(lookProvider).value ?? LookPresets.classic;
    // Saved straight away, applied to the *current* look (D22); the bus
    // tells the overlay (characterChanged).
    void change(BuddyLook Function(BuddyLook current) f) =>
        ref.read(settingsRepositoryProvider).updateLook(f);

    Widget chips<T>(
      String title,
      List<(T, String)> options,
      T current,
      BuddyLook Function(BuddyLook look, T value) apply,
    ) => _Group(
      title,
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final (value, label) in options)
            ChoiceChip(
              label: Text(label),
              selected: value == current,
              showCheckmark: false,
              labelStyle: TextStyle(
                fontFamily: bodyFont,
                fontWeight: FontWeight.w600,
                color: value == current ? context.desk.panel : context.desk.ink,
              ),
              onSelected: (_) => change((l) => apply(l, value)),
            ),
        ],
      ),
    );

    final colors = <(String, String, BuddyLook Function(BuddyLook, String))>[
      (Strings.colorSkin, look.skinHex, (l, h) => l.copyWith(skinHex: h)),
      (Strings.colorHair, look.hairHex, (l, h) => l.copyWith(hairHex: h)),
      (Strings.colorJacket, look.jacketHex, (l, h) => l.copyWith(jacketHex: h)),
      (Strings.colorShirt, look.shirtHex, (l, h) => l.copyWith(shirtHex: h)),
      (Strings.colorPants, look.pantsHex, (l, h) => l.copyWith(pantsHex: h)),
      (Strings.colorShoes, look.shoesHex, (l, h) => l.copyWith(shoesHex: h)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PageHeader(
          Strings.characterTitle,
          subtitle: Text(Strings.characterSubtitle),
        ),
        TwoColumns(
          left: _Stage(look: look),
          right: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Group(
                    Strings.startFromLook,
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final e in LookPresets.all.entries)
                          ActionChip(
                            label: Text(Strings.presetName(e.key)),
                            onPressed: () => change((_) => e.value),
                          ),
                      ],
                    ),
                  ),
                  _Group(
                    Strings.colors,
                    Wrap(
                      spacing: 18,
                      runSpacing: 12,
                      children: [
                        for (final (label, hex, apply) in colors)
                          SizedBox(
                            width: 120,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: context.desk.muted,
                                    ),
                                  ),
                                ),
                                ColorField(
                                  hex: hex,
                                  label: Strings.colorOf(label),
                                  onChanged: (h) => change((l) => apply(l, h)),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  chips<HairStyle>(
                    Strings.hair,
                    [
                      for (final h in HairStyle.values)
                        (h, Strings.hairName(h.name)),
                    ],
                    look.hairStyle,
                    (l, v) => l.copyWith(hairStyle: v),
                  ),
                  chips<HatStyle>(
                    Strings.hat,
                    [
                      for (final h in HatStyle.values)
                        (h, Strings.hatName(h.name)),
                    ],
                    look.hat,
                    (l, v) => l.copyWith(hat: v),
                  ),
                  chips<String>(
                    Strings.usuallyHolding,
                    [
                      for (final e in propRegistry.entries)
                        (e.key, e.value.label),
                    ],
                    look.defaultPropId,
                    (l, v) => l.copyWith(defaultPropId: v),
                  ),
                  chips<bool>(
                    Strings.spectacles,
                    const [(true, Strings.on), (false, Strings.off)],
                    look.spectacles,
                    (l, v) => l.copyWith(spectacles: v),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Stage extends StatelessWidget {
  const _Stage({required this.look});
  final BuddyLook look;

  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    final floor = Color.alphaBlend(c.accent.withValues(alpha: .14), c.panel2);
    return Semantics(
      label: Strings.previewLabel,
      image: true,
      child: Container(
        height: 360,
        alignment: Alignment.center,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.line),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [c.panel2, c.panel2, floor, floor],
            stops: const [0, .72, .72, 1],
          ),
        ),
        child: BuddyCharacter(
          look: look,
          state: BuddyState.idle,
          width: 170,
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group(this.title, this.child);
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        child,
      ],
    ),
  );
}
