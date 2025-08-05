import 'package:flutter/material.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';
import 'package:slapp/features/shared/utils/color_utils.dart';
import 'package:slapp/features/shared/utils/text_utils.dart';

class YearlyPlanButton extends StatelessWidget {
  const YearlyPlanButton({
    super.key,
    required this.onTap,
    required this.selectedWeekly,
    required this.yearlyPackage,
  });

  final Function onTap;
  final bool selectedWeekly;
  final Package yearlyPackage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: selectedWeekly ? context.surface : context.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selectedWeekly ? context.outline : context.primary,
            width: selectedWeekly ? 1 : 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Yearly Plan',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: context.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          //'SAVE 90%',
                          '3 DAYS FREE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      /* Text(
                        '\$259.48',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                      ),
                      const SizedBox(width: 8), */
                      Text('${yearlyPackage.storeProduct.priceString} /year',
                          style: context.titleMedium),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: selectedWeekly ? Colors.transparent : context.primary,
                shape: BoxShape.circle,
                border: selectedWeekly
                    ? Border.all(color: context.outline, width: 2)
                    : null,
              ),
              child: selectedWeekly
                  ? null
                  : const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
