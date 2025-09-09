import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
	const LoginScreen({Key? key}) : super(key: key);

	@override
	State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
	final TextEditingController _usernameController = TextEditingController();
	final TextEditingController _passwordController = TextEditingController();
	final _formKey = GlobalKey<FormState>();

	@override
	void dispose() {
		_usernameController.dispose();
		_passwordController.dispose();
		super.dispose();
	}

	void _submit() {
		if (_formKey.currentState?.validate() ?? false) {
			// Handle login logic here
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(content: Text('Logging in...')),
			);
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Login'),
			),
			body: Center(
				child: Padding(
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
									validator: (value) =>
											value == null || value.isEmpty ? 'Enter username' : null,
								),
								const SizedBox(height: 16),
								TextFormField(
									controller: _passwordController,
									decoration: const InputDecoration(
										labelText: 'Password',
										border: OutlineInputBorder(),
									),
									obscureText: true,
									validator: (value) =>
											value == null || value.isEmpty ? 'Enter password' : null,
								),
								const SizedBox(height: 24),
								SizedBox(
									width: double.infinity,
									child: ElevatedButton(
										onPressed: _submit,
										child: const Text('Submit'),
									),
								),
							],
						),
					),
				),
			),
		);
	}
}
