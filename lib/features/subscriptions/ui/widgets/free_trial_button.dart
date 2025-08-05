import 'package:flutter/material.dart';
import 'package:purchases_flutter/object_wrappers.dart';
import 'package:slapp/app/services.dart';
import 'package:slapp/features/shared/utils/color_utils.dart';
import 'package:slapp/features/shared/utils/text_utils.dart';

class FreeTrialButton extends StatelessWidget {
  const FreeTrialButton({
    super.key,
    required this.selectedWeekly,
    this.weeklyPackage,
    this.yearlyPackage,
    required this.onTap,
    required this.offerings,
  });

  final Offering offerings;
  final bool selectedWeekly;
  final Package? weeklyPackage;
  final Package? yearlyPackage;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () async {
          // Use selected package based on user choice
          Package selectedPackage;
          if (selectedWeekly && weeklyPackage != null) {
            selectedPackage = weeklyPackage!;
          } else if (!selectedWeekly && yearlyPackage != null) {
            selectedPackage = yearlyPackage!;
          } else {
            // Fallback to any available package
            selectedPackage = offerings.availablePackages.first;
          }
          await subscriptionService.purchaseSubscription(selectedPackage);
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
              selectedWeekly ? 'Start Tracking' : 'Start Free Trial',
              style: context.titleLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
