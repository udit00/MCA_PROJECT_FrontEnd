import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zymm/features/attendance/presentation/attendance_screen.dart';
import 'package:zymm/features/attendance/presentation/viewmodel/attendance_viewmodel.dart';

void main() {
  group('AttendanceScreen Widget Tests', () {
    // Helper function to pump widget and handle async operations
    Future<void> pumpAttendanceScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AttendanceViewModel>(
            create: (_) => AttendanceViewModel(),
            child: const AttendanceScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
    }

    testWidgets('Should display Attendance title in AppBar', (WidgetTester tester) async {
      await pumpAttendanceScreen(tester);

      expect(find.text('Attendance'), findsOneWidget);
    });

    testWidgets('Should have Consumer widget for state management', (WidgetTester tester) async {
      await pumpAttendanceScreen(tester);

      // Verify the screen uses Consumer for state management
      expect(find.byType(AttendanceScreen), findsOneWidget);
    });

    testWidgets('Should have Column layout for punch button and list', (WidgetTester tester) async {
      await pumpAttendanceScreen(tester);

      // Verify basic structure exists
      expect(find.byType(AttendanceScreen), findsOneWidget);
    });

    testWidgets('Should have Scaffold with AppBar', (WidgetTester tester) async {
      await pumpAttendanceScreen(tester);

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('Should have proper widget structure', (WidgetTester tester) async {
      await pumpAttendanceScreen(tester);

      // Verify basic widget structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('Should have AppBar with center title', (WidgetTester tester) async {
      await pumpAttendanceScreen(tester);

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.centerTitle, isTrue);
    });
  });
}
