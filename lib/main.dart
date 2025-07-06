import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slapp/app/firebase_options.dart';
import 'package:slapp/app/get_it.dart';
import 'package:slapp/app/router.dart';
import 'package:slapp/app/services.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:slapp/app/theme.dart';
import 'package:slapp/features/settings/services/settings_service.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';

Future<void> main() async {
  // Comment to activate Signals logging
  SignalsObserver.instance = null;

  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  GetIt.instance.registerSingleton(AppRouter());

  await setup();

  runApp(const MainApp());
}

Future<void> setup() async {
  if (const String.fromEnvironment('STACK_PAAS') == 'firebase') {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  } else if (const String.fromEnvironment('STACK_PAAS') == 'supabase') {}
  await configureDependencies();
  await authService.setup();
  await analyticsService.setup();
}

String? fontFamily = GoogleFonts.quicksand().fontFamily;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      return MaterialApp.router(
        theme: FlexThemeData.light(
          fontFamily: fontFamily,
          scheme: FlexScheme.blueWhale,
          subThemesData: subThemesData,
          pageTransitionsTheme: pageTransitionsTheme,
        ),
        darkTheme: FlexThemeData.dark(
          fontFamily: fontFamily,
          scheme: FlexScheme.blueWhale,
          subThemesData: subThemesData,
          pageTransitionsTheme: pageTransitionsTheme,
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
