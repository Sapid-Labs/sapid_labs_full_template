---
name: create-feature
description: Create a new feature in the Flutter app according to the Sapid Labs developer guide
---

Create a new feature in the Flutter app according to the user's request:

$ARGUMENTS$

## Process

### Plan
Interview me in detail about the requested feature using the AskUserQuestionTool about literally anything: technical implementation, UI & UX, concerns, tradeoffs, etc. but make sure the questions are not obvious. Be very in-depth and interview me continually until it's complete, then write the spec to a file in the `feature-plans` directory at the root of the project.

Once the plan is complete, implement the feature while respecting the following rules:

### Folder Structure
All features should be added to the `lib/features` directory. Each feature should have it's own directory in the `lib/features` directory.

Features should have the following subdirectories:
- `ui`: Directory for views and widgets
- `services`: Directory for get_it services related to the feature
- `models`: Directory for data model definititons related to this feature. Models are dart Classes
- (optional) `utils` - Utility functions or classes specific to the feature

### View and ViewModel Naming
At the root of the feature directory, create a view and view model. Each file should be named after the feature and they should use the following format:
- my_feature_view.dart
- my_feature_view_model.dart

### Update Router
Add the new route to `lib/app/router.dart`.