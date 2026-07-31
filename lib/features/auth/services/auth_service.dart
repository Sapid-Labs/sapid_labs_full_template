import 'dart:async';
import 'package:slapp/features/auth/models/app_user.dart';
import 'package:signals/signals_flutter.dart';

final authUserId = signal<String?>(null);
final authEmail = signal<String?>(null);
final authIsInitialized = signal<bool>(false);
final authIsAuthenticated = computed(() => authUserId.value != null);
final authPhoneNumber = signal<String?>(null);
final appUser = signal<AppUser?>(null);

/// Whether Google sign-in can actually run on this device.
///
/// Set by the live [AuthService] implementation once its Google SDK has
/// started. It stays false when the SDK is missing a client id or refuses to
/// start, so the UI hides the button rather than offering one that throws.
final googleSignInAvailable = signal<bool>(false);

/// The auth interface every screen and route guard talks to.
///
/// Keep this a pure interface. It used to carry method bodies that called
/// `FirebaseAuthService()` and `SupabaseAuthService()` one after the other "for easy
/// dev navigation". That made the interface import both vendors, so neither could be
/// deleted from a child app that had picked the other one, and a caller who reached
/// the base class ran two SDKs at once. Pick the vendor with the `// STACK_<NAME>`
/// marker on the implementation, or run `tool/stack.py`.
abstract class AuthService {
  Future<void> setup();

  Future<void> signUpAnonymously();

  Future<bool> signInWithGoogle();

  Future<bool> signInWithApple();

  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> updatePassword({required String password});

  Future<void> resetPassword({required String email});

  Future<void> logout();

  Future<void> deleteAccount();

  Future<void> createUser({
    required String id,
    String? email,
    String? phoneNumber,
  });

  Future<void> loadUserData(String userId);

  Future<void> saveUserData(AppUser user);

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onVerificationFailed,
  });

  Future<bool> signInWithPhoneNumber({
    required String verificationId,
    required String smsCode,
  });

  void listenForPhoneSignUp(String phoneNumber);
}
