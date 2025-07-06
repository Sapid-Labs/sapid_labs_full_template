import 'package:firebase_core/firebase_core.dart';
import 'package:sapid_labs/features/auth/services/firebase_auth_service.dart';
import 'package:sapid_labs/features/auth/services/supabase_auth_service.dart';
import 'package:signals/signals_flutter.dart';

final authUserId = signal<String?>(null);
final authEmail = signal<String?>(null);
final authIsAuthenticated = computed(() => authUserId.value != null);

abstract class AuthService {
  Future<void> setup() async {
    FirebaseAuthService().setup();
    SupabaseAuthService().setup();
  }

  Future<void> signUpAnonymously() async {
    FirebaseAuthService().signUpAnonymously();
    SupabaseAuthService().signUpAnonymously();
  }

  Future<void> signInWithGoogle() async {
    FirebaseAuthService().signInWithGoogle();
    SupabaseAuthService().signInWithGoogle();
  }

  Future<void> signInWithApple() async {
    FirebaseAuthService().signInWithApple();
    SupabaseAuthService().signInWithApple();
  }

  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    FirebaseAuthService().loginWithEmailAndPassword(email: email, password: password);
    SupabaseAuthService().loginWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    FirebaseAuthService().signUpWithEmailAndPassword(email: email, password: password);
    SupabaseAuthService().signUpWithEmailAndPassword(email: email, password: password);
  }

  Future<void> updatePassword({
    required String password,
  }) async {
    FirebaseAuthService().updatePassword(password: password);
    SupabaseAuthService().updatePassword(password: password);
  }

  Future<void> resetPassword({
    required String email,
  }) async {
    FirebaseAuthService().resetPassword(email: email);
    SupabaseAuthService().resetPassword(email: email);
  }

  Future<void> logout() async {
    FirebaseAuthService().logout();
    SupabaseAuthService().logout();
  }

  Future<void> createUser() async {
    FirebaseAuthService().createUser();
    SupabaseAuthService().createUser();
  }
}
