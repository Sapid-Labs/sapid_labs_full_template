import 'package:flutter/foundation.dart';
import 'package:slapp/app/config.dart';
import 'package:slapp/app/constants.dart';
import 'package:slapp/app/router.dart';
import 'package:slapp/app/services.dart';
import 'package:slapp/features/auth/services/auth_service.dart';
import 'package:slapp/features/shared/ui/app_version.dart';
import 'package:slapp/features/shared/utils/color_utils.dart';
import 'package:slapp/features/shared/utils/text_utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:signals/signals_flutter.dart';
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
      body: SafeArea(
        child: Watch((context) {
          return ListView(
            padding: paddingH16.add(EdgeInsets.symmetric(vertical: 8)),
            children: [
              gap24,
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      gap4,
                      sectionTitle('Account'),
                      gap4,
                      ListTile(
                        leading: const Icon(Icons.email),
                        title: const Text('Email'),
                        subtitle: Text(authEmail.value ?? 'No email'),
                        shape: RoundedRectangleBorder(
                          borderRadius: circular8,
                        ),
                      ),
                      Divider(height: 2),
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Profile Information'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          router.push(ProfileRoute());
                        },
                      ),
                      Divider(height: 2),
                      ListTile(
                        leading: Icon(
                          Icons.auto_awesome,
                          color: context.primary,
                        ),
                        title: Text(
                          '${AppConfig.appName} Premium',
                          style: context.titleMedium.bold.primary,
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          router.push(const SubscriptionRoute());
                        },
                      ),
                      Divider(height: 2),
                      ListTile(
                        leading: Icon(
                          Icons.settings,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(16),
                          ),
                        ),
                        title: Text(
                          'Settings',
                          style: context.titleMedium.bold,
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          router.push(const SettingsRoute());
                        },
                      ),
                    ],
                  ),
                ),
              ),

              gap16,
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      gap4,
                      sectionTitle('Feedback'),
                      gap4,
                      ListTile(
                        leading: const Icon(Icons.thumbs_up_down),
                        title: const Text('Suggest a Feature'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          router.push(FeedbackRoute());
                        },
                      ),
                      Divider(height: 2),
                      ListTile(
                        leading: const Icon(Icons.star_rate),
                        title: const Text('Rate ${AppConfig.appName}'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(16),
                          ),
                        ),
                        onTap: () {
                          final InAppReview inAppReview = InAppReview.instance;

                          inAppReview.openStoreListing(
                            appStoreId:
                                const String.fromEnvironment("APP_STORE_ID"),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              gap16,
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      gap4,
                      sectionTitle('Follow Us'),
                      gap4,
                      ListTile(
                        leading: const Icon(Icons.camera_alt_outlined),
                        title: const Text('Instagram'),
                        subtitle: const Text('@' + AppConfig.instagramUsername),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          launchUrl(Uri.parse(
                              'https://instagram.com/${AppConfig.instagramUsername}'));
                        },
                      ),
                      Divider(height: 2),
                      ListTile(
                        leading: const Icon(Icons.chat_bubble_outline),
                        title: const Text('Threads'),
                        subtitle: const Text('@' + AppConfig.threadsUsername),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          launchUrl(Uri.parse(
                              'https://www.threads.com/@${AppConfig.threadsUsername}'));
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (kDebugMode) ...[
                gap8,
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.android),
                    title: const Text('Demo'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      router.push(DemoRoute());
                    },
                  ),
                ),
              ],
              gap32,

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
              gap24,
              Center(child: AppVersion()),
              gap16,
            ],
          );
        }),
      ),
    );
  }
}
