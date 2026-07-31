# STACK_FIREBASE_ANALYTICS

> Activating by hand is what this guide describes, and it still works.
> `./tool/stack.py --analytics firebase ...` does the same swap plus the parts that
> fail silently: it deletes the rival files, drops the SDKs the app no longer
> calls, and toggles the `lib/main.dart` blocks. Prefer it.


Analytics provider using Firebase Analytics.

## Status

**Firebase Analytics is the default.** `FirebaseAnalyticsService` carries the active
`@LazySingleton(as: AnalyticsService)` annotation, and Amplitude's is commented out beside
it. A fresh clone needs nothing here except a Firebase project.

## Prerequisites

Firebase must be initialized first. See [FIREBASE.md](FIREBASE.md).

## Activation Steps

### 1. Check the annotations

DI selection is by annotation, not by a config key. Exactly one analytics service may be
registered as `AnalyticsService`:

- `lib/features/analytics/services/firebase_analytics_service.dart` —
  `@LazySingleton(as: AnalyticsService)` active
- `lib/features/analytics/services/amplitude_analytics_service.dart` — that line commented
  out, plain `@LazySingleton()` in its place

This is how the repo already ships. Run `./tool/codegen.sh` after any change and read
`lib/app/get_it.config.dart` to check it holds one `AnalyticsService` registration.

### 2. Navigation observer

Nothing to change. `AnalyticsNavigationObserver` reports through `analyticsService`,
so its page-view events go to whichever implementation is registered. Uncomment the
`navigatorObservers` block in `lib/main.dart` to switch page-view tracking on.

## Active Services

- `lib/features/analytics/services/firebase_analytics_service.dart`

## Competing Code

- `lib/features/analytics/services/amplitude_analytics_service.dart` — its
  `as: AnalyticsService` line stays commented out.
- The Amplitude import and instance blocks in `lib/main.dart`, both marked
  `// STACK_AMPLITUDE`, stay commented out too.

## Verify

```bash
flutter test test/stack/stack_selection_test.dart   # one implementation per interface
flutter test test/analytics/analytics_stack_test.dart
```
