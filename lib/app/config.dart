import 'package:flutter/material.dart';
import 'package:slapp/features/subscriptions/models/subscription_feature.dart';

class AppConfig {
  static const String appName = 'Sapid Labs';

  /// The custom URL scheme this app claims, lowercase and with no spaces.
  ///
  /// Do not derive this from [appName]. A scheme must be lowercase and cannot
  /// contain a space, so `appName.toLowerCase()` gives 'sapid labs' here, which
  /// no platform can register. Change this together with the `android:scheme`
  /// filter in `android/app/src/main/AndroidManifest.xml` and
  /// `CFBundleURLSchemes` in `ios/Runner/Info.plist`;
  /// `test/auth/password_reset_link_test.dart` fails when the three disagree.
  static const String urlScheme = 'slapp';

  /// The host half of the deep link, claimed beside [urlScheme] in the same
  /// two platform files.
  static const String urlHost = 'slapp.com';

  static const String instagramUsername = 'sapidlabs';
  static const String threadsUsername = 'sapid_labs';
  static const String cta = "Build A Better App";
  static const bool allowAnonymousUsers = true;
  static const List<String> vipEmails = [];
}

List<SubscriptionFeature> features = [
  SubscriptionFeature(
    title: 'Track all your supplements',
    description: 'Keep tabs on your daily intake and health goals',
    icon: Icons.medication,
  ),
  SubscriptionFeature(
    title: 'Build the best stack',
    description: 'Create personalized supplement stacks for optimal health',
    icon: Icons.build,
  ),
  SubscriptionFeature(
    title: 'Stay in the know',
    description: 'Get the latest news and updates on supplements',
    icon: Icons.whatshot,
  ),
];
