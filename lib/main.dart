import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:slapp/app/firebase_options.dart';
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
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:signals/signals_flutter.dart';

// STACK_AMPLITUDE
// import 'package:amplitude_flutter/amplitude.dart';
// import 'package:amplitude_flutter/configuration.dart';
// import 'package:slapp/features/shared/utils/navigation_observers.dart';

/// Sentry is the portfolio's crash backend -- Crashlytics has no read API, so no tool can
/// ask it what is crashing. See docs/tech-stack.md in the fun-money repo. Put SENTRY_DSN in
/// the gitignored assets/config.json; an empty DSN skips init, so a scaffolded app with no
/// Sentry project yet behaves exactly as it did before.
const sentryDsn = String.fromEnvironment('SENTRY_DSN');

// STACK_AMPLITUDE
/* final Amplitude amplitude = Amplitude(Configuration(
  apiKey: "your-amplitude-api-key",
  flushQueueSize: 1,
)); */

Future<void> main() async {
  // Comment to activate Signals logging
  SignalsObserver.instance = null;

  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  GetIt.instance.registerSingleton(AppRouter());

  await setup();

  // MobileAds.instance.initialize();
  await subscriptionService.initPlatformState();
  await gateService.setup();

  if (sentryDsn.isEmpty) {
    runApp(const MainApp());
    return;
  }
  await SentryFlutter.init(
    (options) {
      options.dsn = sentryDsn;
      options.tracesSampleRate = 0.2;
      options.environment = kDebugMode ? 'development' : 'production';
      options.sendDefaultPii = true;
    },
    appRunner: () => runApp(const MainApp()),
  );
}

Future<void> setup() async {
  // STACK_FIREBASE
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // STACK_SUPABASE
  /*    await Supabase.initialize(
      url: 'https://your-project.supabase.co',
      anonymousKey: 'your-anonymous-key',
  ); */

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
