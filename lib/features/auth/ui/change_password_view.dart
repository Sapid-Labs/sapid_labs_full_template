import 'package:auto_route/auto_route.dart';
import 'package:sapid_labs/app/constants.dart';
import 'package:sapid_labs/app/router.dart';
import 'package:sapid_labs/app/services.dart';
import 'package:sapid_labs/features/shared/utils/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

@RoutePage()
class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> with SignalsMixin {
  final _formKey = GlobalKey<FormState>();
  late final password = createSignal('');
  late final confirmPassword = createSignal('');
  late final isLoading = createSignal(false);
  late final error = createSignal<String?>(null);
  late final showPassword = createSignal(false);
  late final isSuccess = createSignal(false);

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      error.value = null;
      
      // Add updatePassword to AuthService
      await authService.updatePassword(password: password.value);
      
      isSuccess.value = true;
    } catch (e) {
      error.value = 'Failed to update password: ${e.toString()}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
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
                    Icons.check_circle,
                    size: 64,
                    color: Colors.green,
                  ),
                  gap24,
                  Text(
                    'Password Updated',
                    style: context.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  gap16,
                  Text(
                    'Your password has been successfully updated.',
                    style: context.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  gap32,
                  FilledButton(
                    onPressed: () => router.replace(const SignInRoute()),
                    child: const Text('Continue to Sign In'),
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
                  'Set New Password',
                  style: context.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                gap16,
                Text(
                  'Please enter your new password below.',
                  style: context.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                gap32,
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPassword.value 
                          ? Icons.visibility_off 
                          : Icons.visibility,
                      ),
                      onPressed: () => showPassword.value = !showPassword.value,
                    ),
                  ),
                  obscureText: !showPassword.value,
                  enabled: !isLoading.value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  onChanged: (value) => password.value = value,
                ),
                gap16,
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPassword.value 
                          ? Icons.visibility_off 
                          : Icons.visibility,
                      ),
                      onPressed: () => showPassword.value = !showPassword.value,
                    ),
                  ),
                  obscureText: !showPassword.value,
                  enabled: !isLoading.value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != password.value) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  onChanged: (value) => confirmPassword.value = value,
                ),
                gap24,
                FilledButton(
                  onPressed: isLoading.value ? null : _handleChangePassword,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Update Password'),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}