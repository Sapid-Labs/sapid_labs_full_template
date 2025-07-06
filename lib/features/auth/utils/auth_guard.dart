import 'package:auto_route/auto_route.dart';
import 'package:slapp/app/router.dart';
import 'package:flutter/material.dart';
import 'package:slapp/features/auth/services/auth_service.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    debugPrint('Basic observer - stack: ${router.stack.map((e) => e.name)}');
    try {
      bool isAuthenticated = authIsAuthenticated.value;

      if (isAuthenticated) {
        resolver.next(true); // Allow navigation
      } else {
        router.push(SignInRoute());
      }
    } catch (e) {
      debugPrint('Basic observer - AuthGuard - error: $e');
      router.push(SignInRoute());
    }
  }
}
