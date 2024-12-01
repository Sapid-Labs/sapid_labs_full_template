import 'package:cotr_flutter_app/app/get_it.dart';
import 'package:cotr_flutter_app/app/router.dart';
import 'package:cotr_flutter_app/app/services.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get_it/get_it.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  GetIt.instance.registerSingleton(AppRouter());

  await setup();

  runApp(const MainApp());
}

Future<void> setup() async {
  await configureDependencies();
  await authService.setup();
  await analyticsService.setup();
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: FlexThemeData.light(scheme: FlexScheme.blueWhale),
      darkTheme: FlexThemeData.dark(scheme: FlexScheme.blueWhale),
      themeMode: ThemeMode.system,
      routerConfig: router.config(),
    );
  }
}
