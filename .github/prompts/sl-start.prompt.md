---
mode: "agent"
tools: ['codebase', 'editFiles', 'search']
description: "Scaffold a new Flutter application according to the provided guidelines"
---

Your goal is to scaffold a new Flutter application that uses the following directory structure:

## app (lib/app)
Contains app-wide configurations, router, and constants. 
Contains the get_it service locator:

```dart
// app/get_it.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'get_it.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: r'$initGetIt', // default
  preferRelativeImports: true, // default
  asExtension: false, // default
)
Future<void> configureDependencies() async => await $initGetIt(getIt);
```

Contains the services file. This file contains convenience getters for app services:
```dart
// app/services.dart
import 'package:abis_recipes/app/get_it.dart';
import 'package:abis_recipes/app/router.dart';
import 'package:abis_recipes/features/home/services/app_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

AppService get appService => getIt.get<AppService>();
AppRouter get router => getIt.get<AppRouter>();
SharedPreferences get sharedPrefs => getIt.get<SharedPreferences>();
```

## features (lib/features)
Contains all the features of the app, each in its own directory.
Each feature directory contains the following subdirectories:
- `models` - Data models used in the feature
- `services` - Services for data fetching and business logic
- `ui` - UI components and screens. At the root of this component is a `feature_name_view.dart` file that serves as the main entry point for the feature's UI. This directory should also contain a `widgets` subdirectory for reusable widgets specific to the feature.
- (optional) `utils` - Utility functions or classes specific to the feature

## features/shared (lib/features/shared)
Contains shared components, utilities, and widgets that can be reused across multiple features.
Like other feature directories, it contains `models`, `services`, and `ui` subdirectories.

## main.dart

At the root of the `lib` directory, there is a `main.dart` file that initializes the app, sets up the service locator, and configures the router.

```dart
import 'dart:async';
import 'dart:io';

import 'package:abis_recipes/app/get_it.dart';
import 'package:abis_recipes/app/router.dart';
import 'package:abis_recipes/app/services.dart';
import 'package:abis_recipes/features/shared/utils/navigation_observers.dart';
import 'package:abis_recipes/firebase_options.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';

final Amplitude amplitude = Amplitude(Configuration(
  apiKey: const String.fromEnvironment('AMPLITUDE_API_KEY');
  flushQueueSize: 1,
));

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  GetIt.instance.registerFactory(() => httpClient);
  GetIt.instance.registerSingleton(AppRouter());

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  await amplitude.isBuilt;
  await configureDependencies();
  await authService.setup();

  await subscriptionService.initPlatformState();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return MaterialApp.router(
      title: '{{appName}}',
      debugShowCheckedModeBanner: false,
      routerConfig: router.config(
        navigatorObservers: () {
          return [
            AmplitudeNavigationObserver(),
          ];
        },
      ),
      
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: flexSchemeLight,
        fontFamily: GoogleFonts.jost().fontFamily,
        // Other theme configurations
      ),
    );
  }
}

const ColorScheme flexSchemeLight = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xffcd5758),
  onPrimary: Color(0xffffffff),
  primaryContainer: Color(0xffe49797),
  onPrimaryContainer: Color(0xff130d0d),
  secondary: Color(0xff69b9cd),
  onSecondary: Color(0xff000000),
  secondaryContainer: Color(0xffa6edff),
  onSecondaryContainer: Color(0xff0e1414),
  tertiary: Color(0xff57c8d3),
  onTertiary: Color(0xff000000),
  tertiaryContainer: Color(0xff90f2fc),
  onTertiaryContainer: Color(0xff0c1414),
  error: Color(0xff790000),
  onError: Color(0xffffffff),
  errorContainer: Color(0xfff1d8d8),
  onErrorContainer: Color(0xff141212),
  background: Color(0xfffdf9f9),
  onBackground: Color(0xff090909),
  surface: Color(0xfffdf9f9),
  onSurface: Color(0xff090909),
  surfaceVariant: Color(0xfffbf3f3),
  onSurfaceVariant: Color(0xff131313),
  outline: Color(0xff565656),
  shadow: Color(0xff000000),
  inverseSurface: Color(0xff171313),
  onInverseSurface: Color(0xfff5f5f5),
  inversePrimary: Color(0xfffff0f0),
  surfaceTint: Color(0xffcd5758),
);

const ColorScheme flexSchemeDark = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xffda8585),
  onPrimary: Color(0xfffff9f9),
  primaryContainer: Color(0xffc05253),
  onPrimaryContainer: Color(0xfffdecec),
  secondary: Color(0xff85c6d6),
  onSecondary: Color(0xff0e1314),
  secondaryContainer: Color(0xff21859e),
  onSecondaryContainer: Color(0xffe4f4f8),
  tertiary: Color(0xff68cdd7),
  onTertiary: Color(0xff0c1414),
  tertiaryContainer: Color(0xff037481),
  onTertiaryContainer: Color(0xffe0f1f4),
  error: Color(0xffcf6679),
  onError: Color(0xff140c0d),
  errorContainer: Color(0xffb1384e),
  onErrorContainer: Color(0xfffbe8ec),
  background: Color(0xff1c1717),
  onBackground: Color(0xffedecec),
  surface: Color(0xff1c1717),
  onSurface: Color(0xffedecec),
  surfaceVariant: Color(0xff281e1e),
  onSurfaceVariant: Color(0xffdddbdb),
  outline: Color(0xffa39d9d),
  shadow: Color(0xff000000),
  inverseSurface: Color(0xfffcf7f7),
  onInverseSurface: Color(0xff131313),
  inversePrimary: Color(0xff6d4848),
  surfaceTint: Color(0xffda8585),
);
```