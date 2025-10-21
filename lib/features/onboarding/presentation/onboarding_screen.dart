import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zymm/core/storage/storage_service.dart';
import 'package:zymm/features/auth/presentation/registration_screen.dart';
import 'package:zymm/features/auth/presentation/widgets/loading_widget.dart';
import 'package:zymm/features/home/presentation/greeting_screen.dart';
import 'package:zymm/features/onboarding/presentation/viewmodel/onboarding_viewmodel.dart';

import '../../auth/presentation/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

  @override
  void initState() {
    super.initState();
    Provider.of<OnboardingViewModel>(context, listen: false).checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingViewModel>(
      builder: (context, onboardingVM, child) {
        // Navigate to HomeScreen if authenticated
        if (onboardingVM.state == AuthState.authenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            String? displayNameFromStorage = await StorageService.instance.getDisplayName();
            if(displayNameFromStorage?.isNotEmpty == true) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) =>
                    GreetingScreen(displayName: displayNameFromStorage!)),
                    (route) => false,
              );
            } else {
              onboardingVM.resetStateToNotAuthenticated();
            }
          });
        }

        switch(onboardingVM.state) {
          case AuthState.loading: return const LoadingWidget();
          case AuthState.authenticated: return const LoadingWidget();
            // WidgetsBinding.instance.addPostFrameCallback((_) {
            //   Navigator.pushReplacement(
            //     context,
            //     MaterialPageRoute(builder: (_) => const HomeScreen()),
            //   );
            // });
          case AuthState.unauthenticated:
              return Scaffold(
                body: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor.withValues(alpha: 0.8),
                        Theme.of(context).primaryColor,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Spacer(flex: 2),
                          // App Logo/Icon
                          Icon(
                            Icons.fitness_center,
                            size: 100,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 24),
                          // App Name
                          Text(
                            'ZYMM',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Tagline
                          Text(
                            'Your Fitness Journey Starts Here',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.9),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Spacer(flex: 3),
                          // Login Button
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Theme.of(context).primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 8,
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Register Button
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => RegistrationScreen())
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Colors.white, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(flex: 2),
                        ],
                      ),
                    ),
                  ),
                ),
              );
        }
      }
    );
  }

}

