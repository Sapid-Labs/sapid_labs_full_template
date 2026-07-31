# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Getting Started with a New Project

When starting a new project from this template, begin with the brand bootstrap process before writing any code. Read `brand/bootstrap.md` and use it to interview the user about what they want to build. Walk them through each step of the bootstrap guide, filling out the brand documents (`brand/mission.md`, `brand/marketing.md`, `brand/app-store.md`) collaboratively through conversation. Ask questions one section at a time, help refine their answers, and write the results into the files. Only move on to technical setup and code once the brand foundation is in place.

## Project Overview

This is the **Sapid Labs Flutter Template** (package name: `slapp`) — a production-grade base template used to create all Sapid Labs apps. It aggregates learnings across child apps (app store fixes, auth flows, notifications, deployment, etc.) so improvements propagate to every project.

**Company**: Sapid Labs — "tasteful software"

Key capabilities:
- **Multi-backend support**: Firebase, Supabase or Pocketbase, one file each, chosen by `tool/stack.py`
- **Comprehensive auth**: Email/password, phone/SMS, Google Sign-In, Apple Sign-In, anonymous
- **Analytics**: Firebase Analytics, Amplitude, or none
- **Crash reporting**: Sentry, Firebase Crashlytics, or none
- **Subscriptions**: RevenueCat
- **Deployment**: Fastlane for iOS (TestFlight, App Store) and Android (internal, alpha, beta, production)

## Stack System

Three categories, one provider each, one file per provider:

| Category | Providers | Interface | Where |
|---|---|---|---|
| Backend | `firebase`, `supabase`, `pocketbase` | `AuthService`, `FeedbackService` | `lib/features/auth/services/`, `lib/features/feedback/services/` |
| Analytics | `firebase`, `amplitude`, `none` | `AnalyticsService` | `lib/features/analytics/services/` |
| Crash | `sentry`, `firebase`, `none` | `CrashService` | `lib/features/shared/services/crash/` |

**Use the script. Do not do this by hand.**

```bash
./tool/stack.py --backend supabase --analytics none --crash sentry --dry-run
./tool/stack.py --backend supabase --analytics none --crash sentry
flutter pub get && ./tool/codegen.sh && flutter test
```

It deletes the providers you did not pick and their `stack/*.md` guides, moves the
`@Injectable(as: Interface)` annotation onto the ones you did, toggles the
`// STACK_<NAME>:BEGIN … :END` blocks in `lib/main.dart`, drops the unused
dependencies from `pubspec.yaml`, and rewrites `assets/config.example.json` to the
keys the survivors read. Dependencies come off by set difference over what the
survivors declare, so `--backend supabase --crash firebase` correctly keeps
`firebase_core`. It refuses to run on a dirty git tree.

The reason it is a script and not a checklist is that every step of the manual
version fails quietly. A dependency nobody calls is not free on Android — a plugin
contributes its own manifest — and that is how FitJo ended up declaring
`com.google.android.gms.permission.AD_ID` for an app with no ads.

`test/stack/stack_manifest_test.dart` fails if a service is renamed out from under
the script's manifest, and `test/stack/stack_selection_test.dart` fails if two
implementations claim one interface. Two live registrations compile without
complaint and throw at startup.

**Selection is by annotation and nothing else.** There is no `STACK_PAAS`,
`STACK_ANALYTICS` or `STACK_CRASHLYTICS` key in `assets/config.json`, and no code
reads one — an older scheme used them and any doc still saying so is stale.

Defaults as shipped: Firebase (auth, feedback), Firebase Analytics, Sentry.

**Interfaces stay pure.** `AuthService`, `CrashService` and `AnalyticsService` are
abstract with no method bodies. They used to carry bodies that called every vendor
in turn "for easy dev navigation", which made the interface import both SDKs — so
no child app could delete the vendor it had not picked, and a caller who reached
the base class ran two SDKs at once. Do not put a body back.

**Nothing outside a `*/services/` directory may import a vendor SDK.** A phone
sign-in screen once imported `firebase_auth` for a listener that `AuthService`
already had, and it was the single file that stopped a Supabase app compiling.

## Build & Development Commands

### Core Commands
```bash
# Install dependencies
flutter pub get

# Run code generation for auto_route, injectable, and json_serializable
./tool/codegen.sh

# Clean build artifacts
flutter clean

# Run the app (uses assets/config.json for environment config)
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
- **Multi-backend pattern**: Abstract service classes (e.g., `AuthService`, `AnalyticsService`, `CrashService`) have multiple concrete implementations. Activating a stack moves the `as: Interface` annotation onto the chosen one and comments the rivals' out (see `stack/` guides). Exactly one may claim each interface.
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
  - `phone_number_text_field.dart`, `layout.dart`
- **Utilities**: `lib/features/shared/utils/` contains helper functions
- **Services**: `lib/features/shared/services/` contains cross-cutting concerns (AI, crash reporting, permissions, HTTP client)

### Backend Services
The template supports multiple backend providers. See `stack/FIREBASE.md`, `stack/SUPABASE.md` and `stack/POCKETBASE.md`. Pocketbase supports email and password only — Google, Apple, anonymous and phone sign-in throw a readable `FastAuthException` there rather than pretending to work.

| Backend | Auth Service | Data Access | Files |
|---|---|---|---|
| **Firebase** | `FirebaseAuthService` | Cloud Firestore | `lib/features/auth/services/firebase_auth_service.dart` |
| **Supabase** | `SupabaseAuthService` | `supabase.from('table')` | `lib/features/auth/services/supabase_auth_service.dart` |
| **Pocketbase** | `PocketbaseAuthService` | `pb.collection('name')` | `lib/features/auth/services/pocketbase_auth_service.dart` |

Auth methods available: email/password, Google Sign-In, Apple Sign-In, phone/SMS, anonymous

Auth state is managed through global signals (`authUserId`, `authEmail`, `authIsAuthenticated`, `authPhoneNumber`, `appUser`) and updated automatically by the active auth service.

### Third-Party Services

| Function | Options | Files |
|---|---|---|
| **Backend/Auth** | Firebase, Supabase, Pocketbase | `lib/features/auth/services/` |
| **Analytics** | Firebase Analytics, Amplitude, none | `lib/features/analytics/services/` |
| **Crash Reporting** | Sentry, Firebase Crashlytics, none | `lib/features/shared/services/crash/` |
| **Subscriptions** | RevenueCat | `lib/features/subscriptions/services/subscription_service.dart` |
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
- Routes in `router.dart` → Run `./tool/codegen.sh` to update `router.gr.dart`
- Services with `@injectable` → Run `./tool/codegen.sh` to update `get_it.config.dart`
- Models with `@JsonSerializable` → Run `./tool/codegen.sh` to update `*.g.dart` files

**Always use `./tool/codegen.sh`, never `dart run build_runner` directly.** The script is
short and its comments give the full reasoning; the summary is that plain build_runner
fails in this package graph on Dart 3.10. It compiles the build script AOT, and
`dart compile` refuses any graph that contains a build hook — `path_provider_foundation`
depends on `objective_c`, which ships one. build_runner only falls back to JIT for
`dart:mirrors` failures, so it cannot recover on its own. The script passes `--force-jit`.

Do not add `--delete-conflicting-outputs`. It removes the `.g.dart` files before the
builders run, so a failed build leaves them deleted and the analyzer then reports dozens
of errors that look unrelated to the real cause. Recover with `git checkout --`.

The `environment.sdk` constraint must stay at `^3.8.0` or higher. json_serializable 6.11.2
emits null-aware elements (`'id': ?instance.id`); below that constraint the formatter
throws and deletes the `.g.dart` files without rewriting them.

## App Configuration

Edit `lib/app/config.dart` for:
- App name and branding (defaults to "Sapid Labs" — replace per child app)
- `urlScheme` and `urlHost` — the deep link this app claims. Change these together with
  the `android:scheme`/`android:host` filter in `android/app/src/main/AndroidManifest.xml`
  and `CFBundleURLSchemes` in `ios/Runner/Info.plist`. Never derive the scheme from
  `appName`: a scheme must be lowercase with no space, so `appName.toLowerCase()` gives
  'sapid labs' here, which no platform can register. `test/auth/password_reset_link_test.dart`
  reads all three files off disk and fails when they disagree, because every failure in
  this chain is silent — Supabase substitutes its Site URL for a redirect it does not
  know, and neither platform manifest errors on a scheme it never claimed.
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
- `assets/config.json`: Environment variable configuration (gitignored). Stack selection is by annotation, not by a key in this file.
- `stack/`: Activation guides for each supported technology
