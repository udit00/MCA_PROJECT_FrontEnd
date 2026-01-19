import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zymm/common/enums/user_role.dart';
import 'package:zymm/features/home/presentation/home_screen.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    // Helper function to pump widget and handle async operations
    Future<void> pumpHomeScreen(WidgetTester tester, UserRole role) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(userRole: role),
        ),
      );
      // Pump multiple times to allow widget tree to build
      // Don't use pumpAndSettle as it waits for all timers (API calls)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
    }

    testWidgets('Should display ZYMM title in AppBar', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.member);

      // Verify ZYMM title is displayed
      expect(find.text('ZYMM'), findsOneWidget);
    });

    testWidgets('Should display role badge for member', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.member);

      // Verify role badge displays "Member"
      expect(find.text('Member'), findsOneWidget);
    });

    testWidgets('Should display role badge for owner', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.owner);

      // Verify role badge displays "Owner"
      expect(find.text('Owner'), findsOneWidget);
    });

    testWidgets('Should display role badge for manager', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.manager);

      // Verify role badge displays "Manager"
      expect(find.text('Manager'), findsOneWidget);
    });

    testWidgets('Should display role badge for staff', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.staff);

      // Verify role badge displays "Staff"
      expect(find.text('Staff'), findsOneWidget);
    });

    testWidgets('Should display role badge for trainer', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.trainer);

      // Verify role badge displays "Trainer"
      expect(find.text('Trainer'), findsOneWidget);
    });

    testWidgets('Should display welcome message for member', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.member);

      // Verify member welcome message
      expect(find.text('Ready to workout?'), findsOneWidget);
      expect(find.text('Let\'s make today count!'), findsOneWidget);
    });

    testWidgets('Should display welcome message for owner', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.owner);

      // Verify owner welcome message
      expect(find.text('Business Dashboard'), findsOneWidget);
      expect(find.text('Manage your gym operations'), findsOneWidget);
    });

    testWidgets('Should display welcome message for manager', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.manager);

      // Verify manager welcome message
      expect(find.text('Management Panel'), findsOneWidget);
      expect(find.text('Oversee daily operations'), findsOneWidget);
    });

    testWidgets('Should display welcome message for staff', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.staff);

      // Verify staff welcome message
      expect(find.text('Staff Panel'), findsOneWidget);
      expect(find.text('Handle front desk tasks'), findsOneWidget);
    });

    testWidgets('Should display welcome message for trainer', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.trainer);

      // Verify trainer welcome message
      expect(find.text('Trainer Dashboard'), findsOneWidget);
      expect(find.text('Manage your clients'), findsOneWidget);
    });

    testWidgets('Should display Quick Actions section', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.member);

      // Verify Quick Actions section title
      expect(find.text('Quick Actions'), findsOneWidget);
    });

    testWidgets('Should display Attendance action for member', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.member);

      // Verify Attendance quick action is displayed for members
      expect(find.text('Attendance'), findsWidgets);
      expect(find.text('My attendance'), findsWidgets);
    });

    testWidgets('Should display Current Gym action for member', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.member);

      // Verify Current Gym quick action is displayed for members
      expect(find.text('Current Gym'), findsWidgets);
      expect(find.text('My gym details'), findsWidgets);
    });

    testWidgets('Should display Search Gyms action for member', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.member);

      // Verify Search Gyms quick action is displayed for members
      expect(find.text('Search Gyms'), findsWidgets);
      expect(find.text('Find nearby gyms'), findsWidgets);
    });

    testWidgets('Should display Chat with Trainer action for member', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.member);

      // Verify Chat with Trainer quick action is displayed for members
      expect(find.text('Chat with Trainer'), findsWidgets);
      expect(find.text('Messages'), findsWidgets);
    });

    testWidgets('Should display Manage Gym action for owner', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.owner);

      // Verify Manage Gym quick action is displayed for owners
      expect(find.text('Manage Gym'), findsWidgets);
      expect(find.text('Gym details & settings'), findsWidgets);
    });

    testWidgets('Should display Manage Employees action for owner', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.owner);

      // Verify Manage Employees quick action is displayed for owners
      expect(find.text('Manage Employees'), findsWidgets);
      expect(find.text('Staff & trainers'), findsWidgets);
    });

    testWidgets('Should display Membership Requests action for owner', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.owner);

      // Verify Membership Requests quick action is displayed for owners
      expect(find.text('Membership Requests'), findsWidgets);
      expect(find.text('Pending approvals'), findsWidgets);
    });

    testWidgets('Should display Manage Members action for owner', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.owner);

      // Verify Manage Members quick action is displayed for owners
      expect(find.text('Manage Members'), findsWidgets);
      expect(find.text('All members'), findsWidgets);
    });

    testWidgets('Should display Manage Plans action for owner', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.owner);

      // Verify Manage Plans quick action is displayed for owners
      expect(find.text('Manage Plans'), findsWidgets);
      expect(find.text('Membership plans'), findsWidgets);
    });

    testWidgets('Should display Pending Fees action for owner', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.owner);

      // Verify Pending Fees quick action is displayed for owners
      expect(find.text('Pending Fees'), findsWidgets);
      expect(find.text('Upcoming payments'), findsWidgets);
    });

    testWidgets('Should display Attendance action for trainer', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.trainer);

      // Verify Attendance quick action is displayed for trainers
      expect(find.text('Attendance'), findsWidgets);
      expect(find.text('My attendance'), findsWidgets);
    });

    testWidgets('Should display Check Members action for trainer', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.trainer);

      // Verify Check Members quick action is displayed for trainers
      expect(find.text('Check Members'), findsWidgets);
      expect(find.text('View members'), findsWidgets);
    });

    testWidgets('Should display Chat with Members action for trainer', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.trainer);

      // Verify Chat with Members quick action is displayed for trainers
      expect(find.text('Chat with Members'), findsWidgets);
      expect(find.text('Messages'), findsWidgets);
    });

    testWidgets('Should display notification icon in AppBar', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.member);

      // Verify notification icon is present
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('Should display profile icon in AppBar', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.member);

      // Verify profile icon is present
      expect(find.byIcon(Icons.person), findsWidgets);
    });

    testWidgets('Should have RefreshIndicator for pull to refresh', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.member);

      // Verify RefreshIndicator is present
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('Should display correct role icon for member', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.member);

      // Verify person icon is used for member role
      expect(find.byIcon(Icons.person), findsWidgets);
    });

    testWidgets('Should display correct role icon for owner', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.owner);

      // Verify business_center icon is used for owner role
      expect(find.byIcon(Icons.business_center), findsWidgets);
    });

    testWidgets('Should display correct role icon for manager', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.manager);

      // Verify admin_panel_settings icon is used for manager role
      expect(find.byIcon(Icons.admin_panel_settings), findsWidgets);
    });

    testWidgets('Should display correct role icon for staff', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.staff);

      // Verify badge icon is used for staff role
      expect(find.byIcon(Icons.badge), findsWidgets);
    });

    testWidgets('Should display correct role icon for trainer', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.trainer);

      // Verify fitness_center icon is used for trainer role
      expect(find.byIcon(Icons.fitness_center), findsWidgets);
    });

    testWidgets('Should have Scaffold with AppBar', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.member);

      // Verify Scaffold and AppBar are present
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('Should have SafeArea widget', (WidgetTester tester) async {
      await pumpHomeScreen(tester, UserRole.member);

      // Verify SafeArea is present (may be multiple due to MaterialApp)
      expect(find.byType(SafeArea), findsAtLeastNWidgets(1));
    });
  });
}
