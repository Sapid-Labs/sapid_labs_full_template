---
mode: "agent"
tools: ["codebase", "editFiles", "search"]
description: "Create an enum in dart using the enhanced enum syntax"
---

Your goal is to create a new enum in Dart using the enhanced enum syntax. Typically, enums should have a name property with a human-readable string and a value property for the actual value. The enum should also override the `toString` method to return a custom string representation.

For example;

```dart
enum ColorNames {
  red(Colors.red,"Red"),
  green(Colors.green,"Green"),
  blue(Colors.blue,"Blue");

  final Color color;
  final String name;
  const ColorNames(this.color,this.name);

  @override
  String toString(){
    super.toString();
    return "Color name is: $name";
  }
}
```

When necessary, add additional properties or methods to the enum to enhance its functionality.