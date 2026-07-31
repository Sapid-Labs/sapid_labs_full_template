import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:slapp/features/analytics/services/analytics_service.dart';
import 'package:injectable/injectable.dart';

// STACK_FIREBASE_ANALYTICS
@LazySingleton(as: AnalyticsService)
class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  Future<void> setup() async {}

  @override
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    properties.forEach((k, v) async {
      await FirebaseAnalytics.instance.setUserProperty(
        name: k,
        value: v,
      );
    });
  }

  @override
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    // Do not cast the map. `parameters` is a Map<String, dynamic> and may be
    // null, so `parameters as Map<String, Object>` throws a TypeError on every
    // call. Copy the non-null entries into the type Firebase asks for instead.
    final Map<String, Object>? safeParameters = parameters == null
        ? null
        : <String, Object>{
            for (final entry in parameters.entries)
              if (entry.value != null) entry.key: entry.value as Object,
          };

    await FirebaseAnalytics.instance.logEvent(
      name: name,
      parameters: safeParameters,
    );
  }

  @override
  Future<void> updateVersionId(String? versionId, {String? userId}) async {
    await FirebaseAnalytics.instance.setUserProperty(
      name: "app_version",
      value: versionId,
    );
  }
}
