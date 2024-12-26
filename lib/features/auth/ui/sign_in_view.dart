import 'package:auto_route/auto_route.dart';
import 'package:fools_app_template/app/constants.dart';
import 'package:fools_app_template/app/router.dart';
import 'package:fools_app_template/app/services.dart';
import 'package:fools_app_template/features/shared/ui/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:signals/signals_flutter.dart';

@RoutePage()
class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> with SignalsMixin {
  final _formKey = GlobalKey<FormState>();
  late final email = createSignal('');
  late final password = createSignal('');
  late final isLoading = createSignal(false);
  late final error = createSignal<String?>(null);

  Future<void> _handleEmailSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      error.value = null;

      await authService.loginWithEmailAndPassword(
        email: email.value,
        password: password.value,
      );

      if (mounted) {
        // Navigate to home or intended screen after successful login
        router.replaceAll([const HomeRoute()]);
      }
    } catch (e) {
      error.value = 'Failed to sign in: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      isLoading.value = true;
      error.value = null;

      await authService.signInWithGoogle();

      if (mounted) {
        // Navigate to home or intended screen after successful login
        router.replaceAll([const HomeRoute()]);
      }
    } catch (e) {
      error.value = 'Failed to sign in with Google: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Watch((context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppLogo(sideLength: 200),
                  gap24,
                  if (error.value != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        error.value!,
                        style:
                            TextStyle(color: Theme.of(context).colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
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
                  gap16,
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    enabled: !isLoading.value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    onChanged: (value) => password.value = value,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading.value ? null : _handleEmailSignIn,
                    child: isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Sign In'),
                  ),
                  gap16,
                  SignInButton(
                    Buttons.Google,
                    onPressed: () {
                      isLoading.value
                          ? null
                          : () async => await _handleGoogleSignIn();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
