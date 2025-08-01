import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals.dart';

@RoutePage()
class DemoView extends StatelessWidget {
  DemoView({super.key});

  final counter = signal(0);

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}