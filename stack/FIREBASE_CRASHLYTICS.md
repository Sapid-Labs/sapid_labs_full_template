# STACK_FIREBASE_CRASHLYTICS

Crash reporting using Firebase Crashlytics.

## Prerequisites

Firebase must be initialized first. See [FIREBASE.md](FIREBASE.md).

## Activation Steps

### 1. Set stack in `assets/config.json`

```json
{
  "STACK_CRASHLYTICS": "firebaseCrashlytics"
}
```

### 2. Enable error handler in `lib/main.dart`

Uncomment this line inside the Firebase init block (line 49):

```dart
FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
```

This is part of the Firebase init block -- if you already uncommented that block for FIREBASE setup, this line is included.

## Active Services

- `lib/features/shared/services/crash/firebase_crash_service.dart`

## Competing Code to Delete

- `lib/features/shared/services/crash/sentry_crash_service.dart`
