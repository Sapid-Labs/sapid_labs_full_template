import 'package:flutter/material.dart';
import 'package:signals/signals.dart';
import 'package:slapp/app/config.dart';
import 'package:slapp/app/constants.dart';
import 'package:slapp/features/shared/ui/app_logo.dart';

class DashboardView extends StatelessWidget {
  DashboardView({super.key});

  final counter = signal(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            AppLogo(
              sideLength: 40,
            ),
            gap8,
            Text(AppConfig.appName),
          ],
        ),
      ),
      body: Placeholder(),
    );
  }
}
