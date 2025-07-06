import 'package:slapp/features/analytics/services/amplitude_analytics_service.dart';

abstract class AnalyticsService {
  Future<void> setup() async {
    AmplitudeAnalyticsService().setup();
  }

  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    AmplitudeAnalyticsService().setUserProperties(properties);
  }

  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    AmplitudeAnalyticsService().logEvent(name, parameters: parameters);
  }

  void updateVersionId(String? versionId, {String? userId}) {
    AmplitudeAnalyticsService().updateVersionId(versionId);
  }
}
