# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Getting Started with a New Project

When starting a new project from this template, begin with the brand bootstrap process before writing any code. Read `brand/bootstrap.md` and use it to interview the user about what they want to build. Walk them through each step of the bootstrap guide, filling out the brand documents (`brand/mission.md`, `brand/marketing.md`, `brand/app-store.md`) collaboratively through conversation. Ask questions one section at a time, help refine their answers, and write the results into the files. Only move on to technical setup and code once the brand foundation is in place.

## Project Overview

This is the **Sapid Labs Flutter Template** (package name: `slapp`) — a production-grade base template used to create all Sapid Labs apps. It aggregates learnings across child apps (app store fixes, auth flows, notifications, deployment, etc.) so improvements propagate to every project.

**Company**: Sapid Labs — "tasteful software"

Key capabilities:
- **Multi-backend support**: Firebase and Supabase, swappable via `stack/` activation guides
- **Comprehensive auth**: Email/password, phone/SMS, Google Sign-In, Apple Sign-In, anonymous
- **Analytics**: Amplitude, PostHog, or Firebase Analytics
- **Crash reporting**: Firebase Crashlytics or Sentry
- **Subscriptions**: RevenueCat
- **Ads**: Google Mobile Ads
- **Deployment**: Fastlane for iOS (TestFlight, App Store) and Android (internal, alpha, beta, production)

## Stack System

The template supports multiple backend, analytics, and crash reporting providers. When the user tells you which technology they want, read the corresponding activation guide from the `stack/` folder and follow its steps.

| Guide | Technology | Category |
|---|---|---|
| `stack/FIREBASE.md` | Firebase Auth, Firestore | Backend |
| `stack/SUPABASE.md` | Supabase Auth, Database | Backend |
| `stack/FIREBASE_ANALYTICS.md` | Firebase Analytics | Analytics |
| `stack/AMPLITUDE.md` | Amplitude | Analytics |
| `stack/FIREBASE_CRASHLYTICS.md` | Firebase Crashlytics | Crash Reporting |
| `stack/SENTRY.md` | Sentry | Crash Reporting |
| `stack/MOBILE_ADS.md` | Google Mobile Ads | Ads |

**How to activate a stack**:
1. Read the guide from `stack/` for the requested technology
2. Follow its activation steps (config.json values, `lib/main.dart` changes, etc.)
3. Delete the competing service files listed in the guide
4. Run `flutter pub run build_runner build --delete-conflicting-outputs`

Each guide specifies the active services to keep and the competing code to delete. Stack selection is configured in `assets/config.json` using `STACK_PAAS` (backend), `STACK_ANALYTICS` (analytics), and `STACK_CRASHLYTICS` (crash reporting) keys.

## Build & Development Commands

### Core Commands
```bash
# Install dependencies
flutter pub get

# Run code generation for auto_route, injectable, and json_serializable
flutter pub run build_runner build --delete-conflicting-outputs

# Clean build artifacts
flutter clean

# Run the app (uses assets/config.json for stack and environment config)
flutter run --dart-define-from-file=assets/config.json
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
- **Multi-backend pattern**: Abstract service classes (e.g., `AuthService`, `AnalyticsService`, `CrashService`) have multiple concrete implementations. When activating a stack, you keep the chosen implementation and delete the competing ones (see `stack/` guides).
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
The template supports multiple backend providers. See `stack/FIREBASE.md` and `stack/SUPABASE.md` for activation instructions.

| Backend | Auth Service | Data Access | Files |
|---|---|---|---|
| **Firebase** | `FirebaseAuthService` | Cloud Firestore | `lib/features/auth/services/firebase_auth_service.dart` |
| **Supabase** | `SupabaseAuthService` | `supabase.from('table')` | `lib/features/auth/services/supabase_auth_service.dart` |

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

All configuration lives in `assets/config.json` and is passed via `--dart-define-from-file`. Each stack activation guide in `stack/` specifies what keys are needed.

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

- `lib/main.dart`: App entry point — initializes backend based on stack, configures dependencies
- `lib/app/router.dart`: Route definitions and navigation guards
- `lib/app/services.dart`: Global service accessors (e.g., `authService`, `analyticsService`)
- `lib/app/get_it.dart`: Dependency injection configuration
- `lib/app/constants.dart`: UI constants (gaps, paddings, borders, breakpoints)
- `lib/app/config.dart`: App configuration and branding (first file to customize per child app)
- `lib/app/theme.dart`: Theme configuration (uses FlexColorScheme)
- `assets/config.json`: Stack selection and environment variable configuration
- `stack/`: Activation guides for each supported technology
