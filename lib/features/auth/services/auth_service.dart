import 'package:foolscript/features/auth/services/auth_service_interface.dart';
import 'package:injectable/injectable.dart';
import 'package:signals/signals_flutter.dart';

final authUserId =
    signal<String?>('1'); // TODO - set to null for real authentication
final authEmail =
    signal<String?>(null); // TODO - set to null for real authentication
final authIsAuthenticated = computed(() => authUserId.value != null);

@singleton
class AuthService implements AuthServiceInterface {
  @override
  Future<void> setup() async {
    // TODO - Implement setup logic for AuthService
  }

  @override
  Future<void> signUpAnonymously() async {
    // TODO - Implement signUpAnonymously logic
  }

  @override
  Future<void> signInWithGoogle() async {
    // TODO - Implement signInWithGoogle logic
  }

  @override
  Future<void> signInWithApple() async {
    // TODO - Implement signInWithApple logic
  }

  @override
  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // TODO - Implement loginWithEmailAndPassword logic
  }

  @override
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // TODO - Implement signUpWithEmailAndPassword logic
  }

  @override
  Future<void> updatePassword({
    required String password,
  }) async {
    // TODO - Implement updatePassword logic
  }

  @override
  Future<void> resetPassword({
    required String email,
  }) async {
    // TODO - Implement resetPassword logic
  }

  @override
  Future<void> logout() async {
    // TODO - Implement logout logic
  }

  @override
  Future<void> createUser() async {
    // TODO - Implement createUser logic
  }
}
