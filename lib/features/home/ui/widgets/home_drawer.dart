import 'package:cotr_flutter_app/app/router.dart';
import 'package:cotr_flutter_app/app/services.dart';
import 'package:cotr_flutter_app/features/shared/ui/app_logo.dart';
import 'package:cotr_flutter_app/features/shared/ui/app_version.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListTileTheme(
        data: ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(horizontal: 0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(child: AppLogo()),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  if (kDebugMode)
                    ListTile(
                      title: Text('Sign In'),
                      onTap: () {
                        router.push(const SignInRoute());
                      },
                    ),
                  ListTile(
                    title: Text('Account'),
                    onTap: () {
                      router.push(const AccountRoute());
                    },
                  ),
                  AppVersion(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
