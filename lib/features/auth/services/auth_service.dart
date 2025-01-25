import 'package:signals/signals_flutter.dart';

final authUserId = signal<String?>(null);
final authEmail = signal<String?>(null);
final authIsAuthenticated = computed(() => authUserId.value != null);

abstract class AuthService {
  Future<void> setup() async {
    // TODO - Implement setup logic for AuthService
  }

  Future<void> signUpAnonymously() async {
    // TODO - Implement signUpAnonymously logic
  }

  Future<void> signInWithGoogle() async {
    // TODO - Implement signInWithGoogle logic
  }

  Future<void> signInWithApple() async {
    // TODO - Implement signInWithApple logic
  }

  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // TODO - Implement loginWithEmailAndPassword logic
  }

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // TODO - Implement signUpWithEmailAndPassword logic
  }

  Future<void> updatePassword({
    required String password,
  }) async {
    // TODO - Implement updatePassword logic
  }

  Future<void> resetPassword({
    required String email,
  }) async {
    // TODO - Implement resetPassword logic
  }

  Future<void> logout() async {
    // TODO - Implement logout logic
  }

  Future<void> createUser() async {
    // TODO - Implement createUser logic
  }
}
