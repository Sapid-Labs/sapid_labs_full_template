# FoolScript Template

This template repository is designed to kickstart your Flutter application while using an opinionated framework.

## Start

To get started, clone the main branch:

```bash
git clone --branch https://github.com/FoolScript/foolscript
```

This branch will serve as your app's foundation and it contains generic features that are used by all Flutter apps.

Now for the fun part. To add support for a third-party service, like Supabase or Firebase, merge the branch with the service name into the main branch. For example, to add Supabase authentication support to your app, run the following command:

```bash
git merge supabase_auth
```
## Setup Updates

To pull future changes from this template into your project, add the template repository as a remote:

```bash
git remote add template https://github.com/FoolScript/foolscript
```

To pull updates, simply run:

```bash
git fetch --all
git merge template/main --allow-unrelated-histories
```

You can also run the `git merge` command for any branch in the template repo. For example:

```bash
git merge template/auth_supabase --allow-unrelated-histories
```

If you see the following error:

```
remote: Write access to repository not granted.
fatal: unable to access 'https://github.com/FoolScript/foolscript/': The requested URL returned error: 403
error: could not fetch template
``

Reauthenticate with GitHub using this command:

```bash
gh auth login
```

## Branches

| Branch | Description |
| --- | --- |
| main | The foundation of the app. |
| supabase | Adds Supabase authentication, database, and storage. |
| firebase | Adds Firebase authentication, database, analytics, and storage. |
| pocketbase | Adds PocketBase authentication, database, and storage. |
| appwrite | Adds AppWrite authentication, database, and storage. |
| amplitude_analytics | Adds Amplitude analytics support. |
| revenuecat_subscriptions | Adds RevenueCat subscriptions support. |

## State Strategy

Global state exists in global signals. Services registered in get_it can be used to manipulate this state. For example, the `authService` contains functions that can update the `authUserId` and `authEmail` global signals.

Global signals typically exist in the same file as their corresponding service and are prefixed with the service name. For example, `authUserId` exists in the same file as the `AuthService`

## Features

### Authentication

### Analytics

### Database

### Push Notifications

### Storage

### Subscriptions
Subscriptions are implemented using RevenueCat

### Extras

- Constant gaps
- Flex Color Scheme setup
- VS Code `tasks.json` file
- App version widget
- Reusable app logo and name widgets
- Copilot instructions

## Platforms

### Firebase

In the root of the project, run the following command to setup Firebase:

```bash
flutterfire config --project=my_project
```

You can [safely commit the firebase_config.dart to your git repo](https://github.com/firebase/flutterfire/discussions/7617#discussioncomment-2667871).

### Supabase

## Assets

Images in the `assets` folder are [resolution-aware](https://docs.flutter.dev/ui/assets/assets-and-images#resolution-aware).

Sign In Buttons are from the [flutter_signin_button](https://pub.dev/packages/flutter_signin_button) package.
Google Sign-In Buttons: https://developers.google.com/identity/branding-guidelines
Apple Sign-In Buttons: https://developer.apple.com/design/resources/

## Development

We are all Fool Stack Developers 🃏