import 'package:flutter/material.dart';
import 'package:slapp/features/shared/utils/color_utils.dart';
import 'package:slapp/features/shared/utils/text_utils.dart';
import 'package:slapp/features/subscriptions/models/subscription_feature.dart';

class FeatureRow extends StatelessWidget {
  const FeatureRow({super.key, required this.feature});

  final SubscriptionFeature feature;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: context.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              feature.icon,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(feature.title, style: context.bodyLarge.bold),
          ),
        ],
      ),
    );
  }
}
