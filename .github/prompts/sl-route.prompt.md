---
mode: 'agent'
tools: ['codebase', 'editFiles', 'search']
description: Create a new route using auto_route'
---

Your goal is to create a new route using auto_route in a Flutter application. The route should be added to the `lib/features/{feature}/ui` directory under the appropriate feature. Route files should be named `feature_name_route.dart`, and the route should be annotated with `@RoutePage`.

For example:
```dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

@RoutePage()
class DemoView extends StatefulWidget {
  const DemoView({super.key});

  @override
  State<DemoView> createState() => _DemoViewState();
}

class _DemoViewState extends State<DemoView> with SignalsMixin {
  late final counter = createSignal(0);

  @override
  Widget build(BuildContext context) {
    return Text('Counter: ${counter.value}');
  }
}
```

New routes must also be added to the [router.dart](../../lib/app/router.dart) file.
