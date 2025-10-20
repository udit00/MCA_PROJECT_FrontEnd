import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zymm/features/auth/presentation/widgets/loading_widget.dart';
import 'package:zymm/features/onboarding/presentation/viewmodel/onboarding_viewmodel.dart';

import '../../auth/presentation/login_screen.dart';
import '../../home/presentation/home_screen.dart';

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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
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
                body: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                              );
                            },
                            child: const Text("Login"),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to Registration
                            },
                            child: const Text("Register"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
        }
      }
    );
  }

}

