import 'package:desk_buddy/features/buddy/domain/buddy_look.dart';
import 'package:desk_buddy/features/buddy/movement/buddy_pose.dart';
import 'package:desk_buddy/features/buddy/render/buddy_painter.dart';
import 'package:desk_buddy/features/buddy/render/props.dart';
import 'package:desk_buddy/features/buddy/ui/buddy_bubble.dart';
import 'package:desk_buddy/shared/strings.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Goldens are rendered on Windows; regenerate with
/// `flutter test --update-goldens test/features/buddy/buddy_golden_test.dart`.
void main() {
  Widget buddy(
    BuddyLook look,
    BuddyPose pose, {
    String? prop,
    bool flip = false,
  }) => CustomPaint(
    size: const Size(120, 222),
    painter: BuddyPainter(
      palette: BuddyPalette.of(look),
      look: look,
      prop: resolveProp(prop, look.defaultPropId),
      pose: ValueNotifier(pose),
      flip: flip,
    ),
  );

  Widget sheet(List<Widget> cells) => Directionality(
    textDirection: TextDirection.ltr,
    child: ColoredBox(
      color: const Color(0xFFEAF1F6),
      child: Align(
        alignment: Alignment.topLeft,
        child: Wrap(
          children: [
            for (final c in cells)
              Padding(padding: const EdgeInsets.all(8), child: c),
          ],
        ),
      ),
    ),
  );

  final poses = {
    'rest': BuddyPose.rest,
    // 0.1 s: legs ~13° apart and mid-bob (0.25 s would be mid-swing, 0°).
    'walk': poseAt(BuddyState.walking, .1),
    'alert': poseAt(BuddyState.alert, .27),
    'blink': poseAt(BuddyState.idle, 4.5 * .96),
  };

  testWidgets('looks × poses', (tester) async {
    tester.view
      ..physicalSize = const Size(4 * 136.0, 4 * 238.0)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      sheet([
        for (final look in LookPresets.all.values)
          for (final pose in poses.values) buddy(look, pose),
      ]),
    );
    await expectLater(
      find.byType(Wrap),
      matchesGoldenFile('goldens/looks_x_poses.png'),
    );
  });

  testWidgets('every prop, plus flipped', (tester) async {
    final props = propRegistry.keys.toList();
    tester.view
      ..physicalSize = Size((props.length + 1) * 136.0, 238)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      sheet([
        for (final p in props)
          buddy(LookPresets.classic, poses['rest']!, prop: p),
        buddy(LookPresets.classic, poses['walk']!, prop: 'bottle', flip: true),
      ]),
    );
    await expectLater(
      find.byType(Wrap),
      matchesGoldenFile('goldens/props.png'),
    );
  });

  testWidgets('bubbles', (tester) async {
    tester.view
      ..physicalSize = const Size(700, 260)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ColoredBox(
          color: const Color(0xFF7A8A99),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: BuddyBubble(
                  message: 'Hey, Sam! Time to stretch?',
                  progress: Strings.goalProgress(3, 6, 'stretches'),
                  actions: [
                    BubbleAction('Done', () {}, primary: true),
                    BubbleAction(Strings.remindLater(10), () {}),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(12),
                child: BuddyBubble(
                  message: Strings.peekNothing,
                  compact: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await expectLater(
      find.byType(Row),
      matchesGoldenFile('goldens/bubbles.png'),
    );
  });
}
