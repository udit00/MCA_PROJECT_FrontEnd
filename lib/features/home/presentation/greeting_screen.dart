import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zymm/features/home/presentation/viewmodel/greeting_viewmodel.dart';
import 'package:zymm/features/home/presentation/home_screen.dart';

class GreetingScreen extends StatefulWidget {
  final String displayName;

  const GreetingScreen({super.key, required this.displayName});

  @override
  State<GreetingScreen> createState() => _GreetingScreenState();
}

class _GreetingScreenState extends State<GreetingScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<GreetingViewModel>(context, listen: false).fetchSelfData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GreetingViewModel>(
      builder: (context, greetingVM, child) {

        if (greetingVM.state == GreetingState.success) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await Future.delayed(const Duration(seconds: 2)); // 👈 Wait 2 seconds
            if (!mounted) return; // Safety check
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
            );
          });
        }

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Zymm'),

          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Welcome, ${widget.displayName}'),
                const SizedBox(height: 20),
                if (greetingVM.state != GreetingState.error) const CircularProgressIndicator(),
                if (greetingVM.state == GreetingState.error) ... [
                  Text(
                    greetingVM.errorMessage ?? 'An error occurred.',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    child: Text("Retry"),
                    onPressed: () {
                      greetingVM.fetchSelfData();
                    },
                  )
                ]
              ],
            ),
          ),
        );
      },
    );
  }
}
