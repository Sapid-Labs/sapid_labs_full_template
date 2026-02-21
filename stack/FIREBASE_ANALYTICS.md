# STACK_FIREBASE_ANALYTICS

Analytics provider using Firebase Analytics.

## Prerequisites

Firebase must be initialized first. See [FIREBASE.md](FIREBASE.md).

## Activation Steps

### 1. Set stack in `assets/config.json`

```json
{
  "STACK_ANALYTICS": "firebaseAnalytics"
}
```

### 2. Fix navigation observer in `lib/main.dart`

The template ships with `AmplitudeNavigationObserver` hardwired in `main.dart` (line 88). Replace it with a Firebase Analytics observer or remove it:

```dart
// Replace this:
AmplitudeNavigationObserver(),

// With a Firebase Analytics observer, or remove the navigatorObservers callback entirely.
```

## Active Services

- `lib/features/analytics/services/firebase_analytics_service.dart`

## Competing Code to Delete

- `lib/features/analytics/services/amplitude_analytics_service.dart`
- Remove the `AmplitudeNavigationObserver` import and usage from `lib/main.dart`
- Remove the Amplitude initialization block (lines 20-24) from `lib/main.dart` if uncommented
