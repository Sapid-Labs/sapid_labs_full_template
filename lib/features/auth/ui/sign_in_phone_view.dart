import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:slapp/app/constants.dart';
import 'package:slapp/app/router.dart';
import 'package:slapp/app/services.dart';
import 'package:slapp/features/auth/services/auth_service.dart';
import 'package:slapp/features/auth/utils/fast_auth_exception.dart';
import 'package:slapp/features/shared/ui/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:slapp/features/shared/ui/loading_stack.dart';
import 'package:slapp/features/shared/ui/phone_number_text_field.dart';
import 'package:signals/signals_flutter.dart';

@RoutePage()
class SignInPhoneView extends StatefulWidget {
  const SignInPhoneView({
    super.key,
  });

  @override
  State<SignInPhoneView> createState() => _SignInPhoneViewState();
}

class _SignInPhoneViewState extends State<SignInPhoneView> with SignalsMixin {
  final _phoneFormKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  // https://dartsignals.dev/core/signal/#flutter
  late final phoneNumber = createSignal('');
  late final isLoading = createSignal(false);

  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        if (user.metadata.creationTime == user.metadata.lastSignInTime) {
          // New user
          await authService.createUser(
            id: authUserId.value!,
            phoneNumber: phoneNumber.value,
          );
          await authService.loadUserData(authUserId.value!);

          router.replaceAll([OnboardingRoute()]);
        } else {
          // Existing user
          await authService.loadUserData(authUserId.value!);

          router.replaceAll([const HomeRoute()]);
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handlePhoneSignIn() async {
    if (!_phoneFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      await authService.verifyPhoneNumber(
        phoneNumber: phoneNumber.value,
        onCodeSent: (verificationId) {
          if (mounted) {
            router.push(SmsVerificationRoute(
              verificationId: verificationId,
              phoneNumber: phoneNumber.value,
            ));
          }
        },
        onVerificationFailed: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        },
      );
    } on FastAuthException catch (e) {
      handleAuthError(e);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'There was an error verifying your phone number. Please try again.'),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void handleAuthError(FastAuthException e) {
    if (e.message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    gap48,
                    AppLogo(sideLength: 250),
                    gap24,
                    Text(
                      'Unlock Your slapp',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    gap8,
                    Text(
                      'Enter your phone number to sign in',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    gap32,
                    // Phone sign-in form
                    Form(
                      key: _phoneFormKey,
                      child: Column(
                        children: [
                          PhoneNumberTextField(
                            controller: _phoneController,
                            labelText: 'Phone Number',
                            hintText: '555-123-4567',
                            showCountryCode: true,
                            enabled: !isLoading.value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              // Basic phone number validation - check if we have 10 digits
                              String digitsOnly =
                                  PhoneNumberTextField.extractDigits(value);
                              if (digitsOnly.length < 10) {
                                return 'Please enter a valid phone number';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              // Extract digits and store with country code
                              String digitsOnly =
                                  PhoneNumberTextField.extractDigits(value);
                              phoneNumber.value = '+1$digitsOnly';
                            },
                          ),
                          gap24,
                          FilledButton(
                            onPressed:
                                isLoading.value ? null : _handlePhoneSignIn,
                            child: isLoading.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Text('Send Verification Code'),
                          ),
                        ],
                      ),
                    ),
                    gap24,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Don\'t have a slapp?'),
                        TextButton(
                          onPressed: () => router.push(SignUpPhoneRoute()),
                          child: const Text('Create One'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      );
    });
  }
}
