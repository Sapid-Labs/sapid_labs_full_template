import 'package:auto_route/auto_route.dart';
import 'package:foolscript/app/constants.dart';
import 'package:foolscript/app/router.dart';
import 'package:foolscript/app/services.dart';
import 'package:foolscript/features/shared/ui/app_logo.dart';
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

  // https://dartsignals.dev/core/signal/#flutter
  late final email = createSignal('');
  late final password = createSignal('');
  late final isLoading = createSignal(false);
  late final error = createSignal<String?>(null);

  Future<void> _handleEmailSignIn() async {
    debugPrint('Sign In');
    if (!_formKey.currentState!.validate()) return;

    debugPrint('email: ${email.value}');
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
      } else {
        debugPrint('Not mounted');
      }
    } catch (e) {
      debugPrint('e: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      isLoading.value = true;
      error.value = null;

      debugPrint('Signing in with Google');
      await authService.signInWithGoogle();

      if (mounted) {
        // Navigate to home or intended screen after successful login
        router.replaceAll([const HomeRoute()]);
      } else {
        debugPrint('Not mounted');
      }
    } catch (e) {
      debugPrint('e: $e');
      error.value = e.toString();
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
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Email',
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
                  SignInButton(Buttons.Google, onPressed: () {
                    if (!isLoading.value) _handleGoogleSignIn();
                  }),
                  gap16,
                  gap24,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Don\'t have an account?'),
                      TextButton(
                        onPressed: () => router.replace(const SignUpRoute()),
                        child: const Text('Sign Up'),
                      ),
                    ],
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
