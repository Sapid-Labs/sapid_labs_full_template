import 'package:flutter/material.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';
import 'package:slapp/app/config.dart';
import 'package:slapp/app/constants.dart';
import 'package:slapp/features/shared/ui/app_logo.dart';
import 'package:slapp/features/shared/utils/text_utils.dart';
import 'package:slapp/features/subscriptions/services/subscription_service.dart';
import 'package:slapp/features/subscriptions/ui/widgets/feature_row.dart';
import 'package:slapp/features/subscriptions/ui/widgets/free_trial_button.dart';
import 'package:slapp/features/subscriptions/ui/widgets/plan_button.dart';

class PremiumPopupContent extends StatefulWidget {
  const PremiumPopupContent();

  @override
  State<PremiumPopupContent> createState() => PremiumPopupContentState();
}

class PremiumPopupContentState extends State<PremiumPopupContent> {
  bool canDismiss = false;
  int countdown = 3;
  String selectedPlan = 'yearly';

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && countdown > 0) {
        setState(() {
          countdown--;
        });
        if (countdown > 0) {
          _startCountdown();
        } else {
          setState(() {
            canDismiss = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canDismiss,
      child: StatefulBuilder(
        builder: (context, setState) {
          return SafeArea(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Container(
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    title: const Text('${AppConfig.appName} Premium'),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: canDismiss
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )
                        : Container(
                            padding: const EdgeInsets.all(12),
                            child: CircleAvatar(
                              backgroundColor: Colors.grey.shade200,
                              child: Text(
                                '$countdown',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                  ),
                  body: ValueListenableBuilder(
                    valueListenable: subscriptionOffering,
                    builder: (context, offerings, child) {
                      if (offerings == null) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (offerings.availablePackages.isEmpty) {
                        return const Center(
                          child: Text('No subscriptions available'),
                        );
                      }

                      Package? yearlyPackage = offerings.availablePackages
                          .where(
                            (element) =>
                                element.packageType == PackageType.annual,
                          )
                          .firstOrNull;

                      Package? monthlyPackage = offerings.availablePackages
                          .where(
                            (element) =>
                                element.packageType == PackageType.monthly,
                          )
                          .firstOrNull;

                      Package? weeklyPackage = offerings.availablePackages
                          .where(
                            (element) =>
                                element.packageType == PackageType.weekly,
                          )
                          .firstOrNull;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Hero images section
                            Container(
                              height: 160,
                              margin: const EdgeInsets.symmetric(vertical: 16),
                              child: AppLogo(),
                            ),

                            Center(
                              child: Text(
                                AppConfig.cta,
                                textAlign: TextAlign.center,
                                style: context.titleLarge.bold,
                              ),
                            ),

                            // Features list
                            Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  ...features
                                      .map(
                                        (feature) =>
                                            FeatureRow(feature: feature),
                                      )
                                      .toList(),
                                ],
                              ),
                            ),

                            gap16,

                            // Yearly plan with discount
                            if (yearlyPackage != null)
                              PlanButton(
                                onTap: () {
                                  setState(() {
                                    selectedPlan = 'yearly';
                                  });
                                },
                                isSelected: selectedPlan == 'yearly',
                                package: yearlyPackage,
                                periodLabel: '/year',
                                planTitle: 'Yearly Plan',
                                badgeText: '3 DAYS FREE',
                              ),
                            if (monthlyPackage != null)
                              PlanButton(
                                onTap: () {
                                  setState(() {
                                    selectedPlan = 'monthly';
                                  });
                                },
                                isSelected: selectedPlan == 'monthly',
                                package: monthlyPackage,
                                periodLabel: '/month',
                                planTitle: 'Monthly Plan',
                              ),
                            // Weekly plan
                            if (weeklyPackage != null)
                              PlanButton(
                                onTap: () {
                                  setState(() {
                                    selectedPlan = 'weekly';
                                  });
                                },
                                isSelected: selectedPlan == 'weekly',
                                package: weeklyPackage,
                                periodLabel: '/week',
                                planTitle: 'Weekly Plan',
                              ),

                            gap24,

                            // Start Free Trial button
                            FreeTrialButton(
                              offerings: offerings,
                              freeTrialEnabled: selectedPlan == 'yearly',
                              package: selectedPlan == 'weekly'
                                  ? weeklyPackage!
                                  : selectedPlan == 'monthly'
                                      ? monthlyPackage!
                                      : yearlyPackage!,
                            ),
                            gap48,
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
