# Sapid Labs Flutter Template

A production-grade Flutter app template with multi-backend support, comprehensive auth, analytics, crash reporting, subscriptions, and ads — all pre-wired and swappable via a simple config file.

## Why Use This Template

Starting a Flutter app from scratch means wiring up authentication, analytics, crash reporting, routing, state management, dependency injection, and deployment — often taking weeks before you write any feature code. This template gives you all of that out of the box:

- **Multi-backend support** — Switch between Firebase, Supabase, and Pocketbase by changing a single config value
- **Full auth flows** — Email/password, phone/SMS, Google Sign-In, Apple Sign-In, and anonymous auth, with pre-built sign-in, sign-up, password reset, and account management screens
- **Analytics ready** — Amplitude, PostHog, or Firebase Analytics, swappable without touching your feature code
- **Crash reporting** — Firebase Crashlytics or Sentry, same swap-friendly pattern
- **Subscriptions** — RevenueCat integration with a paywall UI
- **Ads** — Google Mobile Ads with a reusable banner widget
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

Create `assets/config.json` to select which services to use:

```json
{
  "STACK_PAAS": "firebase",
  "STACK_ANALYTICS": "amplitude",
  "STACK_CRASHLYTICS": "firebaseCrashlytics",
  "SERVER_CLIENT_ID": "your_google_client_id"
}
```

### 3. Install and Generate

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Run

```bash
flutter run --dart-define-from-file=assets/config.json
```

## Stack Configuration

The template uses an environment-based stack system. Three axes control which service implementations are registered at runtime:

| Variable | Options | Default |
|---|---|---|
| `STACK_PAAS` | `firebase`, `supabase`, `pocketbase` | `firebase` |
| `STACK_ANALYTICS` | `amplitude`, `posthog`, `firebaseAnalytics` | `amplitude` |
| `STACK_CRASHLYTICS` | `firebaseCrashlytics`, `sentry` | `firebaseCrashlytics` |

Behind the scenes, abstract service classes (e.g., `AuthService`, `AnalyticsService`) have multiple concrete implementations annotated with environment constants. Only the implementation matching your active stack registers at runtime via get_it's `NoEnvOrContainsAny` filter. Your feature code always depends on the abstract interface, so swapping backends requires zero code changes — just update `config.json`.

### Environment Variables

| Variable | Required When | Purpose |
|---|---|---|
| `STACK_PAAS` | Always (defaults to `firebase`) | Backend provider selection |
| `STACK_ANALYTICS` | Always (defaults to `amplitude`) | Analytics provider selection |
| `STACK_CRASHLYTICS` | Always (defaults to `firebaseCrashlytics`) | Crash reporting provider |
| `SUPABASE_URL` | `STACK_PAAS=supabase` | Supabase project URL |
| `SUPABASE_ANON_KEY` | `STACK_PAAS=supabase` | Supabase anonymous key |
| `AMPLITUDE_API_KEY` | `STACK_ANALYTICS=amplitude` | Amplitude API key |
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

Track events through a unified `AnalyticsService` interface. Swap providers by changing `STACK_ANALYTICS`:

- **Amplitude** — `amplitude`
- **PostHog** — `posthog`
- **Firebase Analytics** — `firebaseAnalytics`

### Crash Reporting

Automatic crash and error reporting through a unified `CrashService` interface:

- **Firebase Crashlytics** — `firebaseCrashlytics`
- **Sentry** — `sentry`

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

Set the `SUPABASE_URL` and `SUPABASE_ANON_KEY` variables in `assets/config.json` and set `STACK_PAAS` to `supabase`.

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
flutter pub run build_runner build --delete-conflicting-outputs
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
| `lib/app/get_it.dart` | DI configuration with stack-based environment filtering |
| `lib/app/constants.dart` | UI constants (gaps, paddings, borders, breakpoints) |
| `lib/app/theme.dart` | Theme configuration |
| `assets/config.json` | Stack and environment variable configuration |

## Assets

Images in the `assets` folder are [resolution-aware](https://docs.flutter.dev/ui/assets/assets-and-images#resolution-aware).

Sign-in button assets follow platform guidelines:
- [Google Sign-In branding](https://developers.google.com/identity/branding-guidelines)
- [Apple Sign-In resources](https://developer.apple.com/design/resources/)
