/// One platform's entry in the remote update manifest.
///
/// The manifest is a small JSON document the app fetches on launch. It is not
/// read from either store: Play has no public "what is the latest version" API,
/// and scraping a store listing is off-limits, so the version we consider
/// current is one we publish ourselves next to the release.
///
/// ```json
/// {
///   "android": {
///     "latest": "1.4.0",
///     "minSupported": "1.2.0",
///     "notes": "Faster sync and a fix for the paywall.",
///     "storeUrl": "https://play.google.com/store/apps/details?id=com.x.y"
///   },
///   "ios": { "latest": "1.4.0", "minSupported": "1.2.0" }
/// }
/// ```
///
/// Every field is optional. A missing or unparseable field reads as empty and
/// downgrades the prompt rather than throwing, because a malformed manifest
/// must never be able to block a user out of a working app.
class AppUpdateInfo {
  const AppUpdateInfo({
    this.latestVersion = '',
    this.minSupportedVersion = '',
    this.releaseNotes = '',
    this.storeUrl = '',
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) => AppUpdateInfo(
        latestVersion: _string(json['latest']),
        minSupportedVersion: _string(json['minSupported']),
        releaseNotes: _string(json['notes']),
        storeUrl: _string(json['storeUrl']),
      );

  /// The newest version published to this platform's store.
  final String latestVersion;

  /// The oldest version that still works against the current backend.
  ///
  /// Below this the prompt cannot be dismissed. Leave it empty unless an
  /// older build is genuinely broken -- a forced update is the most
  /// user-hostile thing in this file.
  final String minSupportedVersion;

  /// What changed, shown in the dialog. One short sentence.
  final String releaseNotes;

  /// Where "Update now" sends the user. Optional: [storeUrlFor] falls back to
  /// the Play listing for the running package when this is empty.
  final String storeUrl;

  static String _string(Object? value) =>
      value is String ? value.trim() : '';
}

/// How hard the app should push the update.
enum UpdateUrgency {
  /// Nothing to say: the running build is current, or the manifest could not
  /// be read. Both mean "show nothing".
  none,

  /// A newer version exists. The dialog is dismissible and is shown once per
  /// published version.
  optional,

  /// The running build is below `minSupported`. The dialog cannot be
  /// dismissed.
  forced,
}

/// The result of one update check.
class UpdateCheck {
  const UpdateCheck({
    required this.urgency,
    required this.currentVersion,
    this.info = const AppUpdateInfo(),
  });

  /// The "nothing to do" result. Returned for every failure path as well, so
  /// an unreachable manifest looks exactly like an up-to-date app.
  static const UpdateCheck none = UpdateCheck(
    urgency: UpdateUrgency.none,
    currentVersion: '',
  );

  final UpdateUrgency urgency;

  /// The version of the build that ran the check, from package_info_plus.
  final String currentVersion;

  final AppUpdateInfo info;

  bool get shouldShow => urgency != UpdateUrgency.none;
}
