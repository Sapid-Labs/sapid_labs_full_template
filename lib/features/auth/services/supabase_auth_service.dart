import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:signals/signals_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:slapp/features/auth/services/auth_service.dart';
import 'package:slapp/features/auth/utils/fast_auth_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:slapp/app/config.dart';
import 'package:slapp/app/router.dart';
import 'package:slapp/app/services.dart';
import 'package:crypto/crypto.dart';

final authUserId = signal<String?>(null);
final authEmail = signal<String?>(null);
final authIsInitialized = signal<bool>(false);
final authIsAuthenticated = computed(() => authUserId.value != null);

@Singleton()
class SupabaseAuthService implements AuthService {
  late final SupabaseClient supabase;

  Future<void> setup() async {
    await GoogleSignIn.instance.initialize(
      serverClientId: const String.fromEnvironment("SERVER_CLIENT_ID"),
    );

    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    );

    supabase = Supabase.instance.client;

    // Listen to auth state changes
    supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      debugPrint('Auth state changed: $event, session: $session');

      switch (event) {
        case AuthChangeEvent.signedIn:
          authUserId.value = session?.user.id;
          authEmail.value = session?.user.email;
          break;
        case AuthChangeEvent.signedOut:
          authUserId.value = null;
          authEmail.value = null;
          break;
        case AuthChangeEvent.passwordRecovery:
          router.push(ChangePasswordRoute());
        default:
          break;
      }
    }).onError((error) {
      if (error is AuthException) {
        if (error.message.contains("Email link is invalid or has expired")) {
          // Handle expired email link
          debugPrint("Email link is invalid or has expired");
          router.push(ResetPasswordRoute());
        } else {
          // Handle other auth errors
          debugPrint("Auth error: ${error.message}");
        }
      }
    });

    // Set initial values from current session (this handles app restarts)
    final session = supabase.auth.currentSession;
    authUserId.value = session?.user.id;
    authEmail.value = session?.user.email;

    // Mark as initialized
    authIsInitialized.value = true;
  }

  Future<void> createUser({
    required String id,
    String? email,
    String? phoneNumber,
  }) async {
    try {
      final response = await supabase.from('users').upsert({
        'id': id,
        'email': email,
        'phone_number': phoneNumber,
        // Add other user fields as necessary
      });

      debugPrint('User created: $response');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUpAnonymously() async {
    try {
      final response = await supabase.auth.signInAnonymously();
      authUserId.value = response.user?.id;

      await createUser(
        id: response.user?.id ?? '',
        email: response.user?.email,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> signInWithGoogle() async {
    if (kIsWeb) {
      try {
        /* debugPrint('Signing in with Google on web');
        final bool signedIn = await supabase.auth.signInWithOAuth(

          provider: OAuthProvider.google,
          redirectTo: 'io.supabase.flutterquickstart://login-callback/',
        );
        authUserId.value = authResponse.user?.id;
        authEmail.value = authResponse.user?.email; */
        return true;
      } catch (e) {
        rethrow;
      }
    } else {
      try {
        debugPrint('Signing in with Google');
        if (GoogleSignIn.instance.supportsAuthenticate()) {
          // Trigger the authentication flow
          final GoogleSignInAccount? googleUser =
              await GoogleSignIn.instance.authenticate();

          // Obtain the auth details from the request
          final GoogleSignInAuthentication? googleAuth =
              googleUser?.authentication;

          final response = await supabase.auth.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: googleAuth!.idToken!,
          );

          await createUser(
            id: response.user?.id ?? '',
            email: response.user?.email,
          );

          debugPrint('User signed in with Google');

          DateTime? createdAt =
              DateTime.tryParse(response.user?.createdAt ?? '');
          debugPrint('User signed in with Apple: ${response.user?.id}');
          debugPrint('Created At: ${response.user?.createdAt}');
          debugPrint('Metadata: ${response.user?.userMetadata}');

          return createdAt != null &&
              createdAt.isAfter(DateTime.now().subtract(Duration(minutes: 5)));
        } else {
          debugPrint('Google Sign-In is not supported on this platform.');
          throw Exception('Google Sign-In is not supported on this platform.');
        }
      } on GoogleSignInException catch (e) {
        debugPrint('e: $e');

        if (e.code == GoogleSignInExceptionCode.canceled) {
          throw FastAuthException('');
        }

        throw FastAuthException(
          'There was an error signing you in with Google. Please try again.',
          error: e.toString(),
        );
      } catch (e) {
        debugPrint('Error signing in with Google: $e');
        throw FastAuthException(
          'There was an error signing you in with Google. Please try again.',
          error: e.toString(),
        );
      }
    }
  }

  Future<bool> signInWithApple() async {
    try {
      final rawNonce = supabase.auth.generateRawNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );
      final idToken = credential.identityToken;
      if (idToken == null) {
        throw const AuthException(
            'Could not find ID Token from generated credential.');
      }
      final response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      DateTime? createdAt = DateTime.tryParse(response.user?.createdAt ?? '');
      debugPrint('User signed in with Apple: ${response.user?.id}');
      debugPrint('Created At: ${response.user?.createdAt}');
      debugPrint('Metadata: ${response.user?.userMetadata}');

      return createdAt != null &&
          createdAt.isAfter(DateTime.now().subtract(Duration(minutes: 5)));
    } on AuthApiException catch (e) {
      debugPrint('AuthApiException: $e');
      if (e.code == 'invalid_credentials') {
        throw FastAuthException(
          'Invalid Apple credentials. Please try again.',
          error: e.toString(),
        );
      } else {
        throw FastAuthException(
          'An error occurred while signing in with Apple. Please try again.',
          error: e.toString(),
        );
      }
    } catch (e) {
      debugPrint('Error signing in with Apple: $e');
      throw FastAuthException(
        'There was an error signing you in with Apple. Please try again.',
        error: e.toString(),
      );
    }
  }

  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      authUserId.value = response.user?.id;
      authEmail.value = response.user?.email;
    } on AuthApiException catch (e) {
      debugPrint('AuthApiException: $e');

      if (e.code == 'invalid_credentials') {
        throw FastAuthException(
          'Invalid email or password.',
          error: e.toString(),
        );
      } else {
        throw FastAuthException(
          'An error occurred while logging in. Please try again.',
          error: e.toString(),
        );
      }
    } catch (e) {
      debugPrint('Error logging in: $e');
      throw FastAuthException(
        'There was an error logging you in. Please try again.',
        error: e.toString(),
      );
    }
  }

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      authUserId.value = response.user?.id;
      authEmail.value = response.user?.email;

      await createUser(
        id: response.user?.id ?? '',
        email: response.user?.email,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePassword({
    required String password,
  }) async {
    try {
      final response = await supabase.auth.updateUser(
        UserAttributes(password: password),
      );

      if (response.user?.id != null) {
        authUserId.value = response.user!.id;
        authEmail.value = response.user?.email;
      } else {
        throw Exception('Failed to update password: User ID is null');
      }

      debugPrint('Password updated successfully');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword({
    required String email,
  }) async {
    try {
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo:
            '${AppConfig.appName.toLowerCase()}://${AppConfig.appName.toLowerCase()}.com/change-password',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await supabase.auth.signOut();
      authUserId.value = null;
      authEmail.value = null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> signInWithPhoneNumber(
      {required String verificationId, required String smsCode}) {
    // TODO: implement signInWithPhoneNumber
    throw UnimplementedError();
  }

  @override
  Future<void> verifyPhoneNumber(
      {required String phoneNumber,
      required Function(String verificationId) onCodeSent,
      required Function(String error) onVerificationFailed}) {
    // TODO: implement verifyPhoneNumber
    throw UnimplementedError();
  }

  @override
  Future<void> loadUserData(String userId) async {
    try {
      final response =
          await supabase.from('users').select().eq('id', userId).single();

      // Update any necessary user state here
      debugPrint('User data loaded: $response');
    } catch (e) {
      debugPrint('Error loading user data: $e');
      rethrow;
    }
  }
}
