import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

class StatefulDemo extends StatefulWidget {
  const StatefulDemo({super.key});

  @override
  State<StatefulDemo> createState() => _StatefulDemoState();
}

class _StatefulDemoState extends State<StatefulDemo> with SignalsMixin {
  late final counter = createSignal(0);

  @override
  Widget build(BuildContext context) {
    return Text('Counter: ${counter.value}');
  }
}
