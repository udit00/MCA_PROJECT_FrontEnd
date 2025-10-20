import 'package:flutter/material.dart';
import 'package:zymm/features/home/presentation/greeting_screen.dart';
import 'package:zymm/features/auth/presentation/viewmodel/login_viewmodel.dart';
import 'package:zymm/features/auth/presentation/widgets/loading_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _viewModel = LoginViewModel();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_handleStateChange);
    _usernameController.text = '7011490531';
    _passwordController.text = 'password@123';
  }

  @override
  void dispose() {
    _viewModel.removeListener(_handleStateChange);
    _viewModel.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleStateChange() {
    if (_viewModel.state == ViewState.success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => GreetingScreen(
            displayName: _viewModel.loginResponse?.displayName ?? 'User',
          ),
        ),
      );
    } else {
      // Rebuild the widget to show loading or error states
      setState(() {});
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _viewModel.login(_usernameController.text, _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_viewModel.state == ViewState.loading) {
      return const LoadingWidget();
    }
    return _buildLoginForm();
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Enter username' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) => value == null || value.isEmpty ? 'Enter password' : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Submit'),
              ),
            ),
            if (_viewModel.state == ViewState.error)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _viewModel.errorMessage ?? 'An error occurred',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
