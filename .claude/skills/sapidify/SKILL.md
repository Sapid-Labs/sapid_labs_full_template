---
name: sapidify
description: Update the mentioned files to use the Sapid Labs coding principles.
---

## Sapid Labs Coding Principles

These files should follow the Sapid Labs Flutter template conventions:

### Naming Conventions
- **No Underscores**: Never use leading underscores for private members
- **Files**: snake_case (user_profile_view.dart)
- **Classes**: PascalCase (UserProfileView)
- **Variables/Methods**: camelCase (currentUser, loadData)
- **Routes**: kebab-case (/user-profile)
- **Collections/Tables**: lowercase plural (users, products)

### UI & Styling
- **Use Constants**: Import constants.dart for spacing (vGap16, hGap16, allPadding16)
- **Use Theme**: context.textTheme, context.colorScheme via utils
- **Const Constructors**: Use const where possible
- **SafeArea**: Default yes for all views

### Architecture (MVVM Pattern)
- **Models**: Data only with @JsonSerializable, fromJson/toJson, copyWith, immutable (final fields)
- **Services**: Business logic, backend integration, error handling with feature-specific exceptions
- **ViewModels**: ViewState enum pattern, error handling, form controllers, extends ViewModel
- **Views**: UI composition with @RoutePage, no logic, use ViewModelBuilder pattern
- **Widgets**: Reusable UI components in feature/ui/widgets/

### State Management & Error Handling
- **ViewState Pattern**: initial, loading, success, error states
- **Error Handling**: Wrap all async in try-catch with proper error states
- **Analytics**: Add TODO comments for tracking events (feature_action_status)

### Dependencies & Services
- **Injection**: Use injectable with @singleton (needs setup) or @lazySingleton
- **Services.dart**: Add getters alphabetically
- **Router**: Use auto_route with AutoRouteGuard for protection

### Documentation
- **Comprehensive Dartdoc**: All public APIs, classes, methods, and properties
- **Use ///**: Not // for documentation
- **Context**: Include purpose, parameters, returns, and exceptions

### Type Safety & Immutability
- **Explicit Types**: Avoid dynamic
- **Non-nullable by Default**: Only use ? when truly optional
- **Final Fields**: All properties should be final
- **CopyWith**: For modifications to immutable objects