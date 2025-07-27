import 'package:slapp/app/constants.dart';
import 'package:slapp/app/router.dart';
import 'package:slapp/app/services.dart';
import 'package:slapp/features/auth/services/auth_service.dart';
import 'package:slapp/features/shared/utils/color_utils.dart';
import 'package:slapp/features/shared/utils/text_utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:signals/signals_flutter.dart';
import 'package:slapp/app/constants.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  bool isSigningOut = false;

  Future<void> handleUpdatePassword() async {
    if (mounted) {
      await router.push(ChangePasswordRoute());
    }
  }

  Future<void> handleSignOut() async {
    if (isSigningOut) return;

    setState(() {
      isSigningOut = true;
    });
    try {
      subscriptionService.signOut();
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

  Widget sectionTitle(String title) {
    return Padding(
      padding: paddingH16,
      child: Text(
        title,
        style: context.titleMedium.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Watch((context) {
        return ListView(
          padding: paddingH16.add(EdgeInsets.symmetric(vertical: 8)),
          children: [
            sectionTitle('Account'),
            gap8,

            Card(
              child: ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: Text(authEmail.value ?? 'No email'),
              ),
            ),
            gap8,
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile Information'),
                subtitle: const Text('Edit your name, username, and bio'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  router.push(ProfileRoute());
                },
              ),
            ),
            gap8,
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: context.primary,
                ),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.auto_awesome,
                  color: context.primary,
                ),
                title: Text(
                  'Bakedown Premium',
                  style: context.titleMedium.bold.primary,
                ),
                subtitle: Text(
                  'Unlimited recipes, components, and more',
                  style: context.bodyMedium.bold,
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  router.push(const SubscriptionRoute());
                },
              ),
            ),
            gap32,
            sectionTitle('Feedback'),
            gap8,
            Card(
              child: ListTile(
                leading: const Icon(Icons.star_rate),
                title: const Text('Rate Bakedown'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  final InAppReview inAppReview = InAppReview.instance;

                  inAppReview.openStoreListing(
                    appStoreId: const String.fromEnvironment("APP_STORE_ID"),
                  );
                },
              ),
            ),
            gap32,
            sectionTitle('Follow Us'),
            gap8,
            Card(
              child: ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Instagram'),
                subtitle: const Text('@bakedownapp'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  launchUrl(Uri.parse('https://instagram.com/bakedownapp'));
                },
              ),
            ),
            gap8,
            Card(
              child: ListTile(
                leading: const Icon(Icons.chat_bubble_outline),
                title: const Text('Threads'),
                subtitle: const Text('@bakedownapp'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  launchUrl(Uri.parse('https://www.threads.com/@bakedownapp'));
                },
              ),
            ),
            gap16,
            OutlinedButton.icon(
              onPressed: handleUpdatePassword,
              icon: const Icon(Icons.lock),
              label: const Text('Update Password'),
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
