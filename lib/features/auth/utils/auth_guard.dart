import 'package:auto_route/auto_route.dart';
import 'package:fools_app_template/app/router.dart';
import 'package:fools_app_template/app/services.dart';
import 'package:flutter/material.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    debugPrint('Basic observer - AuthGuard: ${resolver.hashCode}');
    debugPrint('Basic observer - stack: ${router.stack.map((e) => e.name)}');
    try {
      bool isAuthenticated = authService.isAuthenticated.value;

      if (isAuthenticated) {
        resolver.next(true); // Allow navigation
      } else {
        router.push(SignInRoute());
      }
    } catch (e) {
      debugPrint('Basic observer - AuthGuard - error: $e');
      resolver.next(false);
    }
  }
}
