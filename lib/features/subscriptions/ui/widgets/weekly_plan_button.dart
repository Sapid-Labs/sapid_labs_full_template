import 'package:flutter/material.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';
import 'package:slapp/features/shared/utils/color_utils.dart';
import 'package:slapp/features/shared/utils/text_utils.dart';

class WeeklyPlanButton extends StatelessWidget {
  const WeeklyPlanButton({
    super.key,
    required this.onTap,
    required this.selectedWeekly,
    required this.weeklyPackage,
  });

  final Function onTap;
  final bool selectedWeekly;
  final Package weeklyPackage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
            color:
                selectedWeekly ? context.secondaryContainer : context.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selectedWeekly ? context.primary : context.outline,
              width: selectedWeekly ? 2 : 1,
            )),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly',
                  style: context.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  weeklyPackage.storeProduct.priceString + ' /week',
                  style: context.bodyMedium,
                ),
              ],
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: selectedWeekly ? context.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: selectedWeekly
                    ? null
                    : Border.all(color: Colors.grey, width: 2),
              ),
              child: selectedWeekly
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
