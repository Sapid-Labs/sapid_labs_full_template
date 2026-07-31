# STACK_FIREBASE

> Activating by hand is what this guide describes, and it still works.
> `./tool/stack.py --backend firebase ...` does the same swap plus the parts that
> fail silently: it deletes the rival files, drops the SDKs the app no longer
> calls, and toggles the `lib/main.dart` blocks. Prefer it.


Backend/auth provider using Firebase (Firestore + Firebase Auth).

## Status

**Firebase is the default backend.** `FirebaseAuthService` carries the active
`@Singleton(as: AuthService)` annotation and `FirebaseFeedbackService` the active
`@LazySingleton(as: FeedbackService)`; the Supabase and Pocketbase rivals are commented
out beside them. The Firebase init block in `lib/main.dart` is live.

## Activation Steps

### 1. Check the annotations

DI selection is by annotation, not by a config key. Exactly one implementation may be
registered against each interface:

- `lib/features/auth/services/firebase_auth_service.dart` — `@Singleton(as: AuthService)`
  active
- `lib/features/feedback/services/firebase_feedback_service.dart` —
  `@LazySingleton(as: FeedbackService)` active

This is how the repo already ships.

### 2. Keep the Firebase init block live in `lib/main.dart`

It sits in `setup()` under the `// STACK_FIREBASE` marker:

```dart
await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform);

FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
```

> Sentry is the template's crash backend. Omit the `FlutterError.onError` line unless you
> are activating Crashlytics — see [FIREBASE_CRASHLYTICS.md](FIREBASE_CRASHLYTICS.md).

### 3. Generate Firebase config

```bash
flutterfire configure
```

This generates `lib/app/firebase_options.dart`, which is imported by `main.dart`. It also
writes `android/app/google-services.json`; the Google Services Gradle plugin is applied
only when that file exists, so a Supabase app builds without it.

### 4. (Optional) Set `SERVER_CLIENT_ID` for Google Sign-In

```json
{
  "SERVER_CLIENT_ID": "your_google_client_id"
}
```

### 5. Regenerate

Run `./tool/codegen.sh` — never plain `build_runner`, never `--delete-conflicting-outputs`
— and read `lib/app/get_it.config.dart` to check it holds one `AuthService` and one
`FeedbackService` registration.

## Active Services

- `lib/features/auth/services/firebase_auth_service.dart`
- `lib/features/feedback/services/firebase_feedback_service.dart`

## Competing Code

Their `as: <Interface>` lines stay commented out, with a plain `@Singleton()` or
`@LazySingleton()` in place:

- `lib/features/auth/services/supabase_auth_service.dart`
- `lib/features/feedback/services/supabase_feedback_service.dart`
- `lib/features/feedback/services/pocketbase_feedback_service.dart`

The Supabase init block in `lib/main.dart`, marked `// STACK_SUPABASE`, stays commented out.

## Verify

```bash
flutter test test/stack/stack_selection_test.dart   # one implementation per interface
```
