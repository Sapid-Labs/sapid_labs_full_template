# CLAUDE.md

This file provides guidance to Claude Code twhen working with code in this repository.

## Project Overview

FitJo is a Flutter fitness application built with:
- **Backend**: Supabase (authentication, database, storage)
- **Analytics**: Amplitude
- **Crash Reporting**: Sentry
- **Subscriptions**: RevenueCat

## Build & Development Commands

### Core Commands
```bash
# Install dependencies
flutter pub get

# Run code generation for auto_route, injectable, and json_serializable
flutter pub run build_runner build --delete-conflicting-outputs

# Clean build artifacts
flutter clean

# Run the app
flutter run

# Run with environment variables
flutter run \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key \
  --dart-define=AMPLITUDE_API_KEY=your_key \
  --dart-define=SERVER_CLIENT_ID=your_client_id
```

### Testing & Deployment
```bash
# Run tests
flutter test

# Deploy to Android internal track (from android/ directory)
cd android && fastlane internal

# Deploy to iOS TestFlight (from ios/ directory)
cd ios && fastlane beta
```

### Template Updates
```bash
# Fetch updates from the template repository
./update-from-template.sh

# Or manually
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
- Services are decorated with:
  - `@Singleton()` for single instance services (e.g., `AuthService`)
  - `@LazySingleton()` for lazily initialized services (e.g., `AnalyticsService`)
  - `@Injectable()` for regular services
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

### Shared Resources
- **UI Components**: `lib/features/shared/ui/` contains reusable widgets:
  - `app_logo.dart`, `app_name.dart`, `app_version.dart`
  - `loading_indicator.dart`, `loading_overlay.dart`
  - `phone_number_text_field.dart`, `banner_ad.dart`
- **Utilities**: `lib/features/shared/utils/` contains helper functions
- **Services**: `lib/features/shared/services/` contains cross-cutting concerns (AI, crash reporting, permissions)

### Backend Services
The app uses Supabase for all backend functionality:
- **Authentication**: Email/password, Google Sign-In, Apple Sign-In, phone/SMS, anonymous
- **Database**: Direct access via `supabase.from('table_name')`
- **Storage**: Available through Supabase client
- Auth state is managed through global signals (`authUserId`, `authEmail`, `authIsAuthenticated`)
- Auth service listens to Supabase auth state changes and updates signals automatically

### Third-Party Services
- **Supabase**: Backend (auth, database, storage) - `lib/features/auth/services/auth_service.dart`
- **Amplitude**: Analytics - `lib/features/analytics/services/analytics_service.dart`
- **Sentry**: Crash reporting - `lib/features/shared/services/crash/crash_service.dart`
- **RevenueCat**: Subscription management - `lib/features/subscriptions/services/subscription_service.dart`
- **Google Sign-In**: OAuth authentication
- **Sign In with Apple**: OAuth authentication

### Environment Variables
Required environment variables (passed via `--dart-define`):
- `SUPABASE_URL`: Supabase project URL
- `SUPABASE_ANON_KEY`: Supabase anonymous key
- `AMPLITUDE_API_KEY`: Amplitude analytics API key
- `SERVER_CLIENT_ID`: Google Sign-In server client ID (for iOS/Android)

These can be configured in:
- VS Code: `.vscode/launch.json`
- Android Studio: Run configurations
- Command line: `--dart-define` flags

## Code Style & Conventions

From `.github/copilot-instructions.md`:
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

### Code Generation
After modifying:
- Routes in `router.dart` → Run build_runner to update `router.gr.dart`
- Services with `@injectable` → Run build_runner to update `get_it.config.dart`
- Models with `@JsonSerializable` → Run build_runner to update `*.g.dart` files

## App Configuration

Edit `lib/app/config.dart` for:
- App name and branding
- Social media usernames
- Subscription features
- Anonymous user settings

## Key Files

- `lib/main.dart`: App entry point, initializes Supabase and Amplitude, configures dependencies
- `lib/app/router.dart`: Route definitions and navigation guards
- `lib/app/services.dart`: Global service accessors
- `lib/app/get_it.dart`: Dependency injection configuration
- `lib/app/constants.dart`: UI constants (gaps, paddings, screen size helpers)
- `lib/app/config.dart`: App configuration and branding
- `lib/app/theme.dart`: Theme configuration (uses FlexColorScheme)
