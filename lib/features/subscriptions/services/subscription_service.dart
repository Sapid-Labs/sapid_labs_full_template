import 'package:slapp/app/constants.dart';
import 'package:slapp/app/router.dart';
import 'package:slapp/app/services.dart';
import 'package:slapp/features/auth/services/auth_service.dart';
import 'package:slapp/features/shared/ui/app_name.dart';
import 'package:slapp/features/shared/utils/text_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:io' show Platform;

import 'package:signals/signals_flutter.dart';

final subscriptionPremium = signal<bool>(false);
final subscriptionOffering = signal<Offering?>(null);

@singleton
class SubscriptionService extends ChangeNotifier {
  String _premiumId = 'premium';

  void setOffering(Offering? val) {
    subscriptionOffering.value = val;
  }

  void setPremium(bool val) {
    subscriptionPremium.value = val;
    notifyListeners();
  }

  Future<void> initPlatformState() async {
    try {
      if (kIsWeb) {
        return;
      }
      await Purchases.setDebugLogsEnabled(true);

      late PurchasesConfiguration configuration;
      if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(
            const String.fromEnvironment('google_sdk_key'));
        if (false) {
          // use your preferred way to determine if this build is for Amazon store
          // checkout our MagicWeather sample for a suggestion
          configuration = AmazonConfiguration(
              const String.fromEnvironment('amazon_sdk_key'));
        }
      } else if (Platform.isIOS) {
        configuration =
            PurchasesConfiguration(const String.fromEnvironment('ios_sdk_key'));
      }

      await Purchases.configure(configuration..appUserID = authUserId.value);

      await userSetup();

      Purchases.addCustomerInfoUpdateListener((purchaserInfo) {
        debugPrint(
            'purchaserInfo.activeSubscriptions: ${purchaserInfo.activeSubscriptions}');
        debugPrint(
            'purchaserInfo.entitlements.all: ${purchaserInfo.entitlements.all}');
        debugPrint(
            'purchaserInfo.entitlements.active: ${purchaserInfo.entitlements.active}');
        debugPrint(
            'purchaserInfo.entitlements.all[_premiumId]: ${purchaserInfo.entitlements.all[_premiumId]}');
        debugPrint(
            'purchaserInfo.allExpirationDates: ${purchaserInfo.allExpirationDates}');
        // handle any changes to purchaserInfo
        if (purchaserInfo.entitlements.all[_premiumId]?.isActive ?? false) {
          setPremium(
              purchaserInfo.entitlements.all[_premiumId]?.isActive ?? false);
        }
      });
    } catch (e) {
      debugPrint('Error initializing Purchases: $e');
      // Handle initialization error
    }
  }

  Future<void> userSetup() async {
    if (await Purchases.isConfigured) {
      bool vip = isVip();

      if (vip) {
        setPremium(true);
      } else {
        await checkSubscription();
      }
    } else {
      debugPrint(
          'Purchases is not configured yet. Please call initPlatformState first.');
    }
  }

  Future<void> checkSubscription() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      if (customerInfo.entitlements.all[_premiumId]?.isActive ?? false) {
        // Grant user "pro" access
        setPremium(true);
      }
    } on PlatformException catch (e) {
      // Error fetching purchaser info
      setPremium(false);
    }
  }

  Future<void> fetchOfferings() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        setOffering(offerings.current);
      }
    } on PlatformException catch (e) {
      // optional error handling
    }
  }

  Future<void> purchaseSubscription(Package package) async {
    analyticsService.logEvent('purchase subscription',
        parameters: {'package': package.identifier});
    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      var isPremium =
          customerInfo.entitlements.all[_premiumId]?.isActive ?? false;
      analyticsService.logEvent('purchase subscription success',
          parameters: {'package': package.identifier});
      if (isPremium) {
        setPremium(true);
      }
    } on PlatformException catch (e) {
      analyticsService.logEvent('purchase subscription error',
          parameters: {'package': package.identifier});
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        // showError(e);
      }
    }
  }

  Future<void> showPremiumPopup({
    String? message,
  }) async {
    analyticsService.logEvent('show premium popup');

    await showModalBottomSheet(
      context: router.navigatorKey.currentContext!,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: .7,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                  Theme.of(context).primaryColor.withOpacity(.1),
                  Theme.of(context).canvasColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                AppName(),
                gap8,
                Text(
                  message ??
                      'You need to be a premium member to access this feature.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 250,
                  child: Stack(
                    children: [
                      Positioned(
                          top: 0,
                          left: 0,
                          child: Opacity(
                            opacity: .7,
                            child: Image.asset(
                              'assets/workstation.png',
                              height: 300,
                            ),
                          )),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Image.asset(
                          'assets/feather.png',
                          height: 200,
                        ),
                      ),
                      Positioned(
                          bottom: 0,
                          right: 0,
                          child: Image.asset(
                            'assets/book_stack.png',
                            height: 150,
                          ))
                    ],
                  ),
                ),
                gap16,
                ElevatedButton(
                  onPressed: () {
                    router.maybePop();
                    router.push(SubscriptionRoute());
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                        Theme.of(context).colorScheme.primary),
                  ),
                  child: Text(
                    'Get Premium',
                    style: context.titleLarge.onPrimary.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void signOut() {
    setPremium(false);
  }

  bool isVip() {
    List<String> vipEmails = [
      'test@test.com',
    ];

    return vipEmails.contains(authEmail.value);
  }
}
