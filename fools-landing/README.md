# Start

1. Replace all instances of `fools` and `Fools` with your project name.
2. Replace the Google Play and App Store URLs with your app links.

# Mockups

Use this Figma file to create device mockups:
https://www.figma.com/design/Ujf1YMU8esGvbh5ZM2CnWo/Mobile-Device-Mockups-(Community)

After adding your screenshots to a device, you can select the device and then select "Export" to export .png or .svg files.

Google Play Badges: https://partnermarketinghub.withgoogle.com/brands/google-play/visual-identity/badge-guidelines/?folder=65628
Apple App Store Badges: https://developer.apple.com/app-store/marketing/guidelines/

# Hosting

Run the following to setup Firebase hosting:

```bash
firebase init
```

.firebaserc should look like this:

```
{
  "projects": {
    "default": "abi-s-recipes"
  }
}
```

firebase.json should look like this:

```json
{
  "hosting": {
    "source": ".",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "frameworksBackend": {
      "region": "us-east1"
    }
  }
}
```

Use the "Deploy" VS Code task to deploy to Firebase.