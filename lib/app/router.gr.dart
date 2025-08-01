// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

/// generated route for
/// [AccountView]
class AccountRoute extends PageRouteInfo<void> {
  const AccountRoute({List<PageRouteInfo>? children})
      : super(AccountRoute.name, initialChildren: children);

  static const String name = 'AccountRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AccountView();
    },
  );
}

/// generated route for
/// [ChangePasswordView]
class ChangePasswordRoute extends PageRouteInfo<void> {
  const ChangePasswordRoute({List<PageRouteInfo>? children})
      : super(ChangePasswordRoute.name, initialChildren: children);

  static const String name = 'ChangePasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChangePasswordView();
    },
  );
}

/// generated route for
/// [DemoView]
class DemoRoute extends PageRouteInfo<DemoRouteArgs> {
  DemoRoute({Key? key, List<PageRouteInfo>? children})
      : super(
          DemoRoute.name,
          args: DemoRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'DemoRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DemoRouteArgs>(
        orElse: () => const DemoRouteArgs(),
      );
      return DemoView(key: args.key);
    },
  );
}

class DemoRouteArgs {
  const DemoRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'DemoRouteArgs{key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DemoRouteArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [FeedbackView]
class FeedbackRoute extends PageRouteInfo<void> {
  const FeedbackRoute({List<PageRouteInfo>? children})
      : super(FeedbackRoute.name, initialChildren: children);

  static const String name = 'FeedbackRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const FeedbackView();
    },
  );
}

/// generated route for
/// [HomeView]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
      : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeView();
    },
  );
}

/// generated route for
/// [NewFeedbackView]
class NewFeedbackRoute extends PageRouteInfo<NewFeedbackRouteArgs> {
  NewFeedbackRoute({Key? key, List<PageRouteInfo>? children})
      : super(
          NewFeedbackRoute.name,
          args: NewFeedbackRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'NewFeedbackRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NewFeedbackRouteArgs>(
        orElse: () => const NewFeedbackRouteArgs(),
      );
      return NewFeedbackView(key: args.key);
    },
  );
}

class NewFeedbackRouteArgs {
  const NewFeedbackRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'NewFeedbackRouteArgs{key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NewFeedbackRouteArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [OnboardingView]
class OnboardingRoute extends PageRouteInfo<void> {
  const OnboardingRoute({List<PageRouteInfo>? children})
      : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OnboardingView();
    },
  );
}

/// generated route for
/// [ProfileView]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
      : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileView();
    },
  );
}

/// generated route for
/// [ResetPasswordView]
class ResetPasswordRoute extends PageRouteInfo<void> {
  const ResetPasswordRoute({List<PageRouteInfo>? children})
      : super(ResetPasswordRoute.name, initialChildren: children);

  static const String name = 'ResetPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ResetPasswordView();
    },
  );
}

/// generated route for
/// [RssView]
class RssRoute extends PageRouteInfo<void> {
  const RssRoute({List<PageRouteInfo>? children})
      : super(RssRoute.name, initialChildren: children);

  static const String name = 'RssRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RssView();
    },
  );
}

/// generated route for
/// [SettingsView]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
      : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsView();
    },
  );
}

/// generated route for
/// [SignInView]
class SignInRoute extends PageRouteInfo<void> {
  const SignInRoute({List<PageRouteInfo>? children})
      : super(SignInRoute.name, initialChildren: children);

  static const String name = 'SignInRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SignInView();
    },
  );
}

/// generated route for
/// [SignUpView]
class SignUpRoute extends PageRouteInfo<SignUpRouteArgs> {
  SignUpRoute({Key? key, String? email, List<PageRouteInfo>? children})
      : super(
          SignUpRoute.name,
          args: SignUpRouteArgs(key: key, email: email),
          initialChildren: children,
        );

  static const String name = 'SignUpRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SignUpRouteArgs>(
        orElse: () => const SignUpRouteArgs(),
      );
      return SignUpView(key: args.key, email: args.email);
    },
  );
}

class SignUpRouteArgs {
  const SignUpRouteArgs({this.key, this.email});

  final Key? key;

  final String? email;

  @override
  String toString() {
    return 'SignUpRouteArgs{key: $key, email: $email}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SignUpRouteArgs) return false;
    return key == other.key && email == other.email;
  }

  @override
  int get hashCode => key.hashCode ^ email.hashCode;
}

/// generated route for
/// [SubscriptionView]
class SubscriptionRoute extends PageRouteInfo<void> {
  const SubscriptionRoute({List<PageRouteInfo>? children})
      : super(SubscriptionRoute.name, initialChildren: children);

  static const String name = 'SubscriptionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SubscriptionView();
    },
  );
}
