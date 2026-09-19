import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_notes_app/ui/widgets/animated_fab.dart';

void main() {
  Widget createTestFab({
    required VoidCallback onPressed,
    bool isVisible = true,
  }) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: AnimatedFab(
          isVisible: isVisible,
          onPressed: onPressed,
        ),
      ),
    );
  }

  group('AnimatedFab Widget Tests', () {
    testWidgets('renders FloatingActionButton with add icon and correct styling', (tester) async {
      await tester.pumpWidget(createTestFab(onPressed: () {}));

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      final slide = tester.widget<AnimatedSlide>(find.byType(AnimatedSlide));
      expect(slide.offset, Offset.zero);

      final opacity = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
      expect(opacity.opacity, 1.0);
    });

    testWidgets('slides down and fades out when isVisible is false', (tester) async {
      await tester.pumpWidget(createTestFab(onPressed: () {}, isVisible: false));

      final slide = tester.widget<AnimatedSlide>(find.byType(AnimatedSlide));
      expect(slide.offset, const Offset(0, 2));

      final opacity = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
      expect(opacity.opacity, 0.0);
    });

    testWidgets('triggers rotation animation and executes onPressed callback on tap', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(createTestFab(onPressed: () => pressed = true));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(pressed, isTrue);
    });
  });
}
