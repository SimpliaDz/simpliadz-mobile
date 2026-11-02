import 'package:flutter/material.dart';
import 'package:simpliadz_mobile/features/auth/presentation/controllers/auth_controller.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    required this.authController,
    required this.email,
    required this.resetToken,
    super.key,
  });
  final AuthController authController;
  final String email;
  final String resetToken;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    if (_passwordController.text.length < 6) return;
    final succeeded = await widget.authController.resetPassword(
      widget.email,
      widget.resetToken,
      _passwordController.text,
    );
    if (!mounted || !succeeded) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset. You can sign in now.')),
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose a new password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Resetting the password for ${widget.email}'),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New password'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _reset,
              child: const Text('Reset password'),
            ),
          ],
        ),
      ),
    );
  }
}
