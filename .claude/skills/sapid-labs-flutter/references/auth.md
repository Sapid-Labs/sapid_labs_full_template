# Auth & Guards

## Table of Contents
- Auth Architecture
- Auth Signals
- Route Guards
- Role-Based Access
- Email Domain Filtering
- Auth Methods

## Auth Architecture

Auth is implemented as an abstract service with backend-specific implementations:

```
lib/features/auth/
├── models/
│   └── app_user.dart          # User model
├── services/
│   ├── auth_service.dart      # Abstract + signals
│   ├── firebase_auth_service.dart
│   └── supabase_auth_service.dart
└── ui/
    ├── login_view.dart
    └── widgets/
```

The active implementation is selected via `@Injectable(as: AuthService)` annotations and the stack system. Only one implementation should be present at a time — the competing one is deleted during stack activation.

## Auth Signals

These signals are available globally after import of the auth service:

```dart
final authUserId = signal<String?>(null);
final authEmail = signal<String?>(null);
final authIsAuthenticated = computed(() => authUserId.value != null);
final authPhoneNumber = signal<String?>(null);
final appUser = signal<AppUser?>(null);
```

The auth service listens to auth state changes and updates these signals automatically. Any widget can react to auth state via `Watch`:

```dart
Watch((context) {
  if (!authIsAuthenticated.value) {
    return LoginPrompt();
  }
  return UserDashboard();
})
```

## Route Guards

The `AuthGuard` protects routes that require authentication:

```dart
// In router.dart
AutoRoute(
  page: ProfileRoute.page,
  path: '/profile',
  guards: [AuthGuard()],
),
```

The guard checks `authIsAuthenticated` and redirects to login if false.

### Custom Guards

For role-based access, create additional guards:

```dart
class AdminGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final user = appUser.value;
    if (user != null && user.role == UserRole.admin) {
      resolver.next(true);
    } else {
      router.push(const UnauthorizedRoute());
    }
  }
}
```

## Role-Based Access

Apps like CubCampus and FitJo use role-based routing where different user types see different home screens:

```dart
// In router.dart — conditional initial route
AutoRoute(
  page: HomeRoute.page,
  path: '/home',
  guards: [AuthGuard()],
  children: [
    AutoRoute(page: ParentDashboardRoute.page),
    AutoRoute(page: SitterDashboardRoute.page),
    AutoRoute(page: AdminDashboardRoute.page),
  ],
),
```

The role is stored on the `AppUser` model and determines which UI to show.

## Email Domain Filtering

Pattern from CubCampus — filtering data based on the user's email domain:

```dart
final filteredCampusList = computed(() {
  final email = authEmail.value;
  if (email == null) return <Campus>[];

  final domain = email.split('@').last.toLowerCase();
  
  // Bypass for test accounts
  if (domain == 'test.edu') return campusList.value;

  return campusList.value
      .where((c) => c.emailDomains.contains(domain))
      .toList();
});
```

This pattern is useful whenever content should be scoped to an organization. The model needs a `List<String> emailDomains` field, and the service filters using a computed signal.

## Auth Methods

Available auth methods (configured per app):

| Method | Firebase | Supabase |
|---|---|---|
| Email/Password | `createUserWithEmailAndPassword` | `supabase.auth.signUp` |
| Google Sign-In | `GoogleSignIn` + `signInWithCredential` | `supabase.auth.signInWithOAuth` |
| Apple Sign-In | `SignInWithApple` + `signInWithCredential` | `supabase.auth.signInWithOAuth` |
| Phone/SMS | `verifyPhoneNumber` + `signInWithCredential` | `supabase.auth.signInWithOtp` |
| Anonymous | `signInAnonymously` | N/A |

The template handles all of these — each app activates only the methods it needs.
