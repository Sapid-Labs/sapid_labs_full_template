import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'get_it.config.dart';

const firebaseEnv = Environment('firebase');
const supabaseEnv = Environment('supabase');
const pocketbaseEnv = Environment('pocketbase');
const amplitudeAnalyticsEnv = Environment('amplitude');
const posthogEnv = Environment('posthog');
const firebaseAnalyticsEnv = Environment('firebaseAnalytics');
const firebaseCrashlyticsEnv = Environment('firebaseCrashlytics');
const sentryEnv = Environment('sentry');

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: r'$initGetIt', // default
  preferRelativeImports: true, // default
  asExtension: false, // default
)
Future<void> configureDependencies() async => await $initGetIt(
      getIt,
      environmentFilter: NoEnvOrContainsAny(
        {
          // firebase, supabase, pocketbase
          const String.fromEnvironment('STACK_PAAS', defaultValue: 'firebase'),
          // amplitude, posthog, firebaseAnalytics
          const String.fromEnvironment('STACK_ANALYTICS',
              defaultValue: 'amplitude'),
          // firebaseCrashlytics, sentry
          const String.fromEnvironment('STACK_CRASHLYTICS',
              defaultValue: 'firebaseCrashlytics'),
        },
      ),
    );
