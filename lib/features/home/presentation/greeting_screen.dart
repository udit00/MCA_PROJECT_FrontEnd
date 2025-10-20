import 'package:flutter/material.dart';
import 'package:zymm/features/home/presentation/viewmodel/greeting_viewmodel.dart';
import 'package:zymm/features/home/presentation/home_screen.dart';

class GreetingScreen extends StatefulWidget {
  final String displayName;

  const GreetingScreen({Key? key, required this.displayName}) : super(key: key);

  @override
  State<GreetingScreen> createState() => _GreetingScreenState();
}

class _GreetingScreenState extends State<GreetingScreen> {
  final _viewModel = GreetingViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_handleStateChange);
    _viewModel.fetchSelfData();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_handleStateChange);
    _viewModel.dispose();
    super.dispose();
  }

  void _handleStateChange() {
    if (_viewModel.state == GreetingState.success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
    // Rebuild the widget to show loading or error states
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${widget.displayName}'),
            const SizedBox(height: 20),
            if (_viewModel.state == GreetingState.loading)
              const CircularProgressIndicator(),
            if (_viewModel.state == GreetingState.error)
              Text(
                _viewModel.errorMessage ?? 'An error occurred.',
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
