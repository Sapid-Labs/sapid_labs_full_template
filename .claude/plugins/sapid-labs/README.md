# Sapid Labs Flutter Template Plugin

A comprehensive Claude Code plugin for generating production-ready Flutter code following Sapid Labs conventions and architectural patterns.

## Overview

This plugin provides intelligent code generation for the Sapid Labs Flutter template project. It enforces architectural standards, naming conventions, and best practices while providing an interactive interview-driven development experience.

## Features

### 🎯 What This Plugin Creates

- **Complete Features**: Full-stack features with models, services, views, ViewModels, widgets, and routing
- **Routes/Views**: New screens with MVVM pattern and proper state management
- **Services**: Backend-integrated services with automatic backend detection
- **Models**: Type-safe data classes with JSON serialization

### 🏗️ Architectural Patterns Enforced

- MVVM pattern with `simple_mvvm`
- ViewState pattern (initial, loading, success, error)
- Feature-based code organization
- Dependency injection with `injectable`
- Comprehensive error handling
- Analytics integration points

### 🎨 Code Quality Standards

- Type-safe code (explicit types, avoid dynamic)
- Comprehensive dartdoc documentation
- No leading underscores convention
- Const constructors where applicable
- Proper null safety

### 🎭 UI Standards

- Constants-based spacing (vGap, hGap, padding utilities)
- Theme-aware styling (context.textTheme, context.colorScheme)
- Loading and error states
- Proper form validation
- Accessibility considerations

### 🔧 Backend Integration

- **Auto-detection**: Automatically detects Firebase, Supabase, or Pocketbase
- **Backend-specific code**: Generates appropriate implementation patterns
- **Error handling**: Feature-specific exceptions with meaningful messages
- **Type safety**: Proper model serialization and deserialization

## Usage

### Basic Command

```bash
/create
```

This launches the interactive code generator. You'll be asked what you want to create:

1. **Feature** - Complete new feature
2. **Route** - New view in existing feature
3. **Service** - New service in existing feature
4. **Model** - New model in existing feature

### Example: Creating a Feature

```
You: /create
Plugin: What would you like to create?
You: Feature
Plugin: What is the feature name?
You: Product Catalog
Plugin: What is the main purpose of this feature?
You: Browse and search products
... [detailed interview continues] ...
Plugin: ✓ Feature created successfully!
```

The plugin will generate:
```
lib/features/product_catalog/
├── models/
│   └── product.dart
├── services/
│   └── product_catalog_service.dart
├── ui/
│   ├── product_catalog_view.dart
│   ├── product_catalog_view_model.dart
│   └── widgets/
│       └── product_list_tile.dart
└── utils/
    └── product_catalog_exception.dart
```

Plus automatic integration with:
- Router (new routes added)
- Services (getters added to services.dart)
- Main (setup calls if needed)
- Build runner (generates .g.dart files)

## Components

### Skills

#### `/create`
Main entry point for code generation. Provides interactive menu and routes to appropriate agent based on user selection.

### Commands

#### `/add-todo`
Add a new todo to all other Sapid Labs Flutter projects in the work directory. This command:
- Prompts for todo description, reason, and affected files
- Scans the work directory for other Flutter projects
- Creates or updates `sapid-todos.md` in each project
- Skips duplicates automatically
- Leaves changes unstaged for manual review

**Usage:**
```bash
/add-todo
```

The command will interactively ask for:
1. **Description**: What change should be shared (required)
2. **Reason**: Why this change was made (optional)
3. **Files**: Which files are affected (optional, comma-separated)

**Example workflow:**
```
Template Project → /add-todo → Updates all child apps' sapid-todos.md
Child App → /add-todo → Updates template's sapid-todos.md
```

#### `/sync-todos`
View and implement pending todos from the current project's `sapid-todos.md` file. This command:
- Displays all pending todos with details
- Lets you select which ones to implement via checkboxes
- AI implements each selected todo
- Removes implemented todos from the file

**Usage:**
```bash
/sync-todos
```

The command will:
1. Show a preview of all pending todos
2. Let you select which to implement (multi-select)
3. Implement each selected todo
4. Remove completed todos from sapid-todos.md

**Todo format in sapid-todos.md:**
```markdown
- Add PhoneNumberValidator (Reason: improve data quality) [Files: lib/validators/phone.dart]
<!-- Added: 2026-01-18, From: sapid_labs_flutter_template -->
```

### Agents

#### `feature-creator`
Creates complete features with all necessary components. Conducts comprehensive interviews about:
- Feature purpose and structure
- Data models and properties
- Service requirements and operations
- Detailed UI requirements
- Authentication needs
- Analytics events

#### `route-creator`
Adds new routes/views to existing features. Focuses on:
- UI structure and components
- Route parameters
- Loading and error states
- Form fields and validation
- Integration with existing services

#### `service-creator`
Creates service classes with:
- Automatic backend detection
- CRUD operations
- Error handling
- Lifecycle management (@singleton vs @lazySingleton)
- Dependency injection integration

#### `model-creator`
Generates data model classes with:
- JSON serialization (@JsonSerializable)
- Type-safe properties
- copyWith for immutability
- Proper equality and toString

### Utilities

#### `naming.md`
Conversion utilities for consistent naming:
- toSnakeCase (files, directories)
- toPascalCase (classes)
- toKebabCase (routes)
- toCamelCase (variables)

#### `backend-detector.md`
Automatic backend detection:
- Scans existing services
- Identifies Firebase, Supabase, or Pocketbase patterns
- Generates backend-specific code

#### `file-generators.md`
File update strategies:
- Router integration patterns
- services.dart getter addition
- main.dart setup calls
- Import management

## Conventions Reference

### Naming Conventions

| Context | Convention | Example |
|---------|------------|---------|
| Feature directory | snake_case | `user_profile/` |
| Dart files | snake_case | `user_profile_view.dart` |
| Classes | PascalCase | `UserProfileView` |
| Variables | camelCase | `userProfile` |
| Routes | kebab-case | `/user-profile` |
| Collections | lowercase plural | `users` |

### File Organization

```
lib/features/{feature}/
├── models/              # Data models only
├── services/            # Business logic & data access
├── ui/                  # Views and ViewModels
│   ├── {feature}_view.dart
│   ├── {feature}_view_model.dart
│   └── widgets/         # Feature-specific widgets
└── utils/               # Feature utilities
    └── {feature}_exception.dart
```

### ViewModel Pattern

```dart
enum ViewState { initial, loading, success, error }

class MyViewModel extends ViewModel<MyViewModel> {
  ViewState viewState = ViewState.initial;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    viewState = ViewState.loading;
    setState();

    try {
      // Load data
      viewState = ViewState.success;
      setState();
    } catch (e) {
      errorMessage = e.toString();
      viewState = ViewState.error;
      setState();
    }
  }
}
```

### View Pattern

```dart
@RoutePage()
class MyView extends StatefulWidget {
  const MyView({super.key});

  @override
  State<MyView> createState() => _MyViewState();
}

class _MyViewState extends State<MyView> {
  @override
  Widget build(BuildContext context) {
    return MyViewModelBuilder(
      builder: (context, viewModel) {
        if (viewModel.viewState == ViewState.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.viewState == ViewState.error) {
          return Center(child: Text(viewModel.errorMessage ?? 'Error'));
        }

        return Scaffold(/* UI */);
      },
    );
  }
}
```

## Code Generation Rules

### Required Imports

Views must import:
```dart
import '../../shared/utils/color_utils.dart';
import '../../shared/utils/constants.dart';
import '../../shared/utils/text_utils.dart';
```

### Spacing

Use constants:
```dart
vGap8, vGap16, vGap24, vGap32
hGap8, hGap16, hGap24, hGap32
allPadding8, allPadding16, allPadding24
horizontalPadding16, verticalPadding16
```

### Styling

Use theme extensions:
```dart
Text('Title', style: context.textTheme.headlineLarge)
Container(color: context.colorScheme.primary)
```

### Error Handling

Always wrap async operations:
```dart
try {
  // Operation
} on FeatureException catch (e) {
  // Handle feature-specific error
} catch (e) {
  // Handle unexpected error
} finally {
  setState();
}
```

## Backend-Specific Patterns

### Firebase

```dart
final firestore = FirebaseFirestore.instance;
final collection = firestore.collection('users');

Future<User> getUser(String id) async {
  final doc = await collection.doc(id).get();
  return User.fromJson(doc.data()!);
}
```

### Supabase

```dart
final supabase = Supabase.instance.client;

Future<User> getUser(String id) async {
  final data = await supabase
      .from('users')
      .select()
      .eq('id', id)
      .single();
  return User.fromJson(data);
}
```

### Pocketbase

```dart
final pb = PocketBase('https://your-url.com');

Future<User> getUser(String id) async {
  final record = await pb.collection('users').getOne(id);
  return User.fromJson(record.toJson());
}
```

## Generated File Checklist

After generation, you'll have:

- [ ] Feature specification in `feature-plans/`
- [ ] Models with @JsonSerializable in `models/`
- [ ] Service with error handling in `services/`
- [ ] View with @RoutePage in `ui/`
- [ ] ViewModel with ViewState in `ui/`
- [ ] Custom widgets in `ui/widgets/` (if needed)
- [ ] Exception class in `utils/`
- [ ] Route added to `lib/app/router.dart`
- [ ] Service getter in `lib/app/services.dart`
- [ ] Setup call in `lib/main.dart` (if needed)
- [ ] Build runner executed successfully

## Troubleshooting

### Build Runner Fails

If `flutter pub run build_runner build` fails:
1. Check for syntax errors in generated files
2. Verify all imports resolve
3. Run with `--delete-conflicting-outputs` flag
4. Check console output for specific errors

### Route Not Found

If navigation fails:
1. Verify route added to router.dart
2. Run build_runner to regenerate router.gr.dart
3. Check route path matches navigation call
4. Verify guards allow access

### Service Not Found

If service not available:
1. Check service registered in dependency injection
2. Verify getter in services.dart
3. Run build_runner to update DI config
4. Check service class has @injectable annotation

## Best Practices

1. **Interview Thoroughly**: Provide detailed answers during the interview process
2. **Review Generated Code**: Always review and customize generated code
3. **Test Incrementally**: Test each component as it's generated
4. **Customize Styling**: Adjust UI to match your design system
5. **Add Analytics**: Implement the TODO analytics events
6. **Write Tests**: Add unit and widget tests for generated code

## Extension Ideas

Future enhancements could include:
- Testing code generation
- API client generation
- Database migration helpers
- Localization scaffolding
- Animation templates
- Custom theme generation

## Support

For issues or questions:
1. Review this README
2. Check generated code comments
3. Consult Sapid Labs developer guide
4. Review existing features in the codebase

## Version

Version: 1.0.0

## License

Proprietary - Sapid Labs
