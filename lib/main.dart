import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zymm/features/onboarding/presentation/onboarding_screen.dart';
import 'package:zymm/utils/screen_dimensions.dart';
import 'features/auth/presentation/viewmodel/login_viewmodel.dart';
import 'features/home/presentation/viewmodel/greeting_viewmodel.dart';
import 'features/onboarding/presentation/viewmodel/onboarding_viewmodel.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenDimensions.init(context);
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => OnboardingViewModel()),
          ChangeNotifierProvider(create: (_) => LoginViewModel()),
          ChangeNotifierProvider(create: (_) => GreetingViewModel()),
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: OnboardingScreen(),
        )
    );
  }
}
