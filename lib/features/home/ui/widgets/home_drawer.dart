import 'package:cotr_flutter_app/features/shared/ui/app_logo.dart';
import 'package:cotr_flutter_app/features/shared/ui/app_version.dart';
import 'package:flutter/material.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(child: AppLogo()),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                AppVersion(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
