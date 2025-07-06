import 'package:sapid_labs/app/get_it.dart';
import 'package:sapid_labs/app/router.dart';
import 'package:sapid_labs/features/analytics/services/analytics_service.dart';
import 'package:sapid_labs/features/auth/services/auth_service.dart';
import 'package:sapid_labs/features/settings/services/settings_service.dart';
import 'package:sapid_labs/features/shared/services/permission_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

AnalyticsService get analyticsService => getIt.get<AnalyticsService>();
AppRouter get router => getIt.get<AppRouter>();
AuthService get authService => getIt.get<AuthService>();
SettingsService get settingsService => getIt.get<SettingsService>();
SharedPreferences get sharedPrefs => getIt.get<SharedPreferences>();
PermissionService get permissionService => getIt.get<PermissionService>();