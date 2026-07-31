# STACK_AMPLITUDE

> Activating by hand is what this guide describes, and it still works.
> `./tool/stack.py --analytics amplitude ...` does the same swap plus the parts that
> fail silently: it deletes the rival files, drops the SDKs the app no longer
> calls, and toggles the `lib/main.dart` blocks. Prefer it.


Analytics provider using Amplitude.

Firebase Analytics is the template default (see [FIREBASE_ANALYTICS.md](FIREBASE_ANALYTICS.md)).
Use this guide to switch an app to Amplitude instead.

## Activation Steps

### 1. Swap the annotations

DI selection is by annotation, not by a config key. Exactly one analytics service may be
registered as `AnalyticsService`, so this is a swap and not an addition.

In `lib/features/analytics/services/amplitude_analytics_service.dart`, make the interface
registration active:

```dart
// STACK_AMPLITUDE
@LazySingleton(as: AnalyticsService)
```

In `lib/features/analytics/services/firebase_analytics_service.dart`, comment it out:

```dart
// STACK_FIREBASE_ANALYTICS
// @LazySingleton(as: AnalyticsService)
@LazySingleton()
```

### 2. Put the API key in `assets/config.json`

```json
{
  "AMPLITUDE_API_KEY": "your-amplitude-api-key"
}
```

### 3. Initialize the Amplitude instance in `lib/main.dart`

Uncomment the import block and the instance block, both marked `// STACK_AMPLITUDE`, and
fill in your key:

```dart
final Amplitude amplitude = Amplitude(Configuration(
  apiKey: "your-amplitude-api-key",
  flushQueueSize: 1,
));
```

### 4. Regenerate

Run `./tool/codegen.sh` — never plain `build_runner`, never `--delete-conflicting-outputs`.
Then read `lib/app/get_it.config.dart` and check it holds one `AnalyticsService`
registration, pointing at `AmplitudeAnalyticsService`. Two active registrations compile
without complaint and throw at startup.

### 5. Navigation observer

Nothing to change. `AnalyticsNavigationObserver` is defined in
`lib/features/shared/utils/navigation_observers.dart` and wired in the commented
`navigatorObservers` block of `lib/main.dart`. It reports through `analyticsService` rather
than the Amplitude SDK, so it needs no change when you switch analytics vendors.

## Active Services

- `lib/features/analytics/services/amplitude_analytics_service.dart`

## Competing Code

- `lib/features/analytics/services/firebase_analytics_service.dart` — comment out its
  `as: AnalyticsService` line as shown above. Deleting the file as well is optional; the
  scheme only requires that one implementation claims the interface.

## Verify

```bash
flutter test test/stack/stack_selection_test.dart   # one implementation per interface
flutter test test/analytics/analytics_stack_test.dart
```
