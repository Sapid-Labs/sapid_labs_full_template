---
type: skill
name: create
description: Create features, routes, services, or models following Sapid Labs Flutter conventions
---

# Sapid Labs Code Generator

Welcome! I'll help you create new components for your Sapid Labs Flutter project following all established conventions and patterns.

## What Can I Create?

I can generate:

1. **Complete Feature** - Full feature with models, services, views, ViewModels, widgets, and router integration
2. **Route/View** - Add a new view to an existing feature with ViewModel and router setup
3. **Service** - Add a service to an existing feature with backend integration and error handling
4. **Model** - Add a data model to an existing feature with JSON serialization

## How It Works

Based on your selection, I'll:
- Interview you for requirements (UI, data, functionality)
- Detect your active backend (Firebase, Supabase, Pocketbase)
- Generate production-ready code following all Sapid Labs conventions
- Integrate with your router, services, and dependency injection
- Run build_runner to complete the setup

## Let's Get Started

What would you like to create?

1. **Feature** - Complete new feature (recommended for new functionality)
2. **Route** - Add view to existing feature
3. **Service** - Add service to existing feature
4. **Model** - Add model to existing feature

---

## Usage Instructions

### Creating a Feature

When you select "Feature", I will:
1. Ask about the feature name and purpose
2. Interview you about data models needed
3. Ask if you need a service and what operations
4. Conduct detailed UI requirements interview
5. Ask about authentication requirements
6. Identify key analytics events to track

Then I'll generate:
- Complete directory structure
- Models with @JsonSerializable
- Service with backend integration (if needed)
- View and ViewModel with MVVM pattern
- Custom widgets (if needed)
- Exception class
- Router integration
- Service registration
- Feature specification document

**Example**: Creating a "User Profile" feature will generate everything needed to view and edit user profiles with proper error handling, loading states, and backend integration.

### Creating a Route

When you select "Route", I will:
1. Ask which feature this route belongs to
2. Interview you about the view purpose
3. Conduct detailed UI requirements interview
4. Ask about route parameters
5. Determine authentication requirements

Then I'll generate:
- View file with @RoutePage
- ViewModel with ViewState pattern
- Router integration
- Custom widgets (if complex UI)

**Example**: Adding a "Settings" route to an existing feature creates a new view with form fields, proper state management, and navigation integration.

### Creating a Service

When you select "Service", I will:
1. Ask which feature this service belongs to
2. Ask about service operations and purpose
3. Detect your active backend automatically
4. Determine if service needs initialization

Then I'll generate:
- Service class with backend-specific implementation
- Exception class for error handling
- services.dart integration
- main.dart setup call (if initialization needed)

**Example**: Adding a "Notifications" service will create a service with Firebase Cloud Messaging integration, error handling, and proper dependency injection.

### Creating a Model

When you select "Model", I will:
1. Ask which feature this model belongs to
2. Interview you about model properties
3. Ask about relationships to other models

Then I'll generate:
- Model class with @JsonSerializable
- fromJson/toJson factories
- copyWith method for immutability
- Proper equality and toString implementations

**Example**: Adding a "Product" model creates a fully-typed, serializable data class ready for use in your feature.

---

## Conventions Enforced

All generated code follows these Sapid Labs standards:

### Architecture
- MVVM pattern with simple_mvvm package
- ViewState enum pattern (initial, loading, success, error)
- Feature-based organization
- Dependency injection with injectable

### Code Style
- No leading underscores for private members
- Comprehensive dartdoc documentation
- Type-safe code (avoid dynamic)
- Const constructors where possible

### UI Standards
- Use constants.dart for spacing (vGap, hGap, padding utilities)
- Use context.textTheme for text styles (via text_utils)
- Use context.colorScheme for colors (via color_utils)
- Proper loading and error states in all views

### Error Handling
- Try-catch around all async operations
- Feature-specific exception classes
- Error state in ViewModels
- User-friendly error messages

### Backend Integration
- Auto-detection of active backend
- Backend-specific service implementations
- Proper async/await patterns
- Null safety throughout

### Naming Conventions
- Features: snake_case directories
- Files: snake_case
- Classes: PascalCase
- Variables: camelCase
- Routes: kebab-case

---

## Getting Help

If you're unsure what to create:
- **New functionality** → Create a Feature
- **New screen in existing feature** → Create a Route
- **New data operations** → Create a Service
- **New data structure** → Create a Model

---

Now, what would you like to create? Please respond with:
- "Feature" (or 1)
- "Route" (or 2)
- "Service" (or 3)
- "Model" (or 4)

Or describe what you want to build and I'll help you choose the right option.
