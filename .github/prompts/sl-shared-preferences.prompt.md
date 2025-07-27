---
mode: "agent"
tools: ["codebase", "editFiles", "search"]
description: "Generate a new feature that integrates with shared preferences"
---

Your goal is to create a new feature that integrates with shared preferences in the Dart codebase. Follow these steps:

1. Create the new feature on the selected page.
2. Import shared preferences (`sharedPrefs`) from the [services.dart](../../lib/app/services.dart).

Example:

```dart
import 'package:my_app/app/services.dart';

class MyFeature {

  void saveData(String key, String value) {
    sharedPrefs.setString(key, value);
  }

  String? getData(String key) {
    return sharedPrefs.getString(key);
  }
}
```
