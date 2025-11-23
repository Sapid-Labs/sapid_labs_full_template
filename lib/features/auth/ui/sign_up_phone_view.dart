import 'package:auto_route/auto_route.dart';
import 'package:slapp/app/constants.dart';
import 'package:slapp/app/router.dart';
import 'package:slapp/app/services.dart';
import 'package:slapp/features/shared/ui/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:slapp/features/shared/ui/loading_stack.dart';
import 'package:slapp/features/shared/ui/phone_number_text_field.dart';
import 'package:signals/signals_flutter.dart';

@RoutePage()
class SignUpPhoneView extends StatefulWidget {
  const SignUpPhoneView({super.key});

  @override
  State<SignUpPhoneView> createState() => _SignUpPhoneViewState();
}

class _SignUpPhoneViewState extends State<SignUpPhoneView> with SignalsMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  late final phoneNumber = createSignal('');
  late final isLoading = createSignal(false);
  late final error = createSignal<String?>(null);

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handlePhoneSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      error.value = null;

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
    } catch (e) {
      error.value = 'Failed to verify phone number: ${e.toString()}';
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
                        'Create Your slapp',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your phone number to get started',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
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
                          String digitsOnly = PhoneNumberTextField.extractDigits(value);
                          if (digitsOnly.length < 10) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          // Extract digits and store with country code
                          String digitsOnly = PhoneNumberTextField.extractDigits(value);
                          phoneNumber.value = '+1$digitsOnly';
                        },
                      ),
                      gap24,
                      ElevatedButton(
                        onPressed: isLoading.value ? null : _handlePhoneSignUp,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Send Verification Code'),
                        ),
                      ),
                      gap24,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have a slapp?'),
                          TextButton(
                            onPressed: () =>
                                router.replace(const SignInPhoneRoute()),
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
