import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:slapp/app/constants.dart';
import 'package:slapp/app/router.dart';
import 'package:slapp/app/services.dart';
import 'package:slapp/features/shared/ui/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:slapp/features/shared/ui/loading_stack.dart';
import 'package:signals/signals_flutter.dart';
import 'package:universal_io/io.dart' show Platform;

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      isLoading.value = true;
      error.value = null;

      debugPrint('Signing in with Google');
      bool newUser = await authService.signInWithGoogle();

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
    } on GoogleSignInException catch (e) {
      debugPrint('GoogleSignInException here: $e');
      error.value = e.description;

      if (e.code == GoogleSignInExceptionCode.canceled) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to sign in with Google: ${e.description}')),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: $e');
      error.value = e.message;

      if (e.code == 'auth/user-cancelled') {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in with Google: ${e.message}')),
      );
    } catch (e) {
      debugPrint('e: $e');
      error.value = e.toString();
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

      debugPrint('Signing in with Apple');
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
      debugPrint('e: $e');
      error.value = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      return LoadingStack(
        isLoading: isLoading.value,
        child: Scaffold(
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
                      gap48,
                      AppLogo(sideLength: 200),
                      gap24,
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
                      Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                              onPressed: () {
                                router.push(ResetPasswordRoute());
                              },
                              child: Text("Forgot Password?"))),
                      gap24,
                      ElevatedButton(
                        onPressed: isLoading.value ? null : _handleEmailSignIn,
                        child: isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Sign In'),
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
                          label: const Text('Sign In with Google'),
                          onPressed: () {
                            if (!isLoading.value) _handleGoogleSignIn();
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
                          const Text('Don\'t have an account?'),
                          TextButton(
                            onPressed: () =>
                                router.push(SignUpRoute(email: email.value)),
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
        ),
      );
    });
  }
}
