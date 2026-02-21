import 'package:slapp/app/config.dart';
import 'package:slapp/app/services.dart';
import 'package:slapp/features/auth/services/auth_service.dart';
import 'package:slapp/features/subscriptions/ui/premium_popup.dart';
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
    /* log(level: LogLevel.info.index, 'Setting offering: $val'); */
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
            const String.fromEnvironment('REVENUECAT_GOOGLE_API_KEY'));
      } else if (Platform.isIOS) {
        configuration = PurchasesConfiguration(
            const String.fromEnvironment('REVENUECAT_IOS_API_KEY'));
      }

      await Purchases.configure(configuration..appUserID = authUserId.value);

      await userSetup();
      await fetchOfferings();

      Purchases.addCustomerInfoUpdateListener((purchaserInfo) {
        debugPrint('purchaserInfo.activeSubscriptions: ' +
            purchaserInfo.activeSubscriptions.toString());
        debugPrint('purchaserInfo.entitlements.all: ' +
            purchaserInfo.entitlements.all.toString());
        debugPrint('purchaserInfo.entitlements.active: ' +
            purchaserInfo.entitlements.active.toString());
        debugPrint('purchaserInfo.entitlements.all[_premiumId]: ' +
            purchaserInfo.entitlements.all[_premiumId].toString());
        debugPrint('purchaserInfo.allExpirationDates: ' +
            (purchaserInfo.allExpirationDates.toString()));
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

      // todo check if user is out of free stuff
      if (authUserId.value != null) {}
    } else {
      debugPrint(
          'Purchases is not configured yet. Please call initPlatformState first.');
    }
  }

  Future<void> checkSubscription() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      if (customerInfo.entitlements.active.containsKey(_premiumId)) {
        debugPrint('User has an active subscription for $_premiumId');
        setPremium(true);
      } else {
        debugPrint(
          'User does not have an active subscription for $_premiumId',
        );
      }
    } on PlatformException catch (e) {
      // Error fetching purchaser info
      setPremium(false);
    } catch (e) {
      debugPrint('Error checking subscription: $e');
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
      debugPrint('Error fetching offerings: $e');
    } catch (e) {
      debugPrint('Error fetching offerings: $e');
      // Handle other errors
    }
  }

  Future<void> purchaseSubscription(Package package) async {
    analyticsService.logEvent('purchase subscription', parameters: {
      'package': package.identifier,
    });
    try {
      PurchaseParams params = PurchaseParams.package(package);
      PurchaseResult purchaseResult = await Purchases.purchase(params);
      var isPremium = purchaseResult.customerInfo.entitlements.active
          .containsKey(_premiumId);
      analyticsService.logEvent('purchase subscription success', parameters: {
        'package': package.identifier,
      });
      if (isPremium) {
        setPremium(true);
      }
    } on PlatformException catch (e) {
      analyticsService.logEvent('purchase subscription error', parameters: {
        'package': package.identifier,
      });
      debugPrint('Error purchasing subscription: $e');
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        // showError(e);
      }
    } catch (e) {
      analyticsService.logEvent('purchase subscription error', parameters: {
        'package': package.identifier,
      });
      debugPrint('Error purchasing subscription: $e');
      // Handle other errors
    }
  }

  Future<void> showPremiumPopup({
    String? message,
  }) async {
    analyticsService.logEvent('show premium popup', parameters: {
      'message': message ??
          'You need to be a premium member to access this feature.',
    });

    await showModalBottomSheet(
      context: router.navigatorKey.currentContext!,
      isScrollControlled: true,
      isDismissible: false, // Prevent dismissing until timer ends
      enableDrag: false, // Prevent dragging to dismiss
      barrierColor: Colors.black54,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return PremiumPopupContent();
      },
    );
  }

  void signOut() {
    setPremium(false);
  }

  bool isVip() {
    List<String> vipEmails = AppConfig.vipEmails;

    return vipEmails.contains(authEmail.value);
  }
}
