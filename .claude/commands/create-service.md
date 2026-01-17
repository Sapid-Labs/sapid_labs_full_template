---
name: create-service
description: Create a new service in the Flutter app according to the Sapid Labs developer guide
---

Your goal is to create a new service in the Dart codebase and register it with GetIt. Follow these steps:

1. Create a new service in the appropriate directory inside the `features` folder. Services should be placed in a directory that matches their functionality, such as `features/authentication/services` for authentication-related services. Services should end in `_service.dart`.

2. Implement the service class with the necessary methods and properties. Ensure that the class is well-structured and follows Dart conventions.

3. Use injectable annotations to register the service with GetIt. For example, use `@injectable`, `@singleton`, or `@lazySingleton` as appropriate for the service's lifecycle.

4. In the central services file at `lib/app/services.dart`, add a line for quick access to the new service. For example:

```dart
FeedbackService get feedbackService => getIt.get<FeedbackService>();
```

5. Run the `flutter pub run build_runner build` command to generate the necessary code for dependency injection.