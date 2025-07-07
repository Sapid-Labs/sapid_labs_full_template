import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:slapp/app/get_it.dart';
import 'package:slapp/features/auth/services/auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

@firebase
@Singleton(as: AuthService)
class FirebaseAuthService implements AuthService {
  @override
  Future<void> setup() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        debugPrint('User is currently signed out!');
      } else {
        debugPrint('User is signed in!');
        authUserId.value = user.uid;
        authEmail.value = user.email;
      }
    });
  }

  @override
  Future<void> signUpAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase auth exception: ${e.code} - ${e.message}');
      throw Exception(e.message ?? 'Failed to sign up anonymously');
    } catch (e) {
      debugPrint('e: $e');
      throw Exception('Failed to sign up anonymously: ${e.toString()}');
    }
  }

  @override
  Future<bool> signInWithGoogle() async {
    if (kIsWeb) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithPopup(
          GoogleAuthProvider(),
        );

        return userCredential.additionalUserInfo?.isNewUser ?? false;
      } catch (e) {
        debugPrint('e: $e');
        throw Exception('Failed to sign in with Google: ${e.toString()}');
      }
    } else {
      try {
        debugPrint('Signing in with Google');
        // Trigger the authentication flow
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

        // Obtain the auth details from the request
        final GoogleSignInAuthentication? googleAuth =
            await googleUser?.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        // Once signed in, return the UserCredential
        UserCredential userCredential =await FirebaseAuth.instance.signInWithCredential(credential);

        debugPrint('User signed in with Google');

        return userCredential.additionalUserInfo?.isNewUser ?? false;
      } catch (e) {
        debugPrint('e: $e');
        throw Exception('Failed to sign in with Google: ${e.toString()}');
      }
    }
  }

  @override
  Future<void> signInWithApple() async {
      try {
      final appleProvider = AppleAuthProvider();
      if (kIsWeb) {
        await FirebaseAuth.instance.signInWithPopup(appleProvider);
      } else {
        await FirebaseAuth.instance.signInWithProvider(appleProvider);
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      debugPrint('Error signing in with Apple: $e');
      throw e.message;
    } catch (e) {
      debugPrint('Error signing in with Apple: $e');
      rethrow;
    }
  }

  @override
  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase auth exception: ${e.code} - ${e.message}');
      throw Exception(e.message ?? 'Failed to sign in');
    } catch (e) {
      debugPrint('e: $e');
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  @override
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential user =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      authUserId.value = user.user?.uid;
      authEmail.value = user.user?.email;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase auth exception: ${e.code} - ${e.message}');
      throw Exception(e.message ?? 'Failed to sign in');
    } catch (error, stack) {
      log('Error creating Firebase account: ' + error.toString());
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
    }
  }

  @override
  Future<void> updatePassword({
    required String password,
  }) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      user?.updatePassword(password);
    } catch (error, stack) {
      log('Error updating Firebase password: ' + error.toString());
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
  }) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      authUserId.value = null;
      authEmail.value = null;
    } catch (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack);
    }
  }

  @override
  Future<void> createUser() async {
    // TODO - Implement createUser logic
  }
}
