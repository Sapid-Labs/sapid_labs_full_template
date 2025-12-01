import 'package:auto_route/auto_route.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:slapp/app/constants.dart';
import 'package:slapp/app/router.dart';
import 'package:slapp/app/services.dart';
import 'package:slapp/features/auth/services/auth_service.dart';
import 'package:slapp/features/auth/utils/fast_auth_exception.dart';
import 'package:slapp/features/shared/ui/app_logo.dart';
import 'package:slapp/features/shared/ui/loading_stack.dart';
import 'package:signals/signals_flutter.dart';
import 'package:slapp/features/shared/utils/phone_utils.dart';

@RoutePage()
class SmsVerificationView extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const SmsVerificationView({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<SmsVerificationView> createState() => _SmsVerificationViewState();
}

class _SmsVerificationViewState extends State<SmsVerificationView>
    with SignalsMixin {
  final _formKey = GlobalKey<FormState>();
  final _smsCodeController = TextEditingController();

  late final smsCode = createSignal('');
  late final isLoading = createSignal(false);

  @override
  void initState() {
    authService.listenForPhoneSignUp(widget.phoneNumber);
    super.initState();
  }

  @override
  void dispose() {
    _smsCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleSmsVerification() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      bool isNewUser = await authService.signInWithPhoneNumber(
        verificationId: widget.verificationId,
        smsCode: smsCode.value,
      );

      if (authUserId.value != null) {
        await authService.loadUserData(authUserId.value!);

        if (mounted) {
          if (isNewUser) {
            print('New user detected, creating user profile');
            authService.createUser(
              id: authUserId.value!,
              phoneNumber: widget.phoneNumber,
            );
            router.replaceAll([OnboardingRoute()]);
          } else {
            print('Existing user, navigating to home');
            router.replaceAll([const HomeRoute()]);
          }
        }
      } else {
        throw FastAuthException('Authentication failed. Please try again.');
      }
    } on FastAuthException catch (e) {
      _handleAuthError(e);
    } catch (e, s) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invalid verification code. Please try again: ' + e.toString(),
          ),
        ),
      );
      FirebaseCrashlytics.instance.recordError(e, s, fatal: false);
    } finally {
      isLoading.value = false;
    }
  }

  void _handleAuthError(FastAuthException e) {
    if (e.message.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      return LoadingStack(
        isLoading: isLoading.value,
        child: Scaffold(
          appBar: AppBar(title: const Text('Verify Phone Number')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppLogo(sideLength: 150),
                  gap24,
                  Text(
                    'We sent a verification code to',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  gap8,
                  Text(
                    formatPhoneNumber(widget.phoneNumber),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  gap24,
                  TextFormField(
                    controller: _smsCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Verification Code',
                      hintText: 'Enter 6-digit code',
                    ),
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    enabled: !isLoading.value,
                    onFieldSubmitted: (value) {
                      if (!isLoading.value) {
                        _handleSmsVerification();
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the verification code';
                      }
                      if (value.length != 6) {
                        return 'Code must be 6 digits';
                      }
                      return null;
                    },
                    onChanged: (value) => smsCode.value = value,
                  ),
                  gap24,
                  FilledButton(
                    onPressed: isLoading.value ? null : _handleSmsVerification,
                    child: isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Verify'),
                  ),
                  gap16,
                  TextButton(
                    onPressed: () {
                      router.maybePop();
                    },
                    child: const Text('Back to Phone Number'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
