import 'package:fools_app_template/app/get_it.dart';
import 'package:fools_app_template/app/router.dart';
import 'package:fools_app_template/features/auth/services/auth_service.dart';
import 'package:fools_app_template/features/settings/services/settings_service.dart';
import 'package:fools_app_template/features/analytics/services/analytics_service.dart';
import 'package:fools_app_template/features/shared/services/permission_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

AnalyticsService get analyticsService => getIt.get<AnalyticsService>();
AppRouter get router => getIt.get<AppRouter>();
AuthService get authService => getIt.get<AuthService>();
SettingsService get settingsService => getIt.get<SettingsService>();
SharedPreferences get sharedPrefs => getIt.get<SharedPreferences>();
PermissionService get permissionService => getIt.get<PermissionService>();