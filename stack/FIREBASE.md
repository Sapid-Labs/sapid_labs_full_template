# STACK_FIREBASE

Backend/auth provider using Firebase (Firestore + Firebase Auth).

## Activation Steps

### 1. Initialize Firebase in `lib/main.dart`

Uncomment the Firebase init block in `setup()` (lines 46-49):

```dart
await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform);

FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
```

> If you don't want Crashlytics, omit the `FlutterError.onError` line.

### 2. Generate Firebase config

```bash
flutterfire configure
```

This generates `lib/app/firebase_options.dart`, which is imported by `main.dart`.


### 3. (Optional) Set `SERVER_CLIENT_ID` for Google Sign-In

```json
{
  "SERVER_CLIENT_ID": "your_google_client_id"
}
```

## Active Services

- `lib/features/auth/services/firebase_auth_service.dart`
- `lib/features/feedback/services/firebase_feedback_service.dart`

## Competing Code to Delete

- `lib/features/auth/services/supabase_auth_service.dart`
- `lib/features/feedback/services/supabase_feedback_service.dart`
- `lib/features/feedback/services/pocketbase_feedback_service.dart`

Remove Supabase imports from `lib/main.dart` if present.
