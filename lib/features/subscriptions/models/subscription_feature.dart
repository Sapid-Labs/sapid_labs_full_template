import 'package:flutter/widgets.dart';

class SubscriptionFeature {
  final String title;
  final String? description;
  final IconData icon;
  final Color? color;

  const SubscriptionFeature({
    required this.title,
    this.description,
    required this.icon,
    this.color,
  });
}
