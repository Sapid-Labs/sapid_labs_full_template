import 'package:flutter/material.dart';
import 'package:slapp/features/subscriptions/models/subscription_feature.dart';
import 'package:slapp/features/shared/utils/color_utils.dart';

class BenefitCard extends StatelessWidget {
  BenefitCard({super.key, required this.feature});

  final SubscriptionFeature feature;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: feature.color?.withOpacity(0.3) ?? context.primary,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: feature.color?.withOpacity(0.1) ??
                  context.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              feature.icon,
              color: feature.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (feature.description != null) ...[
                  SizedBox(height: 4),
                  Text(
                    feature.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: feature.color,
            size: 20,
          ),
        ],
      ),
    );
  }
}
