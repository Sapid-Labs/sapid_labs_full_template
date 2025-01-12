import 'package:firebase_core/firebase_core.dart';
import 'package:foolscript/app/get_it.dart';
import 'package:foolscript/app/router.dart';
import 'package:foolscript/app/services.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:foolscript/features/settings/services/settings_service.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  await Firebase.initializeApp();

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
    return Watch((context) {
      return MaterialApp.router(
        theme: FlexThemeData.light(
          scheme: FlexScheme.blueWhale,
          subThemesData: subThemesData,
        ),
        darkTheme: FlexThemeData.dark(
          scheme: FlexScheme.blueWhale,
          subThemesData: subThemesData,
        ),
        themeMode: settingsThemeMode.value,
        routerConfig: router.config(),
      );
    });
  }
}

FlexSubThemesData get subThemesData => FlexSubThemesData(
      defaultRadius: 24,
      inputDecoratorBorderType: FlexInputBorderType.outline,
    );
