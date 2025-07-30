// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../features/analytics/services/amplitude_analytics_service.dart'
    as _i798;
import '../features/analytics/services/analytics_service.dart' as _i546;
import '../features/analytics/services/firebase_analytics_service.dart'
    as _i1072;
import '../features/auth/services/auth_service.dart' as _i413;
import '../features/auth/services/firebase_auth_service.dart' as _i969;
import '../features/auth/services/supabase_auth_service.dart' as _i57;
import '../features/feedback/services/feedback_service.dart' as _i136;
import '../features/feedback/services/firebase_feedback_service.dart' as _i565;
import '../features/feedback/services/pocketbase_feedback_service.dart'
    as _i145;
import '../features/feedback/services/supabase_feedback_service.dart' as _i891;
import '../features/onboarding%20copy/ui/services/onboarding_service.dart'
    as _i89;
import '../features/settings/services/settings_service.dart' as _i542;
import '../features/shared/services/ai_service.dart' as _i567;
import '../features/shared/services/modules.dart' as _i176;
import '../features/shared/services/permission_service.dart' as _i901;
import '../features/subscriptions/services/subscription_service.dart' as _i506;

const String _pocketbase = 'pocketbase';
const String _firebase = 'firebase';
const String _supabase = 'supabase';
const String _firebaseAnalytics = 'firebaseAnalytics';
const String _amplitude = 'amplitude';

// initializes the registration of main-scope dependencies inside of GetIt
Future<_i174.GetIt> $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) async {
  final gh = _i526.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  final registerModule = _$RegisterModule();
  gh.factory<_i901.PermissionService>(() => _i901.PermissionService());
  await gh.factoryAsync<_i460.SharedPreferences>(
    () => registerModule.sharedPrefs,
    preResolve: true,
  );
  gh.singleton<_i542.SettingsService>(() => _i542.SettingsService());
  gh.singleton<_i506.SubscriptionService>(() => _i506.SubscriptionService());
  gh.singleton<_i89.OnboardingService>(() => _i89.OnboardingService());
  gh.lazySingleton<_i567.AIService>(() => _i567.AIService());
  gh.lazySingleton<_i136.FeedbackService>(
    () => _i145.PocketbaseFeedbackService(),
    registerFor: {_pocketbase},
  );
  gh.singleton<_i413.AuthService>(
    () => _i969.FirebaseAuthService(),
    registerFor: {_firebase},
  );
  gh.lazySingleton<_i136.FeedbackService>(
    () => _i891.SupabaseFeedbackService(),
    registerFor: {_supabase},
  );
  gh.lazySingleton<_i546.AnalyticsService>(
    () => _i1072.FirebaseAnalyticsService(),
    registerFor: {_firebaseAnalytics},
  );
  gh.singleton<_i413.AuthService>(
    () => _i57.SupabaseAuthService(),
    registerFor: {_supabase},
  );
  gh.lazySingleton<_i136.FeedbackService>(
    () => _i565.FirebaseFeedbackService(),
    registerFor: {_firebase},
  );
  gh.lazySingleton<_i546.AnalyticsService>(
    () => _i798.AmplitudeAnalyticsService(),
    registerFor: {_amplitude},
  );
  return getIt;
}

class _$RegisterModule extends _i176.RegisterModule {}
