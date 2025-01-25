import 'package:foolscript/app/get_it.dart';
import 'package:foolscript/features/analytics/services/analytics_service.dart';
import 'package:injectable/injectable.dart';

@firebaseAnalytics
@LazySingleton(as: AnalyticsService)
class FirebaseAnalyticsService implements AnalyticsService {
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
