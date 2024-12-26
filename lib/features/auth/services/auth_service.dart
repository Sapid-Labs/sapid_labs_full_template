import 'package:injectable/injectable.dart';
import 'package:signals/signals_flutter.dart';

@singleton
class AuthService {
  final userId = signal<String?>('12345');
  final email = signal<String?>('test@test.com');
  late final FlutterComputed isAuthenticated;

  Future<void> setup() async {
    isAuthenticated = computed(() => userId.value != null);
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

  Future<void> updatePassword({
    required String password,
  }) async {
    // Update password logic
  }

  Future<void> resetPassword({
    required String email,
  }) async {
    // Reset password logic
  }

  Future<void> logout() async {
    // Logout logic
  }

  Future<void> createUser() async {
    // Create user in database
  }
}
