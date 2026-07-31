# STACK_FIREBASE_CRASHLYTICS

> Activating by hand is what this guide describes, and it still works.
> `./tool/stack.py --crash firebase ...` does the same swap plus the parts that
> fail silently: it deletes the rival files, drops the SDKs the app no longer
> calls, and toggles the `lib/main.dart` blocks. Prefer it.


Crash reporting using Firebase Crashlytics.

Sentry is the template default (see [SENTRY.md](SENTRY.md)). Use this guide only when an
app must report to Crashlytics instead. Crashlytics has no read API, so no tool can query
it for what is crashing.

## Prerequisites

Firebase must be initialized first. See [FIREBASE.md](FIREBASE.md).

## Activation Steps

### 1. Swap the annotations

DI selection is by annotation, not by config key. Exactly one crash service may be
registered as `CrashService`, so this is a swap and not an addition.

In `lib/features/shared/services/crash/firebase_crash_service.dart`, make the interface
registration active:

```dart
// STACK_FIREBASE_CRASHLYTICS
@Injectable(as: CrashService)
```

In `lib/features/shared/services/crash/sentry_crash_service.dart`, comment it out:

```dart
// STACK_SENTRY
// @Injectable(as: CrashService)
@Injectable()
```

### 2. Enable the error handler in `lib/main.dart`

Keep this line inside the Firebase init block:

```dart
FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
```

### 3. Regenerate

Run `./tool/codegen.sh` and check that `lib/app/get_it.config.dart` holds one
`CrashService` registration and that it points at `FirebaseCrashService`.

## Active Services

- `lib/features/shared/services/crash/firebase_crash_service.dart`

## Competing Code to Delete

- `lib/features/shared/services/crash/sentry_crash_service.dart`
- Remove the `SentryFlutter.init` block and `SENTRY_DSN` from `lib/main.dart`
