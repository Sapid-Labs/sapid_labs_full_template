# Firebase

## Setup

Follow the instructions here to install the `flutterfire` CLI: https://firebase.google.com/docs/flutter/setup?platform=ios

Create a new project in the Firebase console and then run the following command:

```bash
flutterfire config --ios-bundle-id=com.sapidlabs.slapp --android-app-id=com.sapidlabs.slapp
```

Follow naming conventions here: https://dart.dev/tools/pub/pubspec#name. Avoid using underscores in the package name as this causes issues when registering the iOS app in Firebase.

Update the `config.json` file to set `STACK_PAAS` equal to "firebase".
