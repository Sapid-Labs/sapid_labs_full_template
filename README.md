# Sapid Labs Flutter Template

A production-grade Flutter app template with multi-backend support, comprehensive auth, analytics, crash reporting and subscriptions — all pre-wired, and reduced to the one you picked by a single script.

## Why Use This Template

Starting a Flutter app from scratch means wiring up authentication, analytics, crash reporting, routing, state management, dependency injection, and deployment — often taking weeks before you write any feature code. This template gives you all of that out of the box:

- **Multi-backend support** — Firebase, Supabase or Pocketbase, chosen by one command
- **Full auth flows** — Email/password, phone/SMS, Google Sign-In, Apple Sign-In, and anonymous auth, with pre-built sign-in, sign-up, password reset, and account management screens
- **Analytics ready** — Amplitude or Firebase Analytics, or none at all, swappable without touching your feature code
- **Crash reporting** — Sentry or Firebase Crashlytics, or none at all, same swap-friendly pattern
- **Subscriptions** — RevenueCat integration with a paywall UI
- **Deployment** — Fastlane configs for iOS (TestFlight, App Store) and Android (internal, alpha, beta, production)
- **Opinionated architecture** — Signals for state, auto_route for navigation, get_it + injectable for DI, and a clean feature-based folder structure

## Getting Started

Clone this repository and rename it for your project:

```bash
git clone https://github.com/Sapid-Labs/sapidlabs_flutter_template my_app
cd my_app
```

### 1. Rename the App

Search the project for `slapp` and replace it with your app's package name. Then search for `com.sapidlabs` and replace it with your package identifier.

### 2. Configure Your Stack

Pick one provider per category. The script deletes the rest — files, SDKs and
activation guides — so what you are left with is one file per job:

```bash
./tool/stack.py --backend supabase --analytics none --crash sentry --dry-run
./tool/stack.py --backend supabase --analytics none --crash sentry
```

`--backend` takes `firebase`, `supabase` or `pocketbase`; `--analytics` takes
`firebase`, `amplitude` or `none`; `--crash` takes `sentry`, `firebase` or `none`.
Run it on a clean git tree, read the diff, then `flutter pub get` and
`./tool/codegen.sh`.

Doing it by hand still works and the **Stack System** section below says how. The
script exists because the manual path has four steps that fail silently: an SDK
left in `pubspec.yaml` puts its permissions into the merged Android manifest of an
app that never calls it, which is a data-safety answer nobody wants to defend.

It writes `assets/config.example.json` with exactly the keys your selection reads.
Copy it to `assets/config.json`, which is gitignored, and fill it in.

### 3. Install and Generate

```bash
flutter pub get
./tool/codegen.sh
```

### 4. Run

```bash
flutter run --dart-define-from-file=assets/config.json
```

## Stack System

The template supports multiple backend, analytics, and crash reporting providers. Stack-specific code is marked with `// STACK_[TECH]` comment labels. To switch stacks:

1. Search the codebase for the label (e.g., `// STACK_SUPABASE`)
2. Uncomment the `@Singleton(as: ...)` or `@LazySingleton(as: ...)` annotation for the stack you want to activate
3. Comment out the annotation for the stack you want to deactivate
4. Update `lib/main.dart` initialization blocks accordingly
5. Run `./tool/codegen.sh` and read `lib/app/get_it.config.dart` to check that exactly one implementation is registered against each interface

| Label | Technology | Category | Default |
|---|---|---|---|
| `STACK_FIREBASE` | Firebase Auth, Firestore | Backend | Active |
| `STACK_SUPABASE` | Supabase Auth, Database | Backend | Inactive |
| `STACK_POCKETBASE` | Pocketbase Auth, Database | Backend | Inactive |
| `STACK_FIREBASE_ANALYTICS` | Firebase Analytics | Analytics | Active |
| `STACK_AMPLITUDE` | Amplitude | Analytics | Inactive |
| `STACK_SENTRY` | Sentry | Crash Reporting | Active |
| `STACK_FIREBASE_CRASHLYTICS` | Firebase Crashlytics | Crash Reporting | Inactive |

Abstract service classes (`AuthService`, `AnalyticsService`, `CrashService`, `FeedbackService`) have multiple concrete implementations. Only the implementation with an active (uncommented) annotation registers via get_it. Your feature code always depends on the abstract interface, so swapping backends requires no changes to feature code.

**The annotation is the only selector.** There is no `STACK_PAAS`, `STACK_ANALYTICS` or `STACK_CRASHLYTICS` key in `assets/config.json`; nothing reads such a key. Two active annotations for the same interface compile without complaint and throw at startup, so run `flutter test test/stack/stack_selection_test.dart` after a swap.

### Environment Variables

| Variable | Required When | Purpose |
|---|---|---|
| `SUPABASE_URL` | Supabase stack active | Supabase project URL |
| `SUPABASE_ANON_KEY` | Supabase stack active | Supabase anonymous key |
| `AMPLITUDE_API_KEY` | Amplitude stack active | Amplitude API key |
| `POCKETBASE_URL` | Pocketbase stack active | Pocketbase server URL |
| `SENTRY_DSN` | Sentry stack active | Sentry ingest DSN; empty skips init |
| `SERVER_CLIENT_ID` | Google Sign-In is used | Google OAuth server client ID |

## Architecture

### Feature Organization

Each feature follows a consistent structure:

```
lib/features/{feature_name}/
  ├── models/          # Data models with json_serializable
  ├── services/        # Business logic and state (with signals)
  ├── ui/              # Views and widgets
  │   └── widgets/     # Feature-specific widgets
  └── utils/           # Feature-specific utilities
```

### State Management

Global state is managed via **signals**. Services registered in get_it manipulate this state. Global signals live in the same file as their corresponding service and are prefixed with the service name.

For example, the `AuthService` file defines `authUserId`, `authEmail`, and `authIsAuthenticated` signals, which are updated automatically by the active auth service implementation.

### Dependency Injection

Uses get_it with injectable. Services are decorated with `@Singleton`, `@LazySingleton`, or `@Injectable` and accessed via global getters in `lib/app/services.dart` (e.g., `authService`, `analyticsService`, `router`).

### Routing

Uses auto_route for declarative routing. Routes are defined in `lib/app/router.dart` and protected by `AuthGuard` where needed. Navigation uses `router.push()`, `router.pop()`, etc.

## Features

### Authentication

Full auth flows for multiple providers, with pre-built UI screens:

- **Email/password** — Sign in, sign up, password reset, change password
- **Phone/SMS** — Phone sign in, SMS verification
- **Google Sign-In** — OAuth flow
- **Apple Sign-In** — OAuth flow
- **Anonymous auth** — Guest mode (configurable in `lib/app/config.dart`)
- **Account management** — Profile editing, account view

Auth state is exposed as global signals (`authUserId`, `authEmail`, `authIsAuthenticated`, `authPhoneNumber`, `appUser`) and stays in sync automatically.

### Analytics

Track events through a unified `AnalyticsService` interface. Swap providers by moving the active annotation between these two:

- **Firebase Analytics** — `// STACK_FIREBASE_ANALYTICS`, active by default
- **Amplitude** — `// STACK_AMPLITUDE`

Never call a vendor SDK outside its own service file. `test/analytics/analytics_stack_test.dart` fails when one does, because an event sent to an unconfigured vendor raises no error — it simply arrives nowhere.

### Crash Reporting

Automatic crash and error reporting through a unified `CrashService` interface:

- **Sentry** — `// STACK_SENTRY`, active by default. Set `SENTRY_DSN` in `assets/config.json`; an empty DSN skips init and the app runs unchanged.
- **Firebase Crashlytics** — `// STACK_FIREBASE_CRASHLYTICS`

### Subscriptions

RevenueCat integration with:

- Subscription service for managing purchase state
- Pre-built paywall/subscription UI
- Configurable subscription features list in `lib/app/config.dart`

### Onboarding

A built-in onboarding flow for first-time users.

### Feedback

In-app feedback collection with a submission UI.

### RSS Feed

Built-in RSS feed reader for content delivery.

### Settings

Settings screen with common app preferences.

### Shared Utilities

Reusable components available across all features:

- **UI widgets** — App logo, app name, app version, loading indicators, loading overlays, phone number text field, banner ad, responsive layout helpers
- **Constants** — Pre-defined gaps (`gap4` through `gap64`), paddings (`padding8` through `padding36`, directional variants), border radii, breakpoints
- **Services** — HTTP client, crash reporting, permissions

## Platform Setup

### Firebase

Run FlutterFire CLI in the project root:

```bash
flutterfire config --project=my_project
```

You can [safely commit firebase_options.dart to git](https://github.com/firebase/flutterfire/discussions/7617#discussioncomment-2667871).

### Supabase

Set the `SUPABASE_URL` and `SUPABASE_ANON_KEY` variables in `assets/config.json` and activate the `STACK_SUPABASE` labels (see Stack System above).

## Release

### Generate Upload Key (Android)

```bash
keytool -genkey -v -keystore ./keys/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### Deploy

```bash
# iOS — TestFlight
cd ios && fastlane beta

# iOS — App Store (submit for review)
cd ios && fastlane prod

# Android — Internal test track
cd android && fastlane internal

# Android — Alpha / Beta / Production
cd android && fastlane alpha
cd android && fastlane beta
cd android && fastlane prod
```

## Code Generation

After modifying routes, services, or models, regenerate:

```bash
./tool/codegen.sh
```

This updates:
- `router.gr.dart` — from route definitions in `router.dart`
- `get_it.config.dart` — from `@injectable` annotations
- `*.g.dart` — from `@JsonSerializable` models

## Code Style

- **State**: Signals (not setState, Provider, Bloc, etc.)
- **Routing**: auto_route
- **DI**: get_it + injectable
- **Spacing**: Constant gaps (`gap16`, `gap24`) instead of `SizedBox`
- **Theming**: FlexColorScheme
- **Naming**: No underscores in function or variable names

## Key Files

| File | Purpose |
|---|---|
| `lib/main.dart` | App entry point — initializes backend, configures dependencies |
| `lib/app/config.dart` | App name, branding, feature flags — first file to customize |
| `lib/app/router.dart` | Route definitions and navigation guards |
| `lib/app/services.dart` | Global service accessors |
| `lib/app/get_it.dart` | DI configuration |
| `lib/app/constants.dart` | UI constants (gaps, paddings, borders, breakpoints) |
| `lib/app/theme.dart` | Theme configuration |
| `assets/config.json` | Environment variable configuration |

## Assets

Images in the `assets` folder are [resolution-aware](https://docs.flutter.dev/ui/assets/assets-and-images#resolution-aware).

Sign-in button assets follow platform guidelines:
- [Google Sign-In branding](https://developers.google.com/identity/branding-guidelines)
- [Apple Sign-In resources](https://developer.apple.com/design/resources/)
