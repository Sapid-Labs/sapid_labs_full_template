import 'dart:io';

import 'package:slapp/app/config.dart';
import 'package:slapp/app/constants.dart';
import 'package:slapp/app/services.dart';
import 'package:slapp/features/shared/utils/color_utils.dart';
import 'package:slapp/features/shared/utils/text_utils.dart';
import 'package:slapp/features/subscriptions/services/subscription_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PremiumFeature {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const PremiumFeature({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

@RoutePage()
class SubscriptionView extends StatefulWidget {
  const SubscriptionView({Key? key}) : super(key: key);

  @override
  State<SubscriptionView> createState() => _SubscriptionViewState();
}

class _SubscriptionViewState extends State<SubscriptionView> {
  bool selectedWeekly = true; // Default to weekly selection

  // List of premium features
  static const List<PremiumFeature> premiumFeatures = [
    PremiumFeature(
      icon: Icons.restaurant_menu,
      title: 'Unlimited Recipes',
      description: 'Access to our entire collection of delicious recipes',
      color: Colors.orange,
    ),
    PremiumFeature(
      icon: Icons.camera_alt,
      title: 'Unlimited Camera Generations',
      description: 'Create recipes from any photo with AI magic',
      color: Colors.blue,
    ),
    PremiumFeature(
      icon: Icons.book,
      title: 'Unlimited Recipe Books',
      description: 'Organize your recipes into beautiful collections',
      color: Colors.green,
    ),
    PremiumFeature(
      icon: Icons.merge_type,
      title: 'Smart Recipe Merging',
      description: 'Combine ingredients and instructions intelligently',
      color: Colors.purple,
    ),
    PremiumFeature(
      icon: Icons.construction,
      title: 'Smart Components',
      description: 'Mix and match components from recipes to build your own',
      color: Colors.teal,
    ),
  ];

  @override
  void initState() {
    subscriptionService.fetchOfferings();
    super.initState();
  }

  Widget _buildFeatureRow(PremiumFeature feature) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFFB71C1C),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            feature.icon,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          feature.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitCard(
    BuildContext context, 
    PremiumFeature feature,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: feature.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: feature.color.withOpacity(0.1),
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
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                ),
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
                          Icons.arrow_upward,
                          size: 200,
                          color: context.primary,
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

                  // Benefits cards
                  ...premiumFeatures.asMap().entries.map((entry) {
                    final index = entry.key;
                    final feature = entry.value;
                    return Column(
                      children: [
                        _buildBenefitCard(context, feature),
                        if (index < premiumFeatures.length - 1) gap12,
                      ],
                    );
                  }).toList(),
                  gap32,
                ],
              ),
            ),
          );
        }
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Bakedown Premium'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: ValueListenableBuilder(
            valueListenable: subscriptionOffering,
            builder: (context, offerings, child) {
              if (offerings == null)
                return const Center(child: CircularProgressIndicator());

              if (offerings.availablePackages.isEmpty)
                return const Center(child: Text('No subscriptions available'));

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
                      height: 200,
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.grey.shade100,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Icon(
                                  Icons.arrow_downward,
                                  size: 200,
                                  color: context.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Arrow pointing from photo to cartoon
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.grey.shade100,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Icon(
                                  Icons.arrow_upward,
                                  size: 200,
                                  color: context.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Features list
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: premiumFeatures.take(4).toList().asMap().entries.map((entry) {
                          final index = entry.key;
                          final feature = entry.value;
                          return Column(
                            children: [
                              _buildFeatureRow(feature),
                              if (index < 3) const SizedBox(height: 12),
                            ],
                          );
                        }).toList(),
                      ),
                    ),

                    gap16,

                    // Yearly plan with discount
                    if (yearlyPackage != null)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedWeekly = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: selectedWeekly
                                ? Colors.grey.shade100
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selectedWeekly
                                  ? Colors.grey.shade300
                                  : const Color(0xFFB71C1C),
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
                                          style: context.titleLarge.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFB71C1C),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: const Text(
                                            'SAVE 90%',
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
                                        Text(
                                          '\$259.48',
                                          style: context.bodyMedium.copyWith(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          yearlyPackage
                                                  .storeProduct.priceString +
                                              ' per year',
                                          style: context.titleMedium.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: selectedWeekly
                                      ? Colors.transparent
                                      : const Color(0xFFB71C1C),
                                  shape: BoxShape.circle,
                                  border: selectedWeekly
                                      ? Border.all(color: Colors.grey, width: 2)
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
                      ),

                    // Weekly plan
                    if (weeklyPackage != null)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedWeekly = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: selectedWeekly
                                ? Colors.white
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selectedWeekly
                                  ? const Color(0xFFB71C1C)
                                  : Colors.grey.shade300,
                              width: selectedWeekly ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '3-Day Trial',
                                    style: context.titleLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'then ' +
                                        weeklyPackage.storeProduct.priceString +
                                        ' per week',
                                    style: context.bodyMedium,
                                  ),
                                ],
                              ),
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: selectedWeekly
                                      ? const Color(0xFFB71C1C)
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: selectedWeekly
                                      ? null
                                      : Border.all(
                                          color: Colors.grey, width: 2),
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
                      ),

                    gap24,

                    // Start Free Trial button
                    Container(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Use selected package based on user choice
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB71C1C),
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
                              'Start Free Trial',
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
                    ),
                    gap16,
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
                          FirebaseCrashlytics.instance.recordError(
                            e,
                            null,
                            reason: 'Error restoring purchases',
                          );
                        } catch (e) {
                          FirebaseCrashlytics.instance.recordError(
                            e,
                            null,
                            reason: 'Error restoring purchases',
                          );
                          debugPrint('Error restoring purchases: $e');
                        }
                      },
                    ),
                    gap24,

                    // Footer links
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            launchUrl(Uri.parse(
                                'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'));
                          },
                          child: Text(
                            'Terms of Use',
                            style: context.bodyMedium.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Text(
                          ' • ',
                          style: context.bodyMedium.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            launchUrl(Uri.parse(
                                'https://bakedown.app/privacy-policy'));
                          },
                          child: Text(
                            'Privacy Policy',
                            style: context.bodyMedium.copyWith(
                              color: Colors.grey,
                            ),
                          ),
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
