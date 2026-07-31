# STACK_SUPABASE

Backend/auth provider using Supabase.

Firebase is the template default (see [FIREBASE.md](FIREBASE.md)). Use this guide to switch
an app to Supabase instead.

## Activation Steps

### 1. Swap the annotations

DI selection is by annotation, not by a config key. Exactly one implementation may be
registered against each interface, so this is a swap and not an addition.

Make these active:

```dart
// STACK_SUPABASE
@Singleton(as: AuthService)          // supabase_auth_service.dart
@LazySingleton(as: FeedbackService)  // supabase_feedback_service.dart
```

Comment the Firebase pair out, leaving a plain annotation in place:

```dart
// STACK_FIREBASE
// @Singleton(as: AuthService)
@Singleton()                          // firebase_auth_service.dart
```

### 2. Initialize Supabase in `lib/main.dart`

Uncomment the block in `setup()` marked `// STACK_SUPABASE` and fill in your project URL
and anon key:

```dart
await Supabase.initialize(
    url: 'https://your-project.supabase.co',
    anonymousKey: 'your-anonymous-key',
);
```

### 3. Set the keys in `assets/config.json`

```json
{
  "SUPABASE_URL": "https://your-project.supabase.co",
  "SUPABASE_ANON_KEY": "your-anonymous-key"
}
```

### 4. Remove Firebase references from `lib/main.dart`

Comment out or delete the Firebase init block marked `// STACK_FIREBASE`, and remove these
imports:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:slapp/app/firebase_options.dart';
```

A Supabase app has no `android/app/google-services.json`, and the Google Services Gradle
plugin is applied only when that file exists, so the Android build needs no change.

### 5. Allow the password-reset redirect

Add the app's deep link to the **Redirect URLs** allow-list on the Supabase project. The
link is built from `AppConfig.urlScheme` and `AppConfig.urlHost` in `lib/app/config.dart`.
Supabase substitutes the project's Site URL for a redirect that is not on the list instead
of returning an error, so a missing entry fails silently.

### 6. Regenerate

Run `./tool/codegen.sh` — never plain `build_runner`, never `--delete-conflicting-outputs`
— and read `lib/app/get_it.config.dart` to check it holds one `AuthService` and one
`FeedbackService` registration, both pointing at the Supabase implementations.

## Active Services

- `lib/features/auth/services/supabase_auth_service.dart`
- `lib/features/feedback/services/supabase_feedback_service.dart`

## Competing Code

Their `as: <Interface>` lines stay commented out:

- `lib/features/auth/services/firebase_auth_service.dart`
- `lib/features/feedback/services/firebase_feedback_service.dart`
- `lib/features/feedback/services/pocketbase_feedback_service.dart`

`lib/app/firebase_options.dart` can be deleted once no file imports it.

## Verify

```bash
flutter test test/stack/stack_selection_test.dart    # one implementation per interface
flutter test test/auth/password_reset_link_test.dart # scheme agrees across all three files
```
