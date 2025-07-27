import 'package:flutter/material.dart';
import 'package:signals/signals.dart';

class StatelessDemo extends StatelessWidget {
  StatelessDemo({super.key});

  final counter = signal(0);

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
