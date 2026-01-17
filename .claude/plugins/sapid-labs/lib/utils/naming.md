# Naming Utilities

This document provides naming convention utilities for converting user input to proper Dart/Flutter naming formats following Sapid Labs standards.

## Conversion Rules

### Input Examples
- "User Profile" (title case with spaces)
- "user profile" (lowercase with spaces)
- "userProfile" (camelCase)
- "user_profile" (snake_case)
- "user-profile" (kebab-case)

### Output Formats

#### Files and Directories
- **Feature directories**: `user_profile` (snake_case)
- **View files**: `user_profile_view.dart` (snake_case)
- **ViewModel files**: `user_profile_view_model.dart` (snake_case)
- **Service files**: `user_profile_service.dart` (snake_case)
- **Model files**: `user_profile.dart` (snake_case)
- **Widget files**: `profile_info_card.dart` (snake_case)

#### Classes
- **Views**: `UserProfileView` (PascalCase)
- **ViewModels**: `UserProfileViewModel` (PascalCase)
- **Services**: `UserProfileService` (PascalCase)
- **Models**: `UserProfile` (PascalCase)
- **Widgets**: `ProfileInfoCard` (PascalCase)
- **Exceptions**: `UserProfileException` (PascalCase)

#### Routes
- **Route names**: `user-profile` (kebab-case)
- **Route paths**: `/user-profile/:id` (kebab-case with params)
- **Route classes**: `UserProfileRoute` (PascalCase)

#### Variables
- **Local variables**: `userProfile` (camelCase)
- **Service getters**: `userProfileService` (camelCase)
- **Parameters**: `userId`, `userName` (camelCase)

## Conversion Functions

### toSnakeCase
Converts any format to snake_case for files and directories.

**Examples**:
- "User Profile" → "user_profile"
- "userProfile" → "user_profile"
- "UserProfile" → "user_profile"
- "user-profile" → "user_profile"

**Algorithm**:
1. Replace spaces and hyphens with underscores
2. Insert underscore before capital letters (except first)
3. Convert to lowercase
4. Remove consecutive underscores
5. Trim leading/trailing underscores

### toPascalCase
Converts any format to PascalCase for class names.

**Examples**:
- "user profile" → "UserProfile"
- "user_profile" → "UserProfile"
- "user-profile" → "UserProfile"
- "userProfile" → "UserProfile"

**Algorithm**:
1. Split on spaces, underscores, hyphens, or capital letters
2. Capitalize first letter of each word
3. Join without separators
4. Ensure first character is uppercase

### toKebabCase
Converts any format to kebab-case for routes.

**Examples**:
- "User Profile" → "user-profile"
- "userProfile" → "user-profile"
- "user_profile" → "user-profile"
- "UserProfile" → "user-profile"

**Algorithm**:
1. Replace spaces and underscores with hyphens
2. Insert hyphen before capital letters (except first)
3. Convert to lowercase
4. Remove consecutive hyphens
5. Trim leading/trailing hyphens

### toCamelCase
Converts any format to camelCase for variables.

**Examples**:
- "User Profile" → "userProfile"
- "user_profile" → "userProfile"
- "user-profile" → "userProfile"
- "UserProfile" → "userProfile"

**Algorithm**:
1. Split on spaces, underscores, hyphens, or capital letters
2. Lowercase first word
3. Capitalize first letter of subsequent words
4. Join without separators
5. Ensure first character is lowercase

### singularize
Converts plural nouns to singular.

**Examples**:
- "users" → "user"
- "profiles" → "profile"
- "categories" → "category"
- "children" → "child"

**Common Rules**:
- Remove trailing 's' (users → user)
- "ies" → "y" (categories → category)
- "ves" → "f" (wolves → wolf)
- Irregular forms: children → child, people → person

### pluralize
Converts singular nouns to plural.

**Examples**:
- "user" → "users"
- "profile" → "profiles"
- "category" → "categories"
- "child" → "children"

**Common Rules**:
- Add 's' (user → users)
- "y" → "ies" (category → categories)
- "f" → "ves" (wolf → wolves)
- Irregular forms: child → children, person → people

## Usage Examples

### Feature Creation
**User input**: "User Profile"

Generated names:
- Feature directory: `lib/features/user_profile/`
- View file: `lib/features/user_profile/ui/user_profile_view.dart`
- View class: `UserProfileView`
- ViewModel file: `lib/features/user_profile/ui/user_profile_view_model.dart`
- ViewModel class: `UserProfileViewModel`
- Service file: `lib/features/user_profile/services/user_profile_service.dart`
- Service class: `UserProfileService`
- Service getter: `UserProfileService get userProfileService => ...`
- Route name: `user-profile`
- Route path: `/user-profile/:id`

### Model Creation
**User input**: "product category"

Generated names:
- File: `lib/features/products/models/product_category.dart`
- Class: `ProductCategory`
- Variable: `productCategory`
- JSON key: `product_category` (for API)

### Widget Creation
**User input**: "Profile Info Card"

Generated names:
- File: `lib/features/user_profile/ui/widgets/profile_info_card.dart`
- Class: `ProfileInfoCard`
- Constructor param: `profileInfoCard` (if passed as widget)

## Special Cases

### Acronyms
Preserve common acronyms but follow casing rules:
- "API Service" → `api_service.dart`, `APIService`, `apiService`
- "HTTP Client" → `http_client.dart`, `HTTPClient`, `httpClient`
- "UI Component" → `ui_component.dart`, `UIComponent`, `uiComponent`

### Numbers
Handle numbers appropriately:
- "Item2" → `item_2.dart`, `Item2`, `item2`
- "OAuth2Service" → `oauth2_service.dart`, `OAuth2Service`, `oauth2Service`

### Reserved Words
Avoid Dart reserved words by appending context:
- "class" → `class_model.dart`, `ClassModel`
- "new" → `new_item.dart`, `NewItem`
- "this" → `this_context.dart`, `ThisContext`

## Validation Rules

When converting user input, validate:

1. **No empty strings**: Input must have at least one character
2. **No special characters**: Only letters, numbers, spaces, hyphens, underscores
3. **Starts with letter**: Class names must start with letter (A-Z, a-z)
4. **No reserved words**: Check against Dart reserved word list
5. **Reasonable length**: Feature names 2-50 characters

## Implementation Guidelines

When using these naming utilities in agents:

1. **Always normalize input first**: Convert user input to consistent format
2. **Apply conversions consistently**: Use same rules across all file generation
3. **Preserve semantic meaning**: Don't over-transform (e.g., "iOS" shouldn't become "i_os")
4. **Handle edge cases gracefully**: Provide helpful error messages for invalid input
5. **Document assumptions**: When making naming decisions, explain reasoning

## Example Conversion Pipeline

For input "User Authentication Service":

```
Original input: "User Authentication Service"
           ↓
toSnakeCase: "user_authentication_service"
           ↓
Feature dir: lib/features/user_authentication_service/
File names: user_authentication_service_view.dart
           user_authentication_service_view_model.dart
           user_authentication_service.dart (service)
           ↓
toPascalCase: "UserAuthenticationService"
           ↓
Class names: UserAuthenticationServiceView
            UserAuthenticationServiceViewModel
            UserAuthenticationService
           ↓
toCamelCase: "userAuthenticationService"
           ↓
Variables: userAuthenticationService (getter)
          userAuthenticationServiceInstance
           ↓
toKebabCase: "user-authentication-service"
           ↓
Routes: /user-authentication-service
       user-authentication-service (route name)
```

## Best Practices

1. **Consistency First**: Always use the same conversion for the same context
2. **User-Friendly**: Accept various input formats, output standardized names
3. **Descriptive**: Prioritize clarity over brevity
4. **Follow Flutter Conventions**: Align with official Flutter/Dart style guide
5. **Predictable**: Users should be able to guess the output format
