# Flutter Fast App

This template repository is designed to kickstart your Flutter application while using an opinionated framework.

## Start

To get started, clone the main branch:

```bash
git clone --branch https://github.com/jtmuller5/flutter_fast_app
```

This branch will serve as your app's foundation and it contains generic features that are used by all Flutter apps.

Now for the fun part. To add support for a third-party service, like Supabase or Firebase, merge the branch with the service name into the main branch. For example, to add Supabase authentication support to your app, run the following command:

```bash
git merge supabase_auth
```
## Setup Updates

To pull future changes from this template into your project, add the template repository as a remote:

```bash
git remote add template https://github.com/CodeOTR/flutter_fast_app
```

To pull updates, simply run:

```bash
git fetch --all
```

## Branches

| Branch | Description |
| --- | --- |
| main | The foundation of the app. |
| supabase_auth | Adds Supabase authentication support. |
| firebase_auth | Adds Firebase authentication support. |
| supabase_analytics | Adds Supabase analytics support. |
| firebase_analytics | Adds Firebase analytics support. |
| supabase_database | Adds Supabase database support. |
| firebase_database | Adds Firebase database support. |
| supabase_push_notifications | Adds Supabase push notifications support. |
| firebase_push_notifications | Adds Firebase push notifications support. |
| supabase_storage | Adds Supabase storage support. |
| firebase_storage | Adds Firebase storage support. |
| revenuecat_subscriptions | Adds RevenueCat subscriptions support. |

## Features

### Authentication

### Analytics

### Database

### Push Notifications

### Storage

### Subscriptions

### Extras

- Constant gaps
- Flex Color Scheme setup
- VS Code `tasks.json` file
- App version widget
- Reusable app logo and name widgets
- Copilot instructions

## Assets

Images in the `assets` folder are [resolution-aware](https://docs.flutter.dev/ui/assets/assets-and-images#resolution-aware).

Sign In Buttons are from the [flutter_signin_button](https://pub.dev/packages/flutter_signin_button) package.
Google Sign-In Buttons: https://developers.google.com/identity/branding-guidelines
Apple Sign-In Buttons: https://developer.apple.com/design/resources/

## Development
