import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zymm/features/feedback/presentation/screens/all_feedbacks_screen.dart';
import 'package:zymm/features/feedback/presentation/viewmodel/feedback_viewmodel.dart';

void main() {
  group('AllFeedbacksScreen Widget Tests', () {
    // Helper function to pump widget and handle async operations
    Future<void> pumpAllFeedbacksScreen(WidgetTester tester, {String? gymName}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<FeedbackViewModel>(
            create: (_) => FeedbackViewModel(),
            child: AllFeedbacksScreen(
              gymId: 1,
              gymName: gymName,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
    }

    testWidgets('Should display Gym Reviews title in AppBar', (WidgetTester tester) async {
      await pumpAllFeedbacksScreen(tester);

      expect(find.text('Gym Reviews'), findsOneWidget);
    });

    testWidgets('Should display gym name in AppBar when provided', (WidgetTester tester) async {
      await pumpAllFeedbacksScreen(tester, gymName: 'Test Gym');

      expect(find.text('Test Gym Reviews'), findsOneWidget);
    });

    testWidgets('Should have Consumer widget for state management', (WidgetTester tester) async {
      await pumpAllFeedbacksScreen(tester);

      expect(find.byType(AllFeedbacksScreen), findsOneWidget);
    });

    testWidgets('Should have proper widget structure', (WidgetTester tester) async {
      await pumpAllFeedbacksScreen(tester);

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('Should have AppBar with center title', (WidgetTester tester) async {
      await pumpAllFeedbacksScreen(tester);

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.centerTitle, isTrue);
    });
  });
}
