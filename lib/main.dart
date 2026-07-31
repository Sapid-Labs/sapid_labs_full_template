// STACK_FIREBASE:BEGIN
import 'package:firebase_core/firebase_core.dart';
import 'package:slapp/app/firebase_options.dart';
// STACK_FIREBASE:END
// STACK_FIREBASE_CRASHLYTICS:BEGIN
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// STACK_FIREBASE_CRASHLYTICS:END
// STACK_SENTRY:BEGIN
import 'package:sentry_flutter/sentry_flutter.dart';
// STACK_SENTRY:END
import 'package:slapp/app/get_it.dart';
import 'package:slapp/app/router.dart';
import 'package:slapp/app/services.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:slapp/app/theme.dart';
import 'package:slapp/features/settings/services/settings_service.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';

// STACK_SENTRY:BEGIN
/// Sentry is the portfolio's crash backend -- Crashlytics has no read API, so no tool can
/// ask it what is crashing. See docs/tech-stack.md in the fun-money repo. Put SENTRY_DSN in
/// the gitignored assets/config.json; an empty DSN skips init, so a scaffolded app with no
/// Sentry project yet behaves exactly as it did before.
const sentryDsn = String.fromEnvironment('SENTRY_DSN');
// STACK_SENTRY:END

Future<void> main() async {
  // Comment to activate Signals logging
  SignalsObserver.instance = null;

  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  GetIt.instance.registerSingleton(AppRouter());

  await setup();

  await subscriptionService.initPlatformState();
  await gateService.setup();

  // STACK_SENTRY:BEGIN
  if (sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.tracesSampleRate = 0.2;
        options.environment = kDebugMode ? 'development' : 'production';
        options.sendDefaultPii = true;
      },
      appRunner: () => runApp(const MainApp()),
    );
    return;
  }
  // STACK_SENTRY:END

  runApp(const MainApp());
}

Future<void> setup() async {
  // STACK_FIREBASE:BEGIN
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // STACK_FIREBASE:END

  // STACK_FIREBASE_CRASHLYTICS:BEGIN
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // STACK_FIREBASE_CRASHLYTICS:END

  // Supabase and Pocketbase have no block here on purpose. Their clients are
  // built inside the service that uses them -- SupabaseAuthService.setup() calls
  // Supabase.initialize itself, and calling it here as well throws "already
  // initialized". Firebase is the odd one out because DefaultFirebaseOptions has
  // to be resolved before any Firebase service is constructed.

  await configureDependencies();
  await authService.setup();
  await analyticsService.setup();
}

/// Declared in pubspec.yaml under `fonts:` and shipped in the APK/IPA.
///
/// This used to be `GoogleFonts.quicksand()`, which resolves a family by
/// downloading the TTF from fonts.gstatic.com on first launch. Two things were
/// wrong with that. Until the download lands the app renders in the platform
/// fallback face, and first launch is exactly when a new user decides whether
/// this looks like a real app -- on a bad connection they never see Quicksand at
/// all. And it only ever fetched the w400 file, so every bold weight in the app
/// was synthesised by the engine rather than drawn. Four real weights are now
/// bundled, hash-checked against the files google_fonts would have fetched.
const String fontFamily = 'Quicksand';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      return MaterialApp.router(
        debugShowCheckedModeBanner: false,
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
        routerConfig: router.config(
          // Page-view tracking. Reports through analyticsService, so it works on any stack.
          // navigatorObservers: () {
          //   return [
          //     AnalyticsNavigationObserver(),
          //   ];
          // },
        ),
      );
    });
  }
}

FlexSubThemesData get subThemesData => FlexSubThemesData(
      defaultRadius: 24,
      inputDecoratorBorderType: FlexInputBorderType.outline,
    );
