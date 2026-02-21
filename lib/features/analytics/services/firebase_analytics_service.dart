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
    await FirebaseAnalytics.instance.logEvent(
      name: name,
      parameters: parameters as Map<String, Object>,
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
