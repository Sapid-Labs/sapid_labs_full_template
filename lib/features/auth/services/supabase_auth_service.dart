import 'package:flutter/foundation.dart';
import 'package:slapp/app/get_it.dart';
import 'package:slapp/features/auth/services/auth_service.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@supabase
@Singleton(as: AuthService)
class SupabaseAuthService implements AuthService {
  late final SupabaseClient supabase;

  @override
  Future<void> setup() async {
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
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo:
            kIsWeb ? null : 'io.supabase.flutterquickstart://login-callback/',
      );

      return true;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signInWithApple() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo:
            kIsWeb ? null : 'io.supabase.flutterquickstart://login-callback/',
      );
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
  Future<void> createUser() async {
    // TODO - Implement createUser logic
  }
}
