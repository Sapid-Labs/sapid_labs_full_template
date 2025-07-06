import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'get_it.config.dart';

const firebase = Environment('firebase');
const supabase = Environment('supabase');
const pocketbase = Environment('pocketbase');
const amplitudeAnalytics = Environment('amplitude');
const posthog = Environment('posthog');
const firebaseAnalytics = Environment('firebaseAnalytics');

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
        },
      ),
    );
