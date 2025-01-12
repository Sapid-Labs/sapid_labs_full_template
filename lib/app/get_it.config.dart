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

import '../features/auth/services/auth_service.dart' as _i413;
import '../features/settings/services/settings_service.dart' as _i542;
import '../features/shared/services/analytics_service.dart' as _i751;
import '../features/shared/services/modules.dart' as _i176;
import '../features/shared/services/permission_service.dart' as _i901;
import '../features/subscriptions/services/subscription_service.dart' as _i506;

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
  gh.singleton<_i413.AuthService>(() => _i413.AuthService());
  gh.singleton<_i506.SubscriptionService>(() => _i506.SubscriptionService());
  gh.lazySingleton<_i751.AnalyticsService>(() => _i751.AnalyticsService());
  return getIt;
}

class _$RegisterModule extends _i176.RegisterModule {}
