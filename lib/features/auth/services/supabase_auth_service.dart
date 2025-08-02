import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:slapp/app/get_it.dart';
import 'package:slapp/features/auth/services/auth_service.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@supabaseEnv
@Singleton(as: AuthService)
class SupabaseAuthService implements AuthService {
  late final SupabaseClient supabase;

  @override
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

      switch (event) {
        case AuthChangeEvent.signedIn:
          authUserId.value = session?.user.id;
          authEmail.value = session?.user.email;
          break;
        case AuthChangeEvent.signedOut:
          authUserId.value = null;
          authEmail.value = null;
          break;
        default:
          break;
      }
    });

    // Set initial values
    final session = supabase.auth.currentSession;
    authUserId.value = session?.user.id;
    authEmail.value = session?.user.email;
  }

  @override
  Future<void> signUpAnonymously() async {
    try {
      final response = await supabase.auth.signInAnonymously();
      authUserId.value = response.user?.id;
    } catch (e) {
      rethrow;
    }
  }

  @override
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

          // Create a new credential
          /* final credential = GoogleAuthProvider.credential(
            idToken: googleAuth?.idToken,
          ); */

          final AuthResponse authResponse =
              await supabase.auth.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: googleAuth!.idToken!,
          );

          await createUser(
            id: authResponse.user?.id ?? '',
            email: authResponse.user?.email,
          );

          debugPrint('User signed in with Google');

          // bool isNewUser = await authResponse.user.userMetadata;

          return true;
        } else {
          debugPrint('Google Sign-In is not supported on this platform.');
          throw Exception('Google Sign-In is not supported on this platform.');
        }
      } catch (e) {
        rethrow;
      }
    }
  }

  @override
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
    } catch (e) {
      rethrow;
    }
  }

  @override
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
    } catch (e) {
      rethrow;
    }
  }

  @override
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
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updatePassword({
    required String password,
  }) async {
    // Update password logic
  }

  @override
  Future<void> resetPassword({
    required String email,
  }) async {
    try {
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
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
  Future<void> createUser({
    required String id,
    String? email,
  }) async {
    try {
      final response = await supabase.from('users').upsert({
        'id': id,
        'email': email,
        // Add other user fields as necessary
      });

      debugPrint('User created: $response');
    } catch (e) {
      rethrow;
    }
  }
}
