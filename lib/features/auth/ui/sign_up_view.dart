import 'package:auto_route/auto_route.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:slapp/app/constants.dart';
import 'package:slapp/app/router.dart';
import 'package:slapp/app/services.dart';
import 'package:slapp/features/shared/ui/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:slapp/features/shared/ui/loading_stack.dart';
import 'package:signals/signals_flutter.dart';
import 'package:universal_io/io.dart';

@RoutePage()
class SignUpView extends StatefulWidget {
  const SignUpView({super.key, this.email});

  final String? email;

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> with SignalsMixin {
  final _formKey = GlobalKey<FormState>();
  late final email = createSignal(widget.email ?? '');
  late final password = createSignal('');
  late final confirmPassword = createSignal('');
  late final isLoading = createSignal(false);
  late final error = createSignal<String?>(null);
  late final showPassword = createSignal(false);

  Future<void> signUpWithEmail() async {
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
        router.replaceAll([const OnboardingRoute()]);
      }
    } catch (e) {
      error.value = 'Failed to sign up: ${e.toString()}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUpWithGoogle() async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleAppleSignIn() async {
    try {
      isLoading.value = true;
      error.value = null;

      bool newUser = await authService.signInWithApple();

      if (mounted) {
        if (newUser) {
          router.replaceAll([OnboardingRoute()]);
        } else {
          // Navigate to home or intended screen after successful login
          router.replaceAll([const HomeRoute()]);
        }
      } else {
        debugPrint('Not mounted');
      }
    } catch (e) {
      error.value = 'Failed to sign up with Apple: ${e.toString()}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUpAnonymously() async {
    debugPrint('Sign Up Anonymously');
    try {
      isLoading.value = true;
      error.value = null;

      await authService.signUpAnonymously();

      if (mounted) {
        // Navigate to home or intended screen after successful signup
        router.replaceAll([const HomeRoute()]);
      }
    } catch (e) {
      error.value = 'Failed to sign up anonymously: ${e.toString()}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingStack(
      isLoading: isLoading.value,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      gap48,
                      AppLogo(sideLength: 200),
                      gap24,
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
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        initialValue: email.value,
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
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              showPassword.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () =>
                                showPassword.value = !showPassword.value,
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
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              showPassword.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () =>
                                showPassword.value = !showPassword.value,
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
                      ElevatedButton(
                        onPressed: isLoading.value ? null : signUpWithEmail,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
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
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          if (isLoading.value) return;
                          await signUpAnonymously();
                        },
                        child: Text('Sign Up Anonymously'),
                      ),
                      if (Platform.isAndroid) ...[
                        gap8,
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                Theme.brightnessOf(context) == Brightness.light
                                    ? Colors.white
                                    : Colors.black,
                            foregroundColor:
                                Theme.brightnessOf(context) == Brightness.light
                                    ? Colors.black
                                    : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          icon: Image.asset('assets/images/google_logo.webp',
                              height: 24, width: 24),
                          label: const Text('Continue with Google'),
                          onPressed: () {
                            if (!isLoading.value) signUpWithGoogle();
                          },
                        ),
                      ],
                      if (Platform.isIOS) ...[
                        gap8,
                        SignInWithAppleButton(
                          style: SignInWithAppleButtonStyle.whiteOutlined,
                          height: 38,
                          borderRadius: BorderRadius.circular(24),
                          onPressed: () async {
                            if (!isLoading.value) _handleAppleSignIn();
                          },
                        ),
                      ],
                      gap24,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account?'),
                          TextButton(
                            onPressed: () =>
                                router.replace(const SignInRoute()),
                            child: const Text('Sign In'),
                          ),
                        ],
                      ),
                      gap48,
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
