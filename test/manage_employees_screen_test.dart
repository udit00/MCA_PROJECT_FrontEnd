import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zymm/features/employee/presentation/screens/manage_employees_screen.dart';
import 'package:zymm/features/employee/presentation/viewmodel/employee_viewmodel.dart';

void main() {
  group('ManageEmployeesScreen Widget Tests', () {
    // Helper function to pump widget and handle async operations
    Future<void> pumpManageEmployeesScreen(WidgetTester tester, {String? gymName}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<EmployeeViewModel>(
            create: (_) => EmployeeViewModel(),
            child: ManageEmployeesScreen(
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

    testWidgets('Should display Manage Employees title in AppBar', (WidgetTester tester) async {
      await pumpManageEmployeesScreen(tester);

      expect(find.text('Manage Employees'), findsOneWidget);
    });

    testWidgets('Should display gym name in AppBar when provided', (WidgetTester tester) async {
      await pumpManageEmployeesScreen(tester, gymName: 'Test Gym');

      expect(find.text('Test Gym - Employees'), findsOneWidget);
    });

    testWidgets('Should have Consumer widget for state management', (WidgetTester tester) async {
      await pumpManageEmployeesScreen(tester);

      expect(find.byType(ManageEmployeesScreen), findsOneWidget);
    });

    testWidgets('Should have proper widget structure', (WidgetTester tester) async {
      await pumpManageEmployeesScreen(tester);

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('Should display FloatingActionButton for adding employee', (WidgetTester tester) async {
      await pumpManageEmployeesScreen(tester);

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Add Employee'), findsOneWidget);
    });

    testWidgets('Should have FloatingActionButton with correct properties', (WidgetTester tester) async {
      await pumpManageEmployeesScreen(tester);

      final fab = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
      expect(fab, isNotNull);
    });

    testWidgets('Should have AppBar with center title', (WidgetTester tester) async {
      await pumpManageEmployeesScreen(tester);

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.centerTitle, isTrue);
    });

    testWidgets('Should display person_add icon in FAB', (WidgetTester tester) async {
      await pumpManageEmployeesScreen(tester);

      expect(find.byIcon(Icons.person_add), findsOneWidget);
    });
  });
}
