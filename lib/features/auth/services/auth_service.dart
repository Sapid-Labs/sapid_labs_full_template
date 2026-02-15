import 'dart:async';
import 'package:slapp/features/auth/models/app_user.dart';
import 'package:slapp/features/auth/services/firebase_auth_service.dart';
import 'package:slapp/features/auth/services/supabase_auth_service.dart';
import 'package:signals/signals_flutter.dart';

final authUserId = signal<String?>(null);
final authEmail = signal<String?>(null);
final authIsAuthenticated = computed(() => authUserId.value != null);
final authPhoneNumber = signal<String?>(null);
final appUser = signal<AppUser?>(null);

abstract class AuthService {
  // all implementations are linked here for easy dev navigation
  Future<void> setup() async {
    FirebaseAuthService().setup();
    SupabaseAuthService().setup();
  }

  Future<void> signUpAnonymously() async {
    FirebaseAuthService().signUpAnonymously();
    SupabaseAuthService().signUpAnonymously();
  }

  Future<bool> signInWithGoogle() async {
    FirebaseAuthService().signInWithGoogle();
    SupabaseAuthService().signInWithGoogle();
    return true;
  }

  Future<bool> signInWithApple() async {
    FirebaseAuthService().signInWithApple();
    SupabaseAuthService().signInWithApple();
    return true;
  }

  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    FirebaseAuthService()
        .loginWithEmailAndPassword(email: email, password: password);
    SupabaseAuthService()
        .loginWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    FirebaseAuthService()
        .signUpWithEmailAndPassword(email: email, password: password);
    SupabaseAuthService()
        .signUpWithEmailAndPassword(email: email, password: password);
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

  Future<void> createUser({
    required String id,
    String? email,
    String? phoneNumber,
  }) async {
    FirebaseAuthService()
        .createUser(id: id, email: email, phoneNumber: phoneNumber);
    SupabaseAuthService()
        .createUser(id: id, email: email, phoneNumber: phoneNumber);
  }

  Future<void> loadUserData(String userId) async {
    FirebaseAuthService().loadUserData(userId);
    SupabaseAuthService().loadUserData(userId);
  }

  Future<void> saveUserData(AppUser user) async {
    FirebaseAuthService().saveUserData(user);
    SupabaseAuthService().saveUserData(user);
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onVerificationFailed,
  }) async {
    FirebaseAuthService().verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onVerificationFailed: onVerificationFailed,
    );
  }

  Future<bool> signInWithPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    FirebaseAuthService().signInWithPhoneNumber(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return true;
  }

  void listenForPhoneSignUp(String phoneNumber) {
    FirebaseAuthService().listenForPhoneSignUp(phoneNumber);
    SupabaseAuthService().listenForPhoneSignUp(phoneNumber);
  }
}
