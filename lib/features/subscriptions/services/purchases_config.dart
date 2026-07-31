import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// The RevenueCat API key for this platform, or an empty string.
///
/// Defined out of the gitignored `assets/config.json` by
/// `--dart-define-from-file`. A build made without that flag gets an empty
/// string here, and `String.fromEnvironment` cannot tell you that it did.
String get purchasesApiKey {
  if (kIsWeb) return '';
  if (Platform.isAndroid) {
    return const String.fromEnvironment('REVENUECAT_GOOGLE_API_KEY');
  }
  if (Platform.isIOS || Platform.isMacOS) {
    return const String.fromEnvironment('REVENUECAT_IOS_API_KEY');
  }
  return '';
}

/// Say out loud that this build cannot sell anything.
///
/// An empty key used to reach `Purchases.configure`, which throws into a
/// `catch` that only calls `debugPrint`. The result on a release build is a
/// paywall that never loads an offering, every user on the free tier, and
/// nothing at all in any log a person or the loop can read. Report it as an
/// error instead: a shipped app that cannot take money is the single most
/// expensive defect this portfolio has.
///
/// Debug and profile builds run without the config file all the time, so they
/// only print.
void reportMissingPurchasesKey(String app) {
  debugPrint(
    'SubscriptionService: no RevenueCat API key. Run with '
    '--dart-define-from-file=assets/config.json.',
  );
  if (!kReleaseMode) return;
  Sentry.captureMessage(
    'RevenueCat API key is empty in a release build of $app. The build is '
    'missing assets/config.json, so no user can subscribe.',
    level: SentryLevel.error,
  );
}
