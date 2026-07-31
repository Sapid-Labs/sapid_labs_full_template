# STACK_SENTRY

Crash reporting using Sentry.

## Status

**Sentry is the default.** `sentry_flutter` is in `pubspec.yaml`, `SentryCrashService`
calls `Sentry.captureException`, and `lib/main.dart` initializes Sentry when a DSN is set.
A fresh clone needs nothing here except a DSN. Crashlytics has no read API, so no tool can
ask it what is crashing; that is why this is the default rather than Firebase Crashlytics.

## Activation Steps

### 1. Put the DSN in `assets/config.json`

```json
{
  "SENTRY_DSN": "https://<key>@<org>.ingest.sentry.io/<project>"
}
```

An empty or missing `SENTRY_DSN` skips `SentryFlutter.init` and runs the app unchanged, so
an app with no Sentry project yet still builds and runs.

### 2. Check the annotations

DI selection is by annotation, not by config key. Exactly one crash service may be
registered as `CrashService`:

- `lib/features/shared/services/crash/sentry_crash_service.dart` — `@Injectable(as: CrashService)` active
- `lib/features/shared/services/crash/firebase_crash_service.dart` — that line commented out, plain `@Injectable()` in its place

This is how the repo already ships. Run `./tool/codegen.sh` after any change and check
that `lib/app/get_it.config.dart` holds one `CrashService` registration.

## Active Services

- `lib/features/shared/services/crash/sentry_crash_service.dart`

## Competing Code to Delete

- `lib/features/shared/services/crash/firebase_crash_service.dart`
- Remove the `FlutterError.onError = FirebaseCrashlytics...` line from `lib/main.dart`
