# STACK_SUPABASE

Backend/auth provider using Supabase.

## Activation Steps

### 1. Initialize Supabase in `lib/main.dart`

Uncomment the Supabase init block in `setup()` (lines 52-55) and fill in your project URL and anon key:

```dart
await Supabase.initialize(
    url: 'https://your-project.supabase.co',
    anonymousKey: 'your-anonymous-key',
);
```

### 2. Set stack in `assets/config.json`

```json
{
  "STACK_PAAS": "supabase",
  "SUPABASE_URL": "https://your-project.supabase.co",
  "SUPABASE_ANON_KEY": "your-anonymous-key"
}
```

### 3. Remove Firebase references from `lib/main.dart`

Remove these imports:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:slapp/app/firebase_options.dart';
```

Keep the Firebase init block commented out (or delete it).

## Active Services

- `lib/features/auth/services/supabase_auth_service.dart`
- `lib/features/feedback/services/supabase_feedback_service.dart`

## Competing Code to Delete

- `lib/features/auth/services/firebase_auth_service.dart`
- `lib/features/feedback/services/firebase_feedback_service.dart`
- `lib/features/feedback/services/pocketbase_feedback_service.dart`
- `lib/app/firebase_options.dart`
