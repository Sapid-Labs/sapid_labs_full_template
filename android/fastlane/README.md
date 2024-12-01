fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Android

### android bump_version_code

```sh
[bundle exec] fastlane android bump_version_code
```



### android prod

```sh
[bundle exec] fastlane android prod
```

Deploy a new version to the Google Play

### android internal

```sh
[bundle exec] fastlane android internal
```

Deploy a new version to the beta test track of Google Play

### android send_slack_notification

```sh
[bundle exec] fastlane android send_slack_notification
```

Send a message to Slack

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
