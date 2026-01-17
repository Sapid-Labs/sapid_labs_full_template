# File Generators Utility

This document provides guidance for updating critical project files when generating new features, routes, services, and models in the Sapid Labs Flutter template.

## Purpose

When creating new components, several core files need to be updated to integrate the new code:
1. `lib/app/router.dart` - Route definitions
2. `lib/app/services.dart` - Service getters
3. `lib/main.dart` - Service initialization (when needed)

This utility provides patterns and strategies for safely updating these files.

## Router.dart Updates

### File Location
`lib/app/router.dart`

### Purpose
Defines all application routes using auto_route package.

### When to Update
- Creating a new feature with a view
- Adding a new route to an existing feature
- Adding route guards (AuthGuard, etc.)

### Update Pattern

#### Step 1: Add Import
Add import for the new view at the top of the file with other imports:

```dart
import '../features/{feature_name}/ui/{view_name}_view.dart';
```

**Placement**: Keep imports alphabetically sorted by feature name.

#### Step 2: Add Route to @AutoRouterConfig
Add the route to the routes list inside the `@AutoRouterConfig` class:

```dart
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    // ... existing routes ...

    AutoRoute(
      page: {ViewName}Route.page,
      path: '/{route-path}',
      guards: [AuthGuard()], // Optional: add if authentication required
    ),

    // ... more routes ...
  ];
}
```

**Placement**:
- Group routes by feature area
- Place authenticated routes together
- Place public routes together
- Keep logical ordering (splash → login → home → features)

#### Step 3: Handle Route Parameters
If the route has parameters:

```dart
AutoRoute(
  page: UserProfileRoute.page,
  path: '/user-profile/:id',  // :id is a path parameter
  guards: [AuthGuard()],
),
```

**Parameter Patterns**:
- Required ID: `/:id` (path parameter)
- Optional params: Pass via query string or route extra data
- Complex objects: Use route extra data (handled by auto_route)

### Route Guard Detection

Automatically determine if `AuthGuard` is needed:

**Requires AuthGuard** (authenticated routes):
- User profile views
- Settings/preferences
- User-specific data
- Admin/management features
- Features with "my", "user", "profile" in name

**No AuthGuard** (public routes):
- Login/signup views
- Splash screen
- Onboarding
- Public content browsing
- Landing pages
- Features explicitly marked as public

### Example Router.dart Structure

```dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

// Feature imports (alphabetically sorted)
import '../features/auth/ui/login_view.dart';
import '../features/auth/ui/signup_view.dart';
import '../features/home/ui/home_view.dart';
import '../features/splash/ui/splash_view.dart';
import '../features/user_profile/ui/user_profile_view.dart';
import 'guards/auth_guard.dart';

part 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    // Public routes (no auth required)
    AutoRoute(
      page: SplashRoute.page,
      path: '/splash',
      initial: true,
    ),
    AutoRoute(
      page: LoginRoute.page,
      path: '/login',
    ),
    AutoRoute(
      page: SignupRoute.page,
      path: '/signup',
    ),

    // Authenticated routes
    AutoRoute(
      page: HomeRoute.page,
      path: '/home',
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: UserProfileRoute.page,
      path: '/user-profile/:id',
      guards: [AuthGuard()],
    ),
  ];
}
```

### Safe Update Strategy

1. **Read Current File**: Always read router.dart first
2. **Find Insert Point**: Locate the appropriate section (public vs authenticated)
3. **Check for Duplicates**: Ensure route doesn't already exist
4. **Maintain Formatting**: Preserve indentation and style
5. **Preserve Comments**: Keep any existing comments
6. **Validate Syntax**: Ensure proper Dart syntax after edit

## Services.dart Updates

### File Location
`lib/app/services.dart`

### Purpose
Provides convenient getters for accessing dependency-injected services throughout the app.

### When to Update
- Creating a new service
- Adding a service to an existing feature

### Update Pattern

#### Step 1: Add Import
Add import for the new service:

```dart
import '../features/{feature_name}/services/{service_name}_service.dart';
```

**Placement**: Keep imports alphabetically sorted by feature name.

#### Step 2: Add Getter
Add a getter method for the service:

```dart
{ServiceName}Service get {serviceName}Service => getIt.get<{ServiceName}Service>();
```

**Placement**: Keep getters alphabetically sorted by service name.

### Example Services.dart Structure

```dart
import 'package:get_it/get_it.dart';

// Service imports (alphabetically sorted)
import '../features/auth/services/auth_service.dart';
import '../features/gate/services/gate_service.dart';
import '../features/user_profile/services/user_profile_service.dart';

final getIt = GetIt.instance;

// Service getters (alphabetically sorted)
AuthService get authService => getIt.get<AuthService>();
GateService get gateService => getIt.get<GateService>();
UserProfileService get userProfileService => getIt.get<UserProfileService>();
```

### Safe Update Strategy

1. **Read Current File**: Always read services.dart first
2. **Find Insert Point**: Locate alphabetically correct position
3. **Check for Duplicates**: Ensure getter doesn't already exist
4. **Maintain Formatting**: Preserve consistent spacing and alignment
5. **Follow Pattern**: Use exact same getter pattern as existing getters

## Main.dart Updates

### File Location
`lib/main.dart`

### Purpose
App entry point with initialization logic.

### When to Update
- Creating a service that requires initialization (has `setup()` method)
- Service needs to be configured before app runs

### Update Pattern

#### Step 1: Identify Setup Function
Locate the `setup()` or initialization function in main.dart:

```dart
Future<void> setup() async {
  // Initialization code
}
```

Or it might be inline in `main()`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialization code here

  runApp(MyApp());
}
```

#### Step 2: Add Service Setup Call
Add the service initialization call:

```dart
Future<void> setup() async {
  // ... existing setup ...

  // Initialize {ServiceName}Service
  await services.{serviceName}Service.setup();

  // ... more setup ...
}
```

**Placement**:
- After dependency injection configuration
- Before app launch
- In logical order (e.g., auth before other services)

### When Service Needs Setup

Determine if a service needs `setup()` method:

**Needs Setup** (@singleton):
- Initializes connections (database, network)
- Loads configuration
- Subscribes to streams/listeners
- Caches data at startup
- Requires async initialization

**No Setup** (@lazySingleton):
- Stateless operations
- On-demand initialization
- No startup dependencies
- Simple data transformations

### Example Setup Code

```dart
Future<void> setup() async {
  // Configure dependency injection
  configureDependencies();

  // Initialize Firebase (if using Firebase)
  await Firebase.initializeApp();

  // Initialize services that need setup
  await services.authService.setup();
  await services.gateService.setup();
  await services.userProfileService.setup();

  // Other initialization...
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setup();

  runApp(const MyApp());
}
```

### Safe Update Strategy

1. **Read Current File**: Always read main.dart first
2. **Find Setup Function**: Locate where initialization happens
3. **Determine Insert Point**: Add after existing service setups
4. **Check for Duplicates**: Ensure setup call doesn't already exist
5. **Maintain Async/Await**: Preserve proper async patterns
6. **Preserve Error Handling**: Keep any existing try-catch blocks

## Import Management

### Import Sorting Rules

1. **Dart/Flutter imports first**: `dart:*` and `package:flutter/*`
2. **Third-party packages**: Other `package:*` imports
3. **Relative imports**: Local project imports
4. **Alphabetical within groups**: Sort each group alphabetically

### Example Import Order

```dart
// Dart/Flutter imports
import 'dart:async';
import 'package:flutter/material.dart';

// Third-party packages
import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';

// Relative imports (alphabetically by feature)
import '../features/auth/services/auth_service.dart';
import '../features/user_profile/services/user_profile_service.dart';
```

## Code Formatting

### Indentation
- Use 2 spaces for indentation
- Match existing file indentation

### Line Length
- Keep lines under 80 characters when possible
- Break long parameter lists across multiple lines

### Spacing
- One blank line between imports and code
- One blank line between methods/getters
- No trailing whitespace

### Trailing Commas
- Always use trailing commas for:
  - Parameter lists
  - List/map literals
  - Widget trees

## Validation Checklist

After updating any core file, validate:

- [ ] File syntax is valid Dart
- [ ] All imports resolve correctly
- [ ] No duplicate routes/getters/setup calls
- [ ] Formatting matches existing code
- [ ] Alphabetical ordering maintained
- [ ] Comments preserved
- [ ] No trailing whitespace

## Error Handling

### Common Errors and Solutions

**Duplicate Route Error**:
```
Route with path '/user-profile' already exists
```
**Solution**: Check if route already defined, use different path or update existing

**Import Not Found**:
```
Target of URI doesn't exist: '../features/...'
```
**Solution**: Verify file was created at correct path, check spelling

**GetIt Registration Error**:
```
Object/factory with type {Type} is not registered
```
**Solution**: Ensure service is registered in dependency injection config

**Async Setup Error**:
```
await used without async
```
**Solution**: Ensure setup function is marked as `async`

## Best Practices

1. **Read Before Write**: Always read target file before modifying
2. **Minimal Changes**: Only modify what's necessary
3. **Preserve Style**: Match existing code style exactly
4. **Validate Syntax**: Check Dart syntax after each edit
5. **Test Integration**: Run app after updates to verify integration
6. **Use Edit Tool**: Prefer Edit tool over Write to preserve file content
7. **Atomic Updates**: Update related files together (route + service + main)
8. **Comment Intent**: Add comments for non-obvious integrations

## Template Snippets

### Route Addition Template
```dart
AutoRoute(
  page: {ViewName}Route.page,
  path: '/{route-path}',
  guards: [{Guard}()], // Optional
),
```

### Service Getter Template
```dart
{ServiceName}Service get {serviceName}Service => getIt.get<{ServiceName}Service>();
```

### Service Setup Template
```dart
await services.{serviceName}Service.setup();
```

## Usage in Agents

When agents need to update these files:

1. **Always Read First**: Use Read tool to get current file content
2. **Detect Insert Point**: Find correct location using pattern matching
3. **Use Edit Tool**: Use Edit tool with precise old_string/new_string
4. **Verify Update**: Read file again to confirm changes applied correctly
5. **Run Build**: Execute `flutter pub run build_runner build` after router changes
