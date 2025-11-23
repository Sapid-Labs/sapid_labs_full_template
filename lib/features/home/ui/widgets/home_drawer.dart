import 'package:slapp/app/router.dart';
import 'package:slapp/app/services.dart';
import 'package:slapp/features/shared/ui/app_logo.dart';
import 'package:slapp/features/shared/ui/app_version.dart';
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
                      leading: Icon(Icons.badge),
                      title: Text('Sign In'),
                      onTap: () {
                        Navigator.of(context).pop();
                        router.push(const SignInEmailRoute());
                      },
                    ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Account'),
                    onTap: () {
                      Navigator.of(context).pop();
                      router.push(const AccountRoute());
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.thumb_up),
                    title: Text('Feedback'),
                    onTap: () {
                      Navigator.of(context).pop();
                      router.push(const FeedbackRoute());
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                    onTap: () {
                      Navigator.of(context).pop();
                      router.push(const SettingsRoute());
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
