# STACK_MOBILE_ADS

Google Mobile Ads integration. Independent of other stacks.

## Activation Steps

### 1. Initialize ads in `lib/main.dart`

Uncomment line 37:

```dart
MobileAds.instance.initialize();
```

### 2. Configure ad unit IDs

Update ad unit IDs in your ad widgets. The template includes `lib/features/shared/ui/banner_ad.dart` for banner ads.

### 3. Platform setup

- **Android**: Add your AdMob app ID to `android/app/src/main/AndroidManifest.xml`
- **iOS**: Add your AdMob app ID to `ios/Runner/Info.plist`

## No Competing Code

Ads are independent of the backend/analytics/crash stacks. Nothing to delete.
