import 'package:flutter/material.dart';
import 'package:simplia_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:simplia_mobile/features/auth/presentation/screens/reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({required this.authController, super.key});
  final AuthController authController;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  String? _token;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _requestReset() async {
    final email = _emailController.text.trim();
    if (!email.contains('@')) return;
    final token = await widget.authController.requestPasswordReset(email);
    if (!mounted) return;
    setState(() => _token = token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Enter your email to request a password reset token.'),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email address'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: widget.authController.isLoading ? null : _requestReset,
              child: const Text('Request reset token'),
            ),
            if (_token case final token?) ...[
              const SizedBox(height: 24),
              const Text(
                'Development token (do not expose this in production):',
              ),
              SelectableText(token),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ResetPasswordScreen(
                      authController: widget.authController,
                      email: _emailController.text.trim(),
                      resetToken: token,
                    ),
                  ),
                ),
                child: const Text('Continue to reset password'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
