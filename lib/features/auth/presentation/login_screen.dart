import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zymm/features/home/presentation/greeting_screen.dart';
import 'package:zymm/features/auth/presentation/viewmodel/login_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usernameController.text = '7011490531';
    _passwordController.text = 'password@123';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginViewModel>(
      builder: (context, loginVM, child) {
        if (loginVM.state == ViewState.success) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => GreetingScreen(
                  displayName: loginVM.loginResponse?.displayName ?? 'User',
                ),
              ),
            );
          });
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Login'),
          ),
          body: SafeArea(
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
                      onPressed: () {
                        loginVM.login(_usernameController.text, _passwordController.text);
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                  if (loginVM.state == ViewState.error)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        loginVM.errorMessage ?? 'An error occurred',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
          )
        );
      }
    );
  }
}
