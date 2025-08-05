import 'dart:io';

import 'package:slapp/app/config.dart';
import 'package:slapp/app/constants.dart';
import 'package:slapp/app/services.dart';
import 'package:slapp/features/shared/ui/app_logo.dart';
import 'package:slapp/features/shared/utils/color_utils.dart';
import 'package:slapp/features/shared/utils/text_utils.dart';
import 'package:slapp/features/subscriptions/services/subscription_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:slapp/features/subscriptions/ui/widgets/benefit_card.dart';
import 'package:slapp/features/subscriptions/ui/widgets/feature_row.dart';
import 'package:slapp/features/subscriptions/ui/widgets/free_trial_button.dart';
import 'package:slapp/features/subscriptions/ui/widgets/weekly_plan_button.dart';
import 'package:slapp/features/subscriptions/ui/widgets/yearly_plan_button.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class SubscriptionView extends StatefulWidget {
  const SubscriptionView({Key? key}) : super(key: key);

  @override
  State<SubscriptionView> createState() => _SubscriptionViewState();
}

class _SubscriptionViewState extends State<SubscriptionView> {
  bool selectedWeekly = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: subscriptionPremium,
      builder: (context, premium, child) {
        if (premium) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Premium Membership'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // Manage subscriptions
                    if (Platform.isIOS) {
                      launchUrl(Uri.parse(
                          "https://apps.apple.com/account/subscriptions"));
                    } else {
                      launchUrl(Uri.parse(
                          'https://play.google.com/store/account/subscriptions'));
                    }
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Hero section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.arrow_downward,
                          size: 80,
                        ),
                        gap16,
                        Text(
                          'You\'re enjoying Premium!',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        gap8,
                        Text(
                          'Thank you for supporting ${AppConfig.appName} ☺️',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  gap24,

                  // Benefits section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'What you\'re enjoying:',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  gap16,

                  Column(
                    children: [
                      ...features
                          .map((feature) => BenefitCard(feature: feature))
                          .toList(),
                    ],
                  ),
                  gap32,
                ],
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('${AppConfig.appName} Premium'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: ValueListenableBuilder(
            valueListenable: subscriptionOffering,
            builder: (context, offerings, child) {
              if (offerings == null) {
                debugPrint('No offerings available');
                return const Center(child: CircularProgressIndicator());
              }

              if (offerings.availablePackages.isEmpty) {
                return const Center(child: Text('No subscriptions available'));
              }

              Package? yearlyPackage = offerings.availablePackages
                  .where((element) => element.packageType == PackageType.annual)
                  .firstOrNull;

              Package? weeklyPackage = offerings.availablePackages
                  .where((element) => element.packageType == PackageType.weekly)
                  .firstOrNull;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hero images section
                    Container(
                      height: 100,
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      child: AppLogo(),
                    ),

                    Center(
                      child: Text(AppConfig.cta,
                          textAlign: TextAlign.center,
                          style: context.titleLarge.bold),
                    ),

                    // Features list
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ...features
                              .map((feature) => FeatureRow(feature: feature))
                              .toList(),
                        ],
                      ),
                    ),

                    gap16,

                    if (yearlyPackage != null)
                      YearlyPlanButton(
                        onTap: () {
                          setState(() {
                            selectedWeekly = false;
                          });
                        },
                        selectedWeekly: selectedWeekly,
                        yearlyPackage: yearlyPackage,
                      ),
                    // Weekly plan
                    if (weeklyPackage != null)
                      WeeklyPlanButton(
                        onTap: () {
                          setState(() {
                            selectedWeekly = true;
                          });
                        },
                        selectedWeekly: selectedWeekly,
                        weeklyPackage: weeklyPackage,
                      ),
                    gap24,

                    // Start Free Trial button
                    FreeTrialButton(
                      offerings: offerings,
                      selectedWeekly: selectedWeekly,
                      weeklyPackage: weeklyPackage,
                      yearlyPackage: yearlyPackage,
                      onTap: () async {
                        Package selectedPackage;
                        if (selectedWeekly && weeklyPackage != null) {
                          selectedPackage = weeklyPackage;
                        } else if (!selectedWeekly && yearlyPackage != null) {
                          selectedPackage = yearlyPackage;
                        } else {
                          // Fallback to any available package
                          selectedPackage = offerings.availablePackages.first;
                        }
                        await subscriptionService
                            .purchaseSubscription(selectedPackage);
                      },
                    ),
                    gap16,
                    Row(
                      children: [
                        if (Platform.isIOS) ...[
                          TextButton(
                            child: Text('Redeem Code'),
                            onPressed: () async {
                              await Purchases.presentCodeRedemptionSheet();
                            },
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: SizedBox(
                              height: 8,
                              child: VerticalDivider(
                                color: context.outline,
                                width: 1,
                              ),
                            ),
                          ),
                        ],
                        TextButton(
                          child: Text("Restore Purchases"),
                          onPressed: () async {
                            try {
                              CustomerInfo customerInfo =
                                  await Purchases.restorePurchases();

                              debugPrint(
                                  'Customer info: ${customerInfo.toString()}');

                              subscriptionService.checkSubscription();
                            } on PlatformException catch (e) {
                              debugPrint('Error restoring purchases: $e');
                            } catch (e) {
                              debugPrint('Error restoring purchases: $e');
                            }
                          },
                        ),
                      ],
                    ),

                    gap24,
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
