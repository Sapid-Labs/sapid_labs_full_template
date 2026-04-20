# CI/CD & Deployment

## Table of Contents
- Fastlane Setup
- iOS Deployment
- Android Deployment
- Shorebird (OTA Updates)
- Slack Notifications
- Version Management
- Release Checklist

## Fastlane Setup

Every Sapid Labs app has Fastlane configured in both `ios/fastlane/` and `android/fastlane/`. The setup follows a consistent pattern across all apps.

### Directory Structure
```
ios/fastlane/
├── .env                  # Environment-specific secrets (gitignored)
├── .env.default          # Template for .env
├── Appfile               # App identifier and Apple ID
├── Deliverfile           # App Store metadata config
├── Fastfile              # Lane definitions
├── Pluginfile            # Fastlane plugins
├── metadata/
│   ├── versionCode       # Auto-incrementing build number
│   └── versionName       # Human-readable version
└── screenshots/

android/fastlane/
├── .env                  # Environment-specific secrets (gitignored)
├── .env.default          # Template for .env
├── Appfile               # Package name and JSON key path
├── Fastfile              # Lane definitions
├── Pluginfile            # Fastlane plugins
└── metadata/
    └── versionCode       # Auto-incrementing build number
```

### Required Environment Variables (.env)
```
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...
```

For iOS, the Appfile needs:
```ruby
app_identifier("com.sapidlabs.yourapp")
apple_id("your@email.com")
team_id("TEAM_ID")
```

For Android, the Appfile needs:
```ruby
json_key_file("path/to/google-play-key.json")
package_name("com.sapidlabs.yourapp")
```

## iOS Deployment

### TestFlight (Beta)
```bash
cd ios && fastlane beta
# Optional: pass env:dev for dev build
cd ios && fastlane beta env:dev
```

What it does:
1. Bumps version code in `metadata/versionCode`
2. Runs `flutter build ipa` with `--dart-define-from-file=assets/config.json`
3. Uploads to TestFlight
4. Sends Slack notification

### App Store (Production)
```bash
cd ios && fastlane prod
```

What it does:
1. Bumps version code
2. Builds IPA
3. Uploads to App Store with `submit_for_review: true` and `automatic_release: true`
4. Sets `export_compliance_uses_encryption: false` and `add_id_info_uses_idfa: false`
5. Sends Slack notification

### Version Format
iOS uses `1.0.{versionCode}` for both build name and build number. The version code auto-increments from the `metadata/versionCode` file.

## Android Deployment

### Internal Testing
```bash
cd android && fastlane internal
# Optional: pass env:dev for dev build
cd android && fastlane internal env:dev
```

### Production
```bash
cd android && fastlane prod
```

### Play Store Tracks
Available tracks: `internal`, `alpha`, `beta`, `production`

The pattern for each is identical — only the `track` parameter changes in `upload_to_play_store`.

### Shorebird Integration
Android lanes use Shorebird for building when available:
```ruby
shorebird_release(platform: "android", args: "-- --build-name=1.0.#{versionCode} --build-number=#{versionCode} #{dart_defines}")
```

The regular `flutter build appbundle` command is kept commented out as a fallback.

## Shorebird (OTA Updates)

Shorebird enables code-push updates without going through app store review.

### Patching an Existing Release
```bash
cd android && fastlane patch_shorebird
```

This patches the current version with updated Dart code. The version code stays the same — it reads the current value from `metadata/versionCode` without bumping.

### Config
Shorebird config lives in `shorebird.yaml` at the project root (included in Flutter assets).

## Slack Notifications

All lanes send Slack notifications on completion via a shared helper lane:
```ruby
lane :send_slack_notification do |options|
  message = options[:message] || "A new update has been pushed!"
  slack(
    message: message,
    success: true,
    slack_url: ENV["SLACK_WEBHOOK_URL"]
  )
end
```

Message format: `"New {track} version 1.0.{versionCode} ({versionCode}) has been pushed to {store}!"`

## Version Management

Version codes are stored in `fastlane/metadata/versionCode` as plain integers. Each lane bumps this file by 1 before building.

To reset version codes (e.g., when starting fresh):
```bash
cd ios && fastlane reset_version_code
cd android && fastlane reset_version_code
```

iOS and Android maintain separate version code counters.

## Release Checklist

Before deploying a new version:

1. Ensure all changes are committed and pushed
2. Run `flutter test` to verify tests pass
3. Verify `assets/config.json` has correct environment values
4. Check that `.env` files exist in both `ios/fastlane/` and `android/fastlane/`
5. For iOS: ensure provisioning profiles and certificates are current
6. For Android: ensure the Google Play JSON key is accessible
7. Run the appropriate Fastlane lane
8. Verify the Slack notification was received
9. For production: monitor crash reports after release

### Common Issues
- **"No signing certificate" (iOS)**: Run `fastlane match` or check Xcode signing settings
- **"Upload failed" (Android)**: Verify the JSON key file path in Appfile and that the service account has permissions
- **Version code conflict**: The Play Store / App Store rejects a version code that's already been used. Check `metadata/versionCode` and bump if needed
