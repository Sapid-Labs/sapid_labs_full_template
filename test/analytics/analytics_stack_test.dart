import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the analytics stack scheme against the failure it has already had twice.
///
/// `navigation_observers.dart` used to hold its own `Amplitude` instance and call
/// the SDK directly, and `AnalyticsService` used to carry method bodies that built
/// both vendor services. Either one sends an app's events to a vendor it did not
/// select, and neither shows up as an analyzer error or a runtime exception — the
/// events simply go nowhere. Both are cheap to reintroduce by hand, so they are
/// checked here rather than left to code review.
void main() {
  /// The one file each vendor SDK is allowed to appear in.
  const owners = <String, String>{
    'package:amplitude_flutter/':
        'lib/features/analytics/services/amplitude_analytics_service.dart',
    'package:firebase_analytics/':
        'lib/features/analytics/services/firebase_analytics_service.dart',
    'package:posthog_flutter/':
        'lib/features/analytics/services/posthog_analytics_service.dart',
  };

  test('a vendor analytics SDK is imported only by its own service', () {
    final offenders = <String>[];

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;

      // Read the code, not the commented-out stack alternatives beside it.
      final code = entity
          .readAsLinesSync()
          .where((line) => !line.trimLeft().startsWith('//'))
          .join('\n');

      for (final entry in owners.entries) {
        if (entity.path == entry.value) continue;
        if (code.contains(entry.key)) {
          offenders.add('${entity.path} imports ${entry.key}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Call analyticsService instead. A vendor SDK reached from anywhere '
          'but its own service bypasses the stack selection, so the events go to '
          'whichever vendor was hardcoded rather than the one this app registered.',
    );
  });

  test('AnalyticsService is an interface, not an implementation', () {
    // Comments explain why the vendors are absent, so read the code alone.
    final source =
        File('lib/features/analytics/services/analytics_service.dart')
            .readAsLinesSync()
            .where((line) => !line.trimLeft().startsWith('//'))
            .join('\n');

    for (final vendor in const [
      'AmplitudeAnalyticsService',
      'FirebaseAnalyticsService',
      'PostHogAnalyticsService',
    ]) {
      expect(
        source.contains(vendor),
        isFalse,
        reason: 'AnalyticsService names $vendor. The base class must not know '
            'about any implementation — that is what get_it registration is for.',
      );
    }

    // No method bodies: every declaration ends at its semicolon.
    expect(
      source.contains('{\n    '),
      isFalse,
      reason: 'AnalyticsService has a method body. Declare the methods abstract '
          'and let each vendor service implement them.',
    );
  });
}
