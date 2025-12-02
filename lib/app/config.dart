import 'package:flutter/material.dart';
import 'package:slapp/features/subscriptions/models/subscription_feature.dart';

class AppConfig {
  static const String appName = 'Sapid Labs';
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
