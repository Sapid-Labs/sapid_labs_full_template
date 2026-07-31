# STACK_AMPLITUDE

Analytics provider using Amplitude.

## Activation Steps

### 1. Set stack in `assets/config.json`

```json
{
  "STACK_ANALYTICS": "amplitude",
  "AMPLITUDE_API_KEY": "your-amplitude-api-key"
}
```

### 2. (Optional) Initialize Amplitude instance in `lib/main.dart`

Uncomment the Amplitude initialization block (lines 20-24):

```dart
final Amplitude amplitude = Amplitude(Configuration(
  apiKey: "your-amplitude-api-key",
  flushQueueSize: 1,
));
```

### 3. Navigation Observer

`AnalyticsNavigationObserver` is defined in `lib/features/shared/utils/navigation_observers.dart` and wired in the commented `navigatorObservers` block of `lib/main.dart`. It reports through `analyticsService` rather than the Amplitude SDK, so it needs no change when you switch analytics vendors.

## Active Services

- `lib/features/analytics/services/amplitude_analytics_service.dart`

## Competing Code to Delete

- `lib/features/analytics/services/firebase_analytics_service.dart`
