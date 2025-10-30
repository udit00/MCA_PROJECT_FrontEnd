import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zymm/features/home/presentation/home_screen.dart';
import 'package:zymm/features/onboarding/presentation/onboarding_screen.dart';
import 'package:zymm/utils/app_info.dart';
import 'package:zymm/utils/screen_dimensions.dart';
import 'features/onboarding/presentation/viewmodel/onboarding_viewmodel.dart';


void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenDimensions.init(context);
    AppInfo().init();
    return ChangeNotifierProvider(
      create: (_) => OnboardingViewModel(),
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        navigatorObservers: [homeScreenRouteObserver],
        home: const OnboardingScreen(),
      ),
    );
  }
}
