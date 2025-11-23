# Sapid Laps Template

This template repository is designed to kickstart your Flutter application while using an opinionated framework.

## Start

To get started, clone the template repo using the Github UI or run the following command:

```bash
git clone https://github.com/Sapid-Labs/sapidlabs_flutter_template
```

Now for the fun part. To add support for a third-party service, like Supabase or Firebase, create a `config.json` file in the `assets` folder and change the STACK environment variables to the values you want to use. For example, to use Supabase for authentication and storage, set `STACK_PAAS` to "supabase".

To update the app name, use the search tool to search for `slapp` and replace it with your app name. To update the package name, search for `com.sapidlabs` and replace it with your package name.

## Setup Updates

To pull future changes from this template into your project, add the template repository as a remote:

```bash
git remote add template https://github.com/Sapid-Labs/sapidlabs_flutter_template
```

To pull updates, simply run:

```bash
git fetch --all
git merge template/main --allow-unrelated-histories
```

If you see the following error:

````
remote: Write access to repository not granted.
fatal: unable to access 'https://github.com/Sapid-Labs/sapidlabs_flutter_template/': The requested URL returned error: 403
error: could not fetch template
``

Reauthenticate with GitHub using this command:

```bash
gh auth login
````

## Release Steps

Generate your upload key if you don't already have one:

```bash
keytool -genkey -v -keystore ./keys/vault-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

## Environments

| Environment       | Description                                                     | Type                |
| ----------------- | --------------------------------------------------------------- | ------------------- |
| supabase          | Adds Supabase authentication, database, and storage.            | STACK_PAAS          |
| firebase          | Adds Firebase authentication, database, analytics, and storage. | STACK_PAAS          |
| pocketbase        | Adds PocketBase authentication, database, and storage.          | STACK_PAAS          |
| amplitudeAnalytics         | Adds Amplitude analytics support.                               | STACK_ANALYTICS     |
| firebaseAnalytics | Adds Firebase analytics support.                                | STACK_ANALYTICS     |
| revenuecat        | Adds RevenueCat subscriptions support.                          | STACK_SUBSCRIPTIONS |

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
