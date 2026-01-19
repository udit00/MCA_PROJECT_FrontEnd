import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zymm/features/onboarding/presentation/onboarding_screen.dart';
import 'package:zymm/features/onboarding/presentation/viewmodel/onboarding_viewmodel.dart';

void main() {
  group('OnboardingScreen Widget Tests', () {
    testWidgets('Should display ZYMM app name and tagline when unauthenticated', (WidgetTester tester) async {
      // Create a mock viewmodel with unauthenticated state
      final viewModel = OnboardingViewModel();
      viewModel.resetStateToNotAuthenticated();

      // Build the widget wrapped with Provider
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<OnboardingViewModel>.value(
            value: viewModel,
            child: const OnboardingScreen(),
          ),
        ),
      );

      // Wait for the widget to build and handle any async operations
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify that the app name is displayed
      expect(find.text('ZYMM'), findsOneWidget);

      // Verify that the tagline is displayed
      expect(find.text('Your Fitness Journey Starts Here'), findsOneWidget);

      // Verify that Login button is displayed
      expect(find.text('Login'), findsOneWidget);

      // Verify that Register button is displayed
      expect(find.text('Register'), findsOneWidget);

      // Verify that the fitness center icon is displayed
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
    });

    testWidgets('Should display loading widget when in loading state', (WidgetTester tester) async {
      // Create a mock viewmodel with loading state
      final viewModel = OnboardingViewModel();

      // Build the widget wrapped with Provider
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<OnboardingViewModel>.value(
            value: viewModel,
            child: const OnboardingScreen(),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pump();

      // The loading state should show LoadingWidget (CircularProgressIndicator)
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Login button should be tappable', (WidgetTester tester) async {
      // Create a mock viewmodel with unauthenticated state
      final viewModel = OnboardingViewModel();
      viewModel.resetStateToNotAuthenticated();

      // Build the widget wrapped with Provider
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<OnboardingViewModel>.value(
            value: viewModel,
            child: const OnboardingScreen(),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pump();
      await tester.pumpAndSettle();

      // Find and tap the Login button
      final loginButton = find.text('Login');
      expect(loginButton, findsOneWidget);
      
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // After tapping, navigation should occur (button may disappear)
      // We verify the button was found and tappable
      expect(find.byType(OnboardingScreen), findsNothing);
    });

    testWidgets('Register button should be tappable', (WidgetTester tester) async {
      // Create a mock viewmodel with unauthenticated state
      final viewModel = OnboardingViewModel();
      viewModel.resetStateToNotAuthenticated();

      // Build the widget wrapped with Provider
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<OnboardingViewModel>.value(
            value: viewModel,
            child: const OnboardingScreen(),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pump();
      await tester.pumpAndSettle();

      // Find and tap the Register button
      final registerButton = find.text('Register');
      expect(registerButton, findsOneWidget);
      
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      // After tapping, navigation should occur (button may disappear)
      // We verify the button was found and tappable
      expect(find.byType(OnboardingScreen), findsNothing);
    });
  });
}
