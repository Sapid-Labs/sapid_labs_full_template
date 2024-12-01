import 'package:injectable/injectable.dart';
import 'package:signals/signals_flutter.dart';

@singleton
class AuthService {
  final userId = signal<String?>('12345');
  final email = signal<String?>('test@test.com');

  Future<void> setup() async {
    // Setup logic
  }

  Future<void> signUpAnonymously() async {
    // Sign up logic
  }

  Future<void> signInWithGoogle() async {
    // Sign in logic
  }

  Future<void> signInWithApple() async {
    // Sign in logic
  }

  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Login logic
  }

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Sign up logic
  }

  Future<void> logout() async {
    // Logout logic
  }
}
