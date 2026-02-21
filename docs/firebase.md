# Firebase

## Setup

Follow the instructions here to install the `flutterfire` CLI: https://firebase.google.com/docs/flutter/setup?platform=ios

```bash
dart pub global activate flutterfire_cli
```

Create a new project in the Firebase console and then run the following command:

```bash
flutterfire configure --ios-bundle-id=com.sapidlabs.slapp -a com.sapidlabs.slapp -p sapid-labs -o lib/app/firebase_options.dart -y -f
```

Follow naming conventions here: https://dart.dev/tools/pub/pubspec#name. Avoid using underscores in the package name as this causes issues when registering the iOS app in Firebase.
