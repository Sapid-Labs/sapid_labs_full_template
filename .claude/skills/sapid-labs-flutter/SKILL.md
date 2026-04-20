---
name: sapid-labs-flutter
description: Comprehensive conventions, architecture patterns, and reusable snippets for all Sapid Labs Flutter apps. Use this skill whenever working on ANY Flutter project under ~/Dev/sapid/work/flutter-apps/, or when the user mentions Sapid Labs, slapp template, or any of these app names: CubCampus, Vault Messages, FitJo, SuppConnect, Speculator, Void, Blueprint, Walkie, SpanOS Health Chat, Abis Recipes. Also trigger when creating new Flutter features, services, models, or routes in a Sapid Labs project, when deploying via Fastlane, when debugging CI/CD, or when the user asks about "how we do X" in a Sapid context. This skill complements per-project CLAUDE.md files and per-project skills (sapid-feature, sapid-model, etc.) by providing the cross-cutting knowledge those don't cover.
---

# Sapid Labs Flutter Development Skill

This skill captures the conventions, architecture patterns, and reusable knowledge across all Sapid Labs Flutter apps. It's designed as a living reference — the patterns here come from real production apps and should be updated as practices evolve.

## When to Use This Skill

- Starting work on any Sapid Labs Flutter project
- Creating new features, services, models, or routes
- Deploying or releasing an app
- Debugging architecture or convention questions
- Porting patterns between projects

## Quick Reference: The Sapid Stack

Every Sapid Labs app derives from the `sapid_labs_flutter_template` (package name: `slapp`). The core stack is:

| Layer | Technology | Notes |
|---|---|---|
| State management | `signals` package | Global signals, NOT setState/Provider/Bloc |
| MVVM | `simple_mvvm` | ViewModelBuilder for complex views; simple views use StatefulWidget |
| DI | `get_it` + `injectable` | Services registered via annotations |
| Routing | `auto_route` | Declarative, with `AuthGuard` for protected routes |
| Models | `json_serializable` | `@JsonSerializable()` + `copyWith` + equality |
| Theming | `FlexColorScheme` | Configured in `lib/app/theme.dart` |
| Backend | Firebase OR Supabase | Swappable via `stack/` activation guides in template |
| Analytics | Amplitude OR Firebase Analytics | Abstract `AnalyticsService` |
| Crash reporting | Crashlytics OR Sentry | Abstract `CrashService` |
| Subscriptions | RevenueCat | `subscription_service.dart` |
| Ads | Google Mobile Ads | `banner_ad.dart` widget |
| CI/CD | Fastlane + Shorebird | iOS and Android lanes with Slack notifications |

## Project Structure (Canonical)

```
lib/
├── app/
│   ├── config.dart          # First file to customize per app
│   ├── constants.dart       # Gaps, paddings, breakpoints
│   ├── get_it.dart          # DI configuration
│   ├── router.dart          # Route definitions
│   ├── router.gr.dart       # Generated (don't edit)
│   ├── services.dart        # Global service getters
│   └── theme.dart           # FlexColorScheme config
├── features/
│   ├── {feature_name}/
│   │   ├── models/          # Data models with json_serializable
│   │   ├── services/        # Business logic + signals
│   │   ├── ui/              # Views
│   │   │   └── widgets/     # Feature-specific widgets
│   │   └── utils/           # Feature-specific utilities
│   └── shared/
│       ├── ui/              # Reusable widgets (app_logo, loading_indicator, etc.)
│       ├── utils/           # Helper functions
│       └── services/        # Cross-cutting (AI, crash, permissions, HTTP)
├── main.dart
assets/
├── config.json              # Stack selection + env vars
├── images/
```

## Core Conventions

These rules apply to EVERY Sapid Labs Flutter app. Violating them creates drift from the template and makes merging upstream changes painful.

### Naming
- **No leading underscores** in function or variable names — ever. Dart convention uses `_` for library-private members, but Sapid Labs apps avoid this entirely. Use camelCase for all variables and functions regardless of visibility. This keeps code grep-friendly and avoids confusion when refactoring visibility.
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Routes in URL: `kebab-case`
- Firestore collections: `lowercase_plural`

```dart
// Wrong — never do this in Sapid Labs apps
final _controller = TextEditingController();
void _handleSubmit() { ... }

// Correct
final controller = TextEditingController();
void handleSubmit() { ... }
```

### Spacing — Use Constants, Not SizedBox
Import from `lib/app/constants.dart`:
```dart
// Gaps (SizedBox wrappers)
gap4, gap8, gap12, gap16, gap24, gap32, gap48, gap64
smallerGap, smallGap, gap, largeGap, largerGap, largestGap

// Padding (EdgeInsets)
padding8, padding12, padding16, padding24, padding36
paddingH8, paddingV8, paddingH16, paddingV16, paddingH24, paddingV24
```

### Signals — Global State Pattern
Signals live in the same file as their service, prefixed with the service name:
```dart
// In auth_service.dart
final authUserId = signal<String?>(null);
final authEmail = signal<String?>(null);
final authIsAuthenticated = computed(() => authUserId.value != null);
```

### Services — DI Pattern
```dart
// Registration (in the service file)
@lazySingleton        // Stateless, created on demand
@singleton            // Has setup(), maintains state
@Injectable(as: Foo)  // When using abstract interface

// Access (via lib/app/services.dart)
FooService get fooService => getIt.get<FooService>();
```

### Views — MVVM with simple_mvvm
Use the `ViewModelBuilder` pattern from `simple_mvvm` for complex views. Keep all business logic and controllers (TextEditingController, ScrollController, etc.) in the ViewModel. The View file should contain only UI composition.

For simple views with little state, a basic `StatefulWidget` is fine — no need to over-engineer.

In both cases, always put child widgets in a nested `widgets/` directory:
```
lib/features/{feature_name}/ui/
├── {feature}_view.dart              # The view (Scaffold, layout)
├── {feature}_view_model.dart        # ViewModel (controllers, logic) — only for complex views
└── widgets/                         # Child widgets, always nested here
    ├── {feature}_list_tile.dart
    └── {feature}_header.dart
```

```dart
// ViewModel — owns all controllers and business logic
class ProfileViewModel extends ViewModel<ProfileViewModel> {
  final nameController = TextEditingController();
  final bioController = TextEditingController();

  ViewState viewState = ViewState.initial;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async { ... }
  Future<void> saveProfile() async { ... }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    super.dispose();
  }
}

// View — UI only, delegates to ViewModel
@RoutePage()
class ProfileView extends StatefulWidget { ... }

class ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    return ProfileViewModelBuilder(
      builder: (context, viewModel) {
        return Scaffold(
          body: ...,
        );
      },
    );
  }
}
```

### Loading & Empty States
Every view that loads data from the database must have loading and empty states. No exceptions.

**Loading state:** Use `CircularProgressIndicator` centered on the page. For lists, a centered spinner is fine — no need for skeleton/shimmer unless the app specifically calls for it.

**Empty state:** Always include an icon and descriptive text. Use the theme's `bodyLarge` for the message and a muted icon from Material Icons.

```dart
// Standard empty state pattern
if (items.isEmpty) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.inbox_outlined,
          size: 64,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        gap16,
        Text(
          'No items yet',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    ),
  );
}
```

**Error state:** Inline on the page with a retry button. Don't use snackbars for load failures — the user needs to see the error persists.

```dart
if (viewModel.viewState == ViewState.error) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(viewModel.errorMessage ?? 'Something went wrong'),
        gap16,
        ElevatedButton(
          onPressed: viewModel.reload,
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}
```

### Animations with flutter_animate
`flutter_animate` is included in every app. Use it for entrance animations and micro-interactions, but keep it subtle — animations should feel polished, not distracting.

**Standard entrance animation** for list items and page content:
```dart
// Fade + slide up for page content
child.animate()
  .fadeIn(duration: 300.ms)
  .slideY(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOut)

// Staggered list items
ListView.builder(
  itemBuilder: (context, index) {
    return ItemTile(item: items[index])
      .animate()
      .fadeIn(delay: (50 * index).ms, duration: 300.ms)
      .slideX(begin: -0.1, end: 0, delay: (50 * index).ms, duration: 300.ms);
  },
)
```

**Standard durations:**
- Micro-interactions (button feedback, toggles): `150.ms`
- Entrance animations (fade in, slide): `300.ms`
- Page transitions: `300.ms` (handled by auto_route)
- Stagger delay between list items: `50.ms`

**When NOT to animate:**
- Loading spinners (already animated)
- Form inputs while the user is typing
- Data that updates in real-time (chat messages arriving)
- Anything that fires on every rebuild

### Responsive Breakpoints
The template defines breakpoints in `lib/app/constants.dart` via the `Breakpoints` class:

```dart
Breakpoints.xs  // 400  — phone
Breakpoints.sm  // 600  — tablet
Breakpoints.md  // 1000 — laptop
Breakpoints.lg  // 1440 — desktop
```

Helpers already available:
- `kIsWideScreen(context)` — true when width >= 600 (tablet+)
- `kIsWideDesktopWeb(context)` — true when web and width >= 1000
- `LayoutUtils.isWide(context)` — true when width > 400
- `LayoutUtils.maxWidth` — 600, use for constraining content width on wide screens

**Standard responsive pattern:**
```dart
// Constrain content width on wide screens
Center(
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: LayoutUtils.maxWidth),
    child: content,
  ),
)

// Switch layout at tablet breakpoint
if (kIsWideScreen(context)) {
  return MasterDetailLayout(...);  // Side-by-side
} else {
  return ListView(...);  // Stacked
}
```

### UI — Form Fields Must Use InputDecorator
Never use raw `Container` with `BoxDecoration` for form-like fields. Always use `InputDecorator` so the theme drives styling:
```dart
// Correct
InkWell(
  onTap: pickDate,
  child: InputDecorator(
    decoration: InputDecoration(labelText: 'Date'),
    isEmpty: selectedDate == null,
    child: Text(selectedDate != null ? formatDate(selectedDate!) : ''),
  ),
),
```

### Code Generation
After changing models, routes, or DI annotations, always run:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Template Sync
All apps can pull upstream template improvements:
```bash
git fetch template
git merge template/main --allow-unrelated-histories
```

The `sapid-todos.md` system propagates changes between template and child apps. Use `/add-todo` to notify other projects and `/sync-todos` to apply pending changes.

## Deep Dives

For detailed patterns, read the appropriate reference file. These cover patterns that go beyond the template baseline — things learned from shipping real apps.

| Topic | File | When to read |
|---|---|---|
| CI/CD & Deployment | `references/cicd.md` | Deploying, setting up Fastlane, Shorebird patching |
| Service Patterns | `references/services.md` | Creating services, real-time streams, filtered queries |
| Model Patterns | `references/models.md` | Creating models, handling nulls, Firestore gotchas |
| Auth & Guards | `references/auth.md` | Auth flows, role-based access, email domain filtering |
| Cross-App Patterns | `references/cross-app-patterns.md` | Media, chat, maps, notifications, OCR/ML |
| Per-Project Skills | `references/project-skills.md` | Using sapid-feature, sapid-model, etc. |

## Per-Project CLAUDE.md

Every Sapid Labs app has its own `CLAUDE.md` at the repo root. Always read it first when entering a project — it specifies which stack is active (Firebase vs Supabase), which analytics provider, environment variables, and project-specific conventions. This global skill supplements but doesn't replace those files.

## Common Packages Across All Apps

These are the packages you can rely on being available in any Sapid Labs app:

**Always present:** `signals`, `simple_mvvm`, `get_it`, `injectable`, `auto_route`, `json_annotation`, `json_serializable`, `flex_color_scheme`, `google_fonts`, `flutter_animate`, `flutter_svg`, `http`, `shared_preferences`, `permission_handler`, `in_app_review`, `url_launcher`, `device_info_plus`, `package_info_plus`, `intl`, `collection`, `recase`

**Usually present:** `cached_network_image`, `flutter_image_compress`, `image_picker`, `firebase_messaging`, `flutter_local_notifications`

**Backend-dependent:** `cloud_firestore` / `supabase_flutter` / `pocketbase`, `firebase_auth`, `firebase_analytics`, `firebase_crashlytics`, `amplitude_flutter`
