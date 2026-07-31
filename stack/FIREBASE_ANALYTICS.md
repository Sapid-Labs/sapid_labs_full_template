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

### 2. Navigation observer

Nothing to change. `AnalyticsNavigationObserver` reports through `analyticsService`,
so its page-view events go to whichever implementation is registered. Uncomment the
`navigatorObservers` block in `lib/main.dart` to switch page-view tracking on.

## Active Services

- `lib/features/analytics/services/firebase_analytics_service.dart`

## Competing Code to Delete

- `lib/features/analytics/services/amplitude_analytics_service.dart`
- Remove the Amplitude initialization block (lines 20-24) from `lib/main.dart` if uncommented
