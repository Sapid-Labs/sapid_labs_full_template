import 'package:auto_route/auto_route.dart';
import 'package:cotr_flutter_app/app/constants.dart';
import 'package:cotr_flutter_app/app/router.dart';
import 'package:cotr_flutter_app/app/services.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

@RoutePage()
class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> with SignalsMixin {
  final _formKey = GlobalKey<FormState>();
  late final email = createSignal('');
  late final password = createSignal('');
  late final confirmPassword = createSignal('');
  late final isLoading = createSignal(false);
  late final error = createSignal<String?>(null);
  late final showPassword = createSignal(false);
  
  Future<void> _handleEmailSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      error.value = null;
      
      await authService.signUpWithEmailAndPassword(
        email: email.value,
        password: password.value,
      );
      
      if (mounted) {
        // Navigate to home or intended screen after successful signup
        router.replaceAll([const HomeRoute()]);
      }
    } catch (e) {
      error.value = 'Failed to sign up: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleGoogleSignUp() async {
    try {
      isLoading.value = true;
      error.value = null;
      
      await authService.signInWithGoogle();
      
      if (mounted) {
        // Navigate to home or intended screen after successful signup
        router.replaceAll([const HomeRoute()]);
      }
    } catch (e) {
      error.value = 'Failed to sign up with Google: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => router.maybePop(),
        ),
      ),
      body: Watch((context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Join Us',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create an account to get started',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (error.value != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        error.value!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
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
                  gap16,
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
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
                      labelText: 'Confirm Password',
                      border: const OutlineInputBorder(),
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
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading.value ? null : _handleEmailSignUp,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create Account'),
                    ),
                  ),
                  gap16,
                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  gap16,
                  OutlinedButton(
                    onPressed: isLoading.value ? null : _handleGoogleSignUp,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/google_logo.png',
                            height: 24,
                            width: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text('Sign up with Google'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account?'),
                      TextButton(
                        onPressed: () => router.replace(const SignInRoute()),
                        child: const Text('Sign In'),
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