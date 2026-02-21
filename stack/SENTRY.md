# STACK_SENTRY

Crash reporting using Sentry.

## Status

Sentry support is **stubbed out**. The `SentryCrashService` exists but may be incomplete. The `sentry_flutter` package is not yet in `pubspec.yaml`.

## Activation Steps

### 1. Add the Sentry package

```bash
flutter pub add sentry_flutter
```

### 2. Set stack in `assets/config.json`

```json
{
  "STACK_CRASHLYTICS": "sentry"
}
```

### 3. Initialize Sentry in `lib/main.dart`

Add Sentry initialization (wrap `runApp` or add to `setup()`):

```dart
await SentryFlutter.init(
  (options) {
    options.dsn = 'your-sentry-dsn';
  },
  appRunner: () => runApp(const MainApp()),
);
```

### 4. Verify `SentryCrashService` annotation

Ensure `lib/features/shared/services/crash/sentry_crash_service.dart` has the `@sentryEnv` annotation so it registers correctly with the DI system.

## Active Services

- `lib/features/shared/services/crash/sentry_crash_service.dart`

## Competing Code to Delete

- `lib/features/shared/services/crash/firebase_crash_service.dart`
- Remove Firebase Crashlytics imports and error handler from `lib/main.dart` if present
