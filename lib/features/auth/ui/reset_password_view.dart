import 'package:auto_route/auto_route.dart';
import 'package:cotr_flutter_app/app/constants.dart';
import 'package:cotr_flutter_app/app/router.dart';
import 'package:cotr_flutter_app/app/services.dart';
import 'package:cotr_flutter_app/features/shared/utils/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

@RoutePage()
class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView>
    with SignalsMixin {
  final _formKey = GlobalKey<FormState>();
  late final email = createSignal('');
  late final isLoading = createSignal(false);
  late final error = createSignal<String?>(null);
  late final isSuccess = createSignal(false);

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      error.value = null;

      // TODO: Add reset password method to AuthService
      // await authService.resetPassword(email: email.value);

      isSuccess.value = true;
    } catch (e) {
      error.value = 'Failed to send reset email: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => router.maybePop(),
        ),
      ),
      body: Watch((context) {
        if (isSuccess.value) {
          return Center(
            child: Padding(
              padding: padding16,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.mark_email_read,
                    size: 64,
                    color: Colors.green,
                  ),
                  gap24,
                  Text(
                    'Reset Link Sent',
                    style: context.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  gap16,
                  Text(
                    'We\'ve sent a password reset link to ${email.value}',
                    style: context.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  gap32,
                  FilledButton(
                    onPressed: () => router.replace(const SignInRoute()),
                    child: const Text('Return to Sign In'),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: padding16,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                gap32,
                Text(
                  'Forgot Your Password?',
                  style: context.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                gap16,
                Text(
                  'Enter your email address and we\'ll send you a link to reset your password.',
                  style: context.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                gap32,
                if (error.value != null) ...[
                  Text(
                    error.value!,
                    style: context.bodyMedium.error,
                    textAlign: TextAlign.center,
                  ),
                  gap16,
                ],
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !isLoading.value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  onChanged: (value) => email.value = value,
                ),
                gap24,
                FilledButton(
                  onPressed: isLoading.value ? null : _handleResetPassword,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Send Reset Link'),
                  ),
                ),
                gap24,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Remember your password?'),
                    TextButton(
                      onPressed: () => router.replace(const SignInRoute()),
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
