import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:slapp/features/auth/ui/account_view.dart';
import 'package:slapp/features/auth/ui/change_password_view.dart';
import 'package:slapp/features/auth/ui/profile/profile_view.dart';
import 'package:slapp/features/auth/ui/reset_password_view.dart';
import 'package:slapp/features/auth/ui/sign_in_view.dart';
import 'package:slapp/features/auth/ui/sign_up_view.dart';
import 'package:slapp/features/auth/utils/auth_guard.dart';
import 'package:slapp/features/feedback/ui/feedback_view.dart';
import 'package:slapp/features/feedback/ui/new_feedback/new_feedback_view.dart';
import 'package:slapp/features/home/ui/home_view.dart';
import 'package:slapp/features/onboarding/ui/onboarding_view.dart';
import 'package:slapp/features/rss/ui/rss_view.dart';
import 'package:slapp/features/settings/ui/settings_view.dart';
import 'package:slapp/features/subscriptions/ui/subscription_view.dart';

part 'router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'View|Picker,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType =>
      const RouteType.material(); //.cupertino, .adaptive ..etc

  @override
  final List<AutoRoute> routes = [
    AutoRoute(
      initial: true,
      page: HomeRoute.page,
      path: '/home',
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: OnboardingRoute.page,
      path: '/onboarding',
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: SignInRoute.page,
      path: '/sign-in',
    ),
    AutoRoute(
      page: SignUpRoute.page,
      path: '/sign-up',
    ),
    AutoRoute(
      page: AccountRoute.page,
      path: '/account',
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: SettingsRoute.page,
      path: '/settings',
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: FeedbackRoute.page,
      path: '/feedback',
      guards: [AuthGuard()],
    ),
     AutoRoute(
      page: NewFeedbackRoute.page,
      path: '/new-feedback',
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: ChangePasswordRoute.page,
      path: '/update-password',
    ),
    AutoRoute(
      page: ResetPasswordRoute.page,
      path: '/reset-password',
    ),
    AutoRoute(
      page: SubscriptionRoute.page,
      path: '/subscriptions',
      guards: [
        AuthGuard(),
      ],
    ),
  ];
}
