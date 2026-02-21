import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:amplitude_flutter/events/base_event.dart';
import 'package:amplitude_flutter/events/identify.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:slapp/features/analytics/services/analytics_service.dart';
import 'package:injectable/injectable.dart';

// STACK_AMPLITUDE
// @LazySingleton(as: AnalyticsService)
@LazySingleton()
class AmplitudeAnalyticsService implements AnalyticsService {
  final Amplitude amplitude = Amplitude(
      Configuration(apiKey: const String.fromEnvironment("AMPLITUDE_API_KEY")));

  @override
  Future<void> setup() async {
    await amplitude.isBuilt;

    if (kIsWeb) {
      PackageInfo info = await PackageInfo.fromPlatform();
      updateVersionId(info.version);
    }
  }

  @override
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    final Identify identify = Identify();
    properties.forEach((k, v) {
      identify..set(k, v);
    });
    amplitude.identify(identify);
  }

  @override
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    amplitude.track(
      BaseEvent(name, eventProperties: parameters),
    );
  }

  @override
  void updateVersionId(String? versionId, {String? userId}) {
    if (kIsWeb) {
      final Identify identify = Identify();
      identify..set('app_version', versionId);

      amplitude.identify(identify);
    }
  }
}
