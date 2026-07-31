import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:slapp/features/analytics/services/analytics_service.dart';

// STACK_NO_ANALYTICS
// The analytics backend for an app that has not picked one yet. Every call site
// already goes through `analyticsService`, so adding Amplitude or Firebase later is
// a swap of this annotation rather than a hunt for the places that log an event.
// @LazySingleton(as: AnalyticsService)
@LazySingleton()
class NoopAnalyticsService implements AnalyticsService {
  @override
  Future<void> setup() async {}

  @override
  Future<void> setUserProperties(Map<String, dynamic> properties) async {}

  @override
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    if (kDebugMode) debugPrint('analytics (not sent): $name $parameters');
  }

  @override
  void updateVersionId(String? versionId, {String? userId}) {}
}
