# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Project Overview

This is the **Sapid Labs Flutter Template** (package name: `slapp`) — a production-grade base template used to create all Sapid Labs apps. It aggregates learnings across child apps (app store fixes, auth flows, notifications, deployment, etc.) so improvements propagate to every project.

**Company**: Sapid Labs — "tasteful software"

Key capabilities:
- **Multi-backend support**: Firebase, Supabase, and Pocketbase via a configurable stack system
- **Comprehensive auth**: Email/password, phone/SMS, Google Sign-In, Apple Sign-In, anonymous
- **Analytics**: Amplitude, PostHog, or Firebase Analytics
- **Crash reporting**: Firebase Crashlytics or Sentry
- **Subscriptions**: RevenueCat
- **Ads**: Google Mobile Ads
- **Deployment**: Fastlane for iOS (TestFlight, App Store) and Android (internal, alpha, beta, production)

## Stack Configuration System

The template uses an environment-based stack selection system defined in `lib/app/get_it.dart`. Three axes control which service implementations are registered:

| Variable | Options | Default |
|---|---|---|
| `STACK_PAAS` | `firebase`, `supabase`, `pocketbase` | `firebase` |
| `STACK_ANALYTICS` | `amplitude`, `posthog`, `firebaseAnalytics` | `amplitude` |
| `STACK_CRASHLYTICS` | `firebaseCrashlytics`, `sentry` | `firebaseCrashlytics` |

**How it works**: `configureDependencies()` uses a `NoEnvOrContainsAny` filter. Services without an env annotation always register. Services annotated with an env (e.g., `@firebaseEnv`, `@supabaseEnv`) only register when their env is in the active set.

**Example**: `FirebaseAuthService` is annotated with `@firebaseEnv` and `SupabaseAuthService` with `@supabaseEnv`. When `STACK_PAAS=firebase`, only `FirebaseAuthService` registers as the `AuthService` implementation.

**Configuration**: Set via `assets/config.json` and passed with `--dart-define-from-file`:
```json
{
  "STACK_PAAS": "firebase",
  "STACK_ANALYTICS": "firebaseAnalytics",
  "SERVER_CLIENT_ID": "your_client_id"
}
```

## Build & Development Commands

### Core Commands
```bash
# Install dependencies
flutter pub get

# Run code generation for auto_route, injectable, and json_serializable
flutter pub run build_runner build --delete-conflicting-outputs

# Clean build artifacts
flutter clean

# Run the app (primary approach — uses assets/config.json)
flutter run --dart-define-from-file=assets/config.json

# Run with individual environment variables
flutter run \
  --dart-define=STACK_PAAS=firebase \
  --dart-define=STACK_ANALYTICS=amplitude \
  --dart-define=STACK_CRASHLYTICS=firebaseCrashlytics \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key \
  --dart-define=AMPLITUDE_API_KEY=your_key \
  --dart-define=SERVER_CLIENT_ID=your_client_id
```

### Testing & Deployment
```bash
# Run tests
flutter test

# iOS — TestFlight
cd ios && fastlane beta

# iOS — App Store (submit for review)
cd ios && fastlane prod

# Android — Internal test track
cd android && fastlane internal

# Android — Alpha test track
cd android && fastlane alpha

# Android — Beta test track
cd android && fastlane beta

# Android — Production
cd android && fastlane prod
```

### Template Updates
```bash
# Fetch and merge updates from the template repository
git fetch template
git merge template/main --allow-unrelated-histories
```

## Architecture

### State Management Strategy
- **Global State**: Managed via signals from the `signals` package
- **Global Signals**: Located in the same file as their corresponding service, prefixed with service name
  - Example: `authUserId`, `authEmail`, and `authIsAuthenticated` are defined in `lib/features/auth/services/auth_service.dart`
- **Services**: Registered with `get_it` and `injectable`, accessed via global getters in `lib/app/services.dart`
  - Example: `authService`, `analyticsService`, `settingsService`

### Dependency Injection
- Uses `get_it` with `injectable` for dependency registration
- **Multi-backend pattern**: Abstract service classes (e.g., `AuthService`, `AnalyticsService`, `CrashService`) have multiple concrete implementations annotated with environment constants (e.g., `@firebaseEnv`, `@supabaseEnv`, `@amplitudeAnalyticsEnv`). Only the implementation matching the active stack registers at runtime.
- Services are decorated with:
  - `@Singleton(as: AuthService)` for single instance services with an interface
  - `@LazySingleton(as: AnalyticsService)` for lazily initialized services with an interface
  - `@Injectable(as: CrashService)` for regular services with an interface
- Configuration happens in `lib/app/get_it.dart` with `configureDependencies()`
- Services are accessed via global getters in `lib/app/services.dart` (e.g., `authService`, `router`, `analyticsService`)

### Routing
- Uses `auto_route` for declarative routing
- Router configuration: `lib/app/router.dart`
- Generated routes: `lib/app/router.gr.dart` (auto-generated, don't edit manually)
- Route guards: `AuthGuard` protects authenticated routes
- Navigation: Use `router.push()`, `router.pop()`, etc.

### Feature Organization
Each feature follows this structure:
```
lib/features/{feature_name}/
  ├── models/          # Data models with json_serializable
  ├── services/        # Business logic and state (with signals)
  ├── ui/              # Views and widgets
      └── widgets/     # Feature-specific widgets
  └── utils/           # Feature-specific utilities
```

Current features: `analytics`, `auth`, `dashboard`, `demo`, `feed`, `feedback`, `home`, `onboarding`, `rss`, `settings`, `shared`, `subscriptions`

### Shared Resources
- **UI Components**: `lib/features/shared/ui/` contains reusable widgets:
  - `app_logo.dart`, `app_name.dart`, `app_version.dart`
  - `loading_indicator.dart`, `loading_overlay.dart`, `loading_stack.dart`
  - `phone_number_text_field.dart`, `banner_ad.dart`, `layout.dart`
- **Utilities**: `lib/features/shared/utils/` contains helper functions
- **Services**: `lib/features/shared/services/` contains cross-cutting concerns (AI, crash reporting, permissions, HTTP client)

### Backend Services
The template supports three backend providers, selectable via `STACK_PAAS`:

| Backend | Auth Service | Data Access | Files |
|---|---|---|---|
| **Firebase** | `FirebaseAuthService` | Cloud Firestore | `lib/features/auth/services/firebase_auth_service.dart` |
| **Supabase** | `SupabaseAuthService` | `supabase.from('table')` | `lib/features/auth/services/supabase_auth_service.dart` |
| **Pocketbase** | (planned) | — | — |

Auth methods available: email/password, Google Sign-In, Apple Sign-In, phone/SMS, anonymous

Auth state is managed through global signals (`authUserId`, `authEmail`, `authIsAuthenticated`, `authPhoneNumber`, `appUser`) and updated automatically by the active auth service.

### Third-Party Services

| Function | Options | Files |
|---|---|---|
| **Backend/Auth** | Firebase, Supabase, Pocketbase | `lib/features/auth/services/` |
| **Analytics** | Amplitude, PostHog, Firebase Analytics | `lib/features/analytics/services/` |
| **Crash Reporting** | Firebase Crashlytics, Sentry | `lib/features/shared/services/crash/` |
| **Subscriptions** | RevenueCat | `lib/features/subscriptions/services/subscription_service.dart` |
| **Ads** | Google Mobile Ads | `lib/features/shared/ui/banner_ad.dart` |
| **OAuth** | Google Sign-In, Apple Sign-In | Used within auth services |
| **Theming** | FlexColorScheme | `lib/app/theme.dart`, `lib/main.dart` |

### Environment Variables

| Variable | Required When | Purpose |
|---|---|---|
| `STACK_PAAS` | Always (defaults to `firebase`) | Backend provider selection |
| `STACK_ANALYTICS` | Always (defaults to `amplitude`) | Analytics provider selection |
| `STACK_CRASHLYTICS` | Always (defaults to `firebaseCrashlytics`) | Crash reporting provider selection |
| `SUPABASE_URL` | `STACK_PAAS=supabase` | Supabase project URL |
| `SUPABASE_ANON_KEY` | `STACK_PAAS=supabase` | Supabase anonymous key |
| `AMPLITUDE_API_KEY` | `STACK_ANALYTICS=amplitude` | Amplitude analytics API key |
| `SERVER_CLIENT_ID` | Google Sign-In is used | Google Sign-In server client ID |

These are configured in `assets/config.json` and passed via `--dart-define-from-file`, or individually via `--dart-define` flags. VS Code launch configurations can also be used (`.vscode/launch.json`).

## Code Style & Conventions

- Use Signals for state management (not setState, Provider, Bloc, etc.)
- Use auto_route for routing (`lib/app/router.dart`)
- Use get_it and injectable for service registration (`lib/app/services.dart`)
- Use constant gaps instead of SizedBox (e.g., `gap16`, `gap24` from `lib/app/constants.dart`)
- Don't use underscores in function or variable names

### Spacing Constants
Available gap constants from `lib/app/constants.dart`:
- `gap4`, `gap8`, `gap12`, `gap16`, `gap24`, `gap32`, `gap48`, `gap64`
- Also: `smallerGap`, `smallGap`, `gap`, `largeGap`, `largerGap`, `largestGap`

Available padding constants:
- `padding8`, `padding12`, `padding16`, `padding24`, `padding36`
- Directional: `paddingH8`, `paddingV8`, `paddingH16`, `paddingV16`, `paddingH24`, `paddingV24`

### Code Generation
After modifying:
- Routes in `router.dart` → Run build_runner to update `router.gr.dart`
- Services with `@injectable` → Run build_runner to update `get_it.config.dart`
- Models with `@JsonSerializable` → Run build_runner to update `*.g.dart` files

## App Configuration

Edit `lib/app/config.dart` for:
- App name and branding (defaults to "Sapid Labs" — replace per child app)
- Social media usernames
- Subscription features
- Anonymous user settings
- VIP email list

This is the first file to customize when creating a new child app from the template.

## Claude Skills

Available skills for working with this template:

| Skill | Purpose |
|---|---|
| `/sapid-feature` | Create a complete feature with models, services, UI, and routing |
| `/sapid-model` | Create Dart model classes with JSON serialization |
| `/sapid-service` | Create service classes with backend integration and DI |
| `/sapid-route` | Create routes and connect them to the app router |
| `/sapid-deploy` | Commands and instructions for deploying to production |
| `/sapidify` | Update existing files to follow Sapid Labs conventions |

## Sapid-Todos Sync System

Purpose: propagate improvements between the template and child apps. All Sapid Labs Flutter apps live in a shared `work` folder. See `sapid-labs/overview.md` for full details.

- **`/add-todo`**: Add a change description to other projects' `sapid-todos.md` files. Used from the template to notify child apps, or from child apps to notify the template.
- **`/sync-todos`**: Review and implement pending changes from `sapid-todos.md`, then remove completed items.

## Key Files

- `lib/main.dart`: App entry point — initializes Firebase/Supabase based on stack, configures dependencies
- `lib/app/router.dart`: Route definitions and navigation guards
- `lib/app/services.dart`: Global service accessors (e.g., `authService`, `analyticsService`)
- `lib/app/get_it.dart`: Dependency injection configuration with stack-based environment filtering
- `lib/app/constants.dart`: UI constants (gaps, paddings, borders, breakpoints)
- `lib/app/config.dart`: App configuration and branding (first file to customize per child app)
- `lib/app/theme.dart`: Theme configuration (uses FlexColorScheme)
- `assets/config.json`: Stack and environment variable configuration
