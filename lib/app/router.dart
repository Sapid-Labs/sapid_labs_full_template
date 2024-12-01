import 'package:auto_route/auto_route.dart';
import 'package:cotr_flutter_app/features/auth/ui/sign_in_view.dart';
import 'package:cotr_flutter_app/features/auth/ui/sign_up_view.dart';
import 'package:cotr_flutter_app/features/home/ui/home_view.dart';
import 'package:cotr_flutter_app/features/subscriptions/ui/subscription_view.dart';

part 'router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'View|Picker,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material(); //.cupertino, .adaptive ..etc

  @override
  final List<AutoRoute> routes = [
    AutoRoute(
      initial: true,
      page: HomeRoute.page,
      path: '/',
    ),
    AutoRoute(
      page: SignInRoute.page,
      path: '/sign-in',
    ),
    AutoRoute(
      page: SubscriptionRoute.page,
      path: '/subscriptions',
    ),
  ];
}
