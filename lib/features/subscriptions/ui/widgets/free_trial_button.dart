import 'package:flutter/material.dart';
import 'package:purchases_flutter/object_wrappers.dart';
import 'package:slapp/features/shared/utils/text_utils.dart';
import 'package:slapp/app/services.dart';
import 'package:slapp/features/shared/utils/color_utils.dart';

class FreeTrialButton extends StatelessWidget {
  const FreeTrialButton({
    super.key,
    required this.freeTrialEnabled,
    required this.package,
    required this.offerings,
  });

  final Offering offerings;
  final bool freeTrialEnabled;
  final Package package;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () async {
          await subscriptionService.purchaseSubscription(package);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: context.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              freeTrialEnabled ? 'Start Free Trial' : 'Get Premium',
              style: context.titleLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
