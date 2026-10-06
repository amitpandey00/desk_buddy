import 'package:desk_buddy/features/buddy/domain/buddy_look.dart';
import 'package:desk_buddy/features/buddy/movement/buddy_pose.dart';
import 'package:desk_buddy/features/buddy/render/buddy_painter.dart';
import 'package:desk_buddy/features/buddy/ui/buddy_bubble.dart';
import 'package:desk_buddy/features/buddy/ui/buddy_view.dart';
import 'package:desk_buddy/shared/strings.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => WidgetsApp(
  color: const Color(0xFFFFFFFF),
  builder: (_, _) => FocusScope(
    autofocus: true,
    child: Center(child: child),
  ),
);

BuddyPose _pose(WidgetTester tester) {
  final paint = tester.widget<CustomPaint>(
    find.descendant(
      of: find.byType(BuddyView),
      matching: find.byType(CustomPaint),
    ),
  );
  return (paint.painter! as BuddyPainter).pose.value;
}

void main() {
  group('BuddyView', () {
    testWidgets('sizes to the 120:222 ratio', (tester) async {
      await tester.pumpWidget(
        _host(
          const BuddyView(
            look: LookPresets.classic,
            state: BuddyState.idle,
            width: 60,
          ),
        ),
      );
      expect(tester.getSize(find.byType(BuddyView)), const Size(60, 111));
    });

    testWidgets('walking animates every frame', (tester) async {
      await tester.pumpWidget(
        _host(
          const BuddyView(look: LookPresets.classic, state: BuddyState.walking),
        ),
      );
      // Real elapsed time drives the pose, so wait on the wall clock.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 120)),
      );
      await tester.pump(const Duration(milliseconds: 16));
      final a = _pose(tester).legFront;
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 120)),
      );
      await tester.pump(const Duration(milliseconds: 16));
      expect(_pose(tester).legFront, isNot(a));
    });

    testWidgets('reduce motion: static pose, no frames scheduled', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const BuddyView(
            look: LookPresets.classic,
            state: BuddyState.walking,
            reduceMotion: true,
          ),
        ),
      );
      await tester.pump(); // the focus scope's autofocus frame
      expect(_pose(tester).legFront, 0);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('reads reduce motion from MediaQuery', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: _host(
            const BuddyView(look: LookPresets.classic, state: BuddyState.alert),
          ),
        ),
      );
      expect(_pose(tester).bodyDy, 0);
      expect(_pose(tester).armBack, isNot(0));
    });

    testWidgets('idle does not run a per-frame ticker', (tester) async {
      await tester.pumpWidget(
        _host(
          const BuddyView(look: LookPresets.classic, state: BuddyState.idle),
        ),
      );
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isFalse);
      // …but the 15 fps timer still updates the pose (breathing, blink).
      final before = _pose(tester);
      await tester.pump(const Duration(milliseconds: 70));
      expect(identical(_pose(tester), before), isFalse);
      // Let the periodic timer be cancelled on teardown.
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('is labelled for screen readers', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          const BuddyView(
            look: LookPresets.classic,
            state: BuddyState.idle,
            reduceMotion: true,
          ),
        ),
      );
      expect(find.bySemanticsLabel(Strings.buddyLabel), findsOneWidget);
      semantics.dispose();
    });
  });

  group('BuddyBubble', () {
    testWidgets('shows message, goal pill and actions', (tester) async {
      var done = 0;
      var later = 0;
      await tester.pumpWidget(
        _host(
          BuddyBubble(
            emoji: '⏰',
            message: 'Time to stretch',
            progress: Strings.goalProgress(2, 6, 'stretches'),
            actions: [
              BubbleAction('Done', () => done++, primary: true),
              BubbleAction(Strings.remindLater(10), () => later++),
            ],
          ),
        ),
      );
      expect(find.textContaining('Time to stretch'), findsNWidgets(2));
      expect(find.text('2 / 6 stretches today'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.tap(find.text('Remind me in 10 min'));
      expect((done, later), (1, 1));
    });

    testWidgets('primary button has focus; Tab reaches the rest', (
      tester,
    ) async {
      var done = 0;
      var later = 0;
      await tester.pumpWidget(
        _host(
          BuddyBubble(
            message: 'Hi',
            actions: [
              BubbleAction('Done', () => done++, primary: true),
              BubbleAction('Later', () => later++),
            ],
          ),
        ),
      );
      await tester.pump();
      // The primary button is focused on show; Tab reaches the next one.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect((done, later), (1, 1));
    });

    testWidgets('compact peek has no buttons', (tester) async {
      await tester.pumpWidget(
        _host(const BuddyBubble(message: Strings.peekNothing, compact: true)),
      );
      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets('PopIn springs from 0.6 to 1', (tester) async {
      await tester.pumpWidget(_host(const PopIn(child: SizedBox(width: 10))));
      ScaleTransition scale() => tester.widget(find.byType(ScaleTransition));
      expect(scale().scale.value, closeTo(.6, 1e-9));
      await tester.pump(const Duration(milliseconds: 150));
      expect(scale().scale.value, greaterThan(1)); // overshoot
      await tester.pumpAndSettle();
      expect(scale().scale.value, 1);
    });
  });
}
