import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zymm/features/member/presentation/screens/manage_members_screen.dart';
import 'package:zymm/features/member/presentation/viewmodel/member_viewmodel.dart';

void main() {
  group('ManageMembersScreen Widget Tests', () {
    // Helper function to pump widget and handle async operations
    Future<void> pumpManageMembersScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<MemberViewModel>(
            create: (_) => MemberViewModel(),
            child: const ManageMembersScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
    }

    testWidgets('Should display Manage Members title in AppBar', (WidgetTester tester) async {
      await pumpManageMembersScreen(tester);

      expect(find.text('Manage Members'), findsOneWidget);
    });

    testWidgets('Should have Consumer widget for state management', (WidgetTester tester) async {
      await pumpManageMembersScreen(tester);

      expect(find.byType(ManageMembersScreen), findsOneWidget);
    });

    testWidgets('Should have proper widget structure', (WidgetTester tester) async {
      await pumpManageMembersScreen(tester);

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });


    testWidgets('Should have AppBar with center title', (WidgetTester tester) async {
      await pumpManageMembersScreen(tester);

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.centerTitle, isTrue);
    });


    testWidgets('Should have AppBar with elevation', (WidgetTester tester) async {
      await pumpManageMembersScreen(tester);

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.elevation, 2);
    });
  });
}
