import 'package:fools_app_template/features/analytics/services/analytics_service_interface.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class AnalyticsService implements AnalyticsServiceInterface {
  @override
  Future<void> setup() async {
    // TODO: Implement setup logic for AnalyticsService
  }

  @override
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    // TODO: Implement setUserProperties
  }

  @override
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    // TODO: Implement logEvent
  }
}
