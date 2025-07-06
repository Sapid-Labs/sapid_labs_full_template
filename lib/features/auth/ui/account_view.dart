import 'package:auto_route/auto_route.dart';
import 'package:sapid_labs/app/constants.dart';
import 'package:sapid_labs/app/router.dart';
import 'package:sapid_labs/app/services.dart';
import 'package:sapid_labs/features/auth/services/auth_service.dart';
import 'package:sapid_labs/features/shared/utils/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

@RoutePage()
class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  bool isSigningOut = false;

  Future<void> handleResetPassword() async {
    if (mounted) {
      await router.push(ResetPasswordRoute());
    }
  }

  Future<void> handleSignOut() async {
    if (isSigningOut) return;

    setState(() {
      isSigningOut = true;
    });
    try {
      await authService.logout();
      if (mounted) {
        router.replaceAll([const SignInRoute()]);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign out: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        isSigningOut = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: handleSignOut,
          ),
        ],
      ),
      body: Watch((context) {
        return ListView(
          padding: padding16,
          children: [
            gap32,
            // Profile Icon
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  (authEmail.value ?? '?')[0].toUpperCase(),
                  style: context.displayMedium.colorWhite,
                ),
              ),
            ),
            gap32,
            // User Info Cards
            Card(
              child: ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: Text(authEmail.value ?? 'No email'),
              ),
            ),
            gap16,
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text('User ID'),
                subtitle: Text(authUserId.value ?? 'No ID'),
              ),
            ),
            gap32,
            OutlinedButton.icon(
              onPressed: handleResetPassword,
              icon: const Icon(Icons.lock),
              label: const Text('Reset Password'),
            ),
            // Sign Out Button
            FilledButton.icon(
              onPressed: handleSignOut,
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
            ),
          ],
        );
      }),
    );
  }
}
