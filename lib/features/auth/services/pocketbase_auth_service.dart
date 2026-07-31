import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:slapp/features/auth/models/app_user.dart';
import 'package:slapp/features/auth/services/auth_service.dart';
import 'package:slapp/features/auth/utils/fast_auth_exception.dart';

// STACK_POCKETBASE
// @Singleton(as: AuthService)
@Singleton()
class PocketbaseAuthService implements AuthService {
  /// The collection Pocketbase creates for you. Rename it here if you renamed it
  /// there; nothing else in the app names a collection.
  static const usersCollection = 'users';

  late final PocketBase pb;

  /// What this service does NOT do, and why each one is a throw rather than a
  /// silent no-op.
  ///
  /// Pocketbase has no anonymous sign-in and no phone/SMS sign-in at all, and its
  /// OAuth2 flow needs a redirect URL registered on the server plus a browser
  /// round trip that the Google and Apple SDKs in this template do not perform.
  /// A method that returned normally without signing anybody in would route the
  /// caller to onboarding with no session -- the exact bug the web Google button
  /// had before it was fixed. So each unsupported path throws a message a user
  /// can read, and the sign-in screens already hide the Google button while
  /// [googleSignInAvailable] is false.
  Never _unsupported(String what) => throw FastAuthException(
      '$what is not available on Pocketbase. Use email and password, or switch '
      'the backend with tool/stack.py.');

  @override
  Future<void> setup() async {
    pb = PocketBase(const String.fromEnvironment('POCKETBASE_URL'));

    pb.authStore.onChange.listen((AuthStoreEvent event) {
      final record = event.record;
      authUserId.value = record?.id;
      authEmail.value = record?.getStringValue('email');
    });

    if (pb.authStore.isValid) {
      authUserId.value = pb.authStore.record?.id;
      authEmail.value = pb.authStore.record?.getStringValue('email');
    }

    // Google sign-in never starts here, so the button stays hidden rather than
    // throwing when it is tapped.
    googleSignInAvailable.value = false;
    authIsInitialized.value = true;
  }

  @override
  Future<void> signUpAnonymously() async => _unsupported('Anonymous sign-in');

  @override
  Future<bool> signInWithGoogle() async => _unsupported('Google sign-in');

  @override
  Future<bool> signInWithApple() async => _unsupported('Apple sign-in');

  @override
  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await pb.collection(usersCollection).authWithPassword(email, password);
    } on ClientException catch (e) {
      throw FastAuthException(_readableError(e), error: e.toString());
    }
  }

  @override
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await pb.collection(usersCollection).create(body: {
        'email': email,
        'password': password,
        'passwordConfirm': password,
      });
      // Creating a record does not sign anybody in. Without this the caller
      // reaches onboarding with an empty auth store.
      await pb.collection(usersCollection).authWithPassword(email, password);
    } on ClientException catch (e) {
      throw FastAuthException(_readableError(e), error: e.toString());
    }
  }

  @override
  Future<void> updatePassword({required String password}) async =>
      _unsupported('Changing a password in place');

  @override
  Future<void> resetPassword({required String email}) async {
    // Pocketbase mails a link that lands on its own confirmation page, so this
    // one does not use the app's /update-password route the way Supabase does.
    await pb.collection(usersCollection).requestPasswordReset(email);
  }

  @override
  Future<void> logout() async {
    pb.authStore.clear();
    authUserId.value = null;
    authEmail.value = null;
    appUser.value = null;
  }

  @override
  Future<void> deleteAccount() async {
    final id = authUserId.value;
    if (id == null) return;
    await pb.collection(usersCollection).delete(id);
    await logout();
  }

  @override
  Future<void> createUser({
    required String id,
    String? email,
    String? phoneNumber,
  }) async {
    // The record already exists -- Pocketbase makes it at sign-up. This fills in
    // the profile columns the template's AppUser expects.
    try {
      await pb.collection(usersCollection).update(id, body: {
        if (email != null) 'email': email,
        if (phoneNumber != null) 'phone_number': phoneNumber,
      });
    } catch (e) {
      debugPrint('Error creating user: $e');
      rethrow;
    }
  }

  @override
  Future<void> loadUserData(String userId) async {
    try {
      final record = await pb.collection(usersCollection).getOne(userId);
      appUser.value = AppUser.fromJson(record.toJson());
    } catch (e) {
      debugPrint('Error loading user data: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveUserData(AppUser user) async {
    final id = authUserId.value;
    if (id == null) {
      debugPrint('Cannot save user data: user not authenticated');
      return;
    }
    try {
      await pb.collection(usersCollection).update(id, body: user.toJson());
      appUser.value = user;
    } catch (e) {
      debugPrint('Error saving user data: $e');
      rethrow;
    }
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onVerificationFailed,
  }) async {
    onVerificationFailed('Phone sign-in is not available on Pocketbase.');
  }

  @override
  Future<bool> signInWithPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async =>
      _unsupported('Phone sign-in');

  @override
  void listenForPhoneSignUp(String phoneNumber) {
    // Nothing to listen for: there is no phone sign-in to complete.
  }

  /// Pocketbase reports a bad password and an unknown address the same way, and
  /// that is deliberate on its side -- do not "improve" it into a message that
  /// tells a stranger which addresses have accounts.
  String _readableError(ClientException e) {
    if (e.statusCode == 400) return 'That email and password do not match.';
    if (e.statusCode == 403) return 'That account cannot sign in.';
    return 'Could not reach the server. Please try again.';
  }
}
