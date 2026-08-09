import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:signals/signals_flutter.dart';
import 'package:slapp/app/config.dart';
import 'package:slapp/app/services.dart';
import 'package:slapp/features/update/models/app_update_info.dart';
import 'package:slapp/features/update/services/store_url.dart';
import 'package:slapp/features/update/services/version_compare.dart';
import 'package:universal_io/io.dart';

/// The last check's result, so any screen can read it without fetching again.
final Signal<UpdateCheck> updateCheck = signal<UpdateCheck>(UpdateCheck.none);

/// Reads the remote update manifest and decides whether to nag.
///
/// Deliberately not a store lookup. Play publishes no "latest version" API and
/// scraping a listing is off-limits, so the newest version is a number we
/// publish beside the release, in a static JSON on sapidlabs.com. See
/// [AppConfig.updateManifestUrl].
///
/// Every failure -- no URL, no network, a 404, malformed JSON, a manifest with
/// no entry for this platform -- resolves to [UpdateCheck.none]. A version
/// check is a convenience, and a convenience that can hold the app closed is
/// worse than one that is absent.
@lazySingleton
class UpdateService {
  /// Swapped in tests. There is no constructor parameter because injectable
  /// would then look for an `http.Client` registration that does not exist.
  @visibleForTesting
  http.Client client = http.Client();

  static const String _promptedKey = 'update_prompted_version';

  static const Duration _timeout = Duration(seconds: 5);

  /// Fetches the manifest and compares it with the running build.
  ///
  /// Also publishes the result on [updateCheck].
  Future<UpdateCheck> check() async {
    final UpdateCheck result = await _check();
    updateCheck.value = result;

    return result;
  }

  Future<UpdateCheck> _check() async {
    // The web build is served, not installed: there is no store listing to
    // send anyone to, and a hard refresh already has the newest code.
    if (kIsWeb) {
      return UpdateCheck.none;
    }

    // An empty URL means this app has opted out, which is a source constant a
    // developer sets rather than a config key that can go missing. It is
    // logged all the same, because a feature that is quietly off looks exactly
    // like a feature that is broken.
    if (AppConfig.updateManifestUrl.isEmpty) {
      debugPrint('UpdateService: no updateManifestUrl set, skipping check');

      return UpdateCheck.none;
    }

    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final http.Response response = await client
          .get(Uri.parse(AppConfig.updateManifestUrl))
          .timeout(_timeout);

      if (response.statusCode != 200) {
        crashService.logError(
          error: 'UpdateService: manifest returned ${response.statusCode} '
              'for ${AppConfig.updateManifestUrl}',
          stackTrace: StackTrace.current,
        );

        return UpdateCheck.none;
      }

      final AppUpdateInfo? info = parseUpdateManifest(
        response.body,
        isAndroid: Platform.isAndroid,
      );

      if (info == null) {
        return UpdateCheck.none;
      }

      return decideUpdate(
        currentVersion: packageInfo.version,
        info: info,
      );
    } catch (error, stack) {
      // A launch-time convenience must not take the launch with it.
      crashService.logError(error: error, stackTrace: stack);

      return UpdateCheck.none;
    }
  }

  /// True when the optional prompt for [version] has not been shown yet.
  ///
  /// A forced update ignores this: it is shown every launch until the user
  /// updates.
  bool shouldPrompt(UpdateCheck result) {
    if (result.urgency == UpdateUrgency.forced) {
      return true;
    }

    if (result.urgency == UpdateUrgency.none) {
      return false;
    }

    return sharedPrefs.getString(_promptedKey) != result.info.latestVersion;
  }

  /// Remembers that the optional prompt for this version has been shown, so
  /// the user is asked once per published version rather than once per launch.
  Future<void> markPrompted(UpdateCheck result) async {
    if (result.info.latestVersion.isEmpty) {
      return;
    }

    await sharedPrefs.setString(_promptedKey, result.info.latestVersion);
  }

  /// The URL the "Update now" button opens, or empty when none resolves.
  Future<String> resolveStoreUrl(UpdateCheck result) async {
    if (kIsWeb) {
      return '';
    }

    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    return storeUrlFor(
      manifestUrl: result.info.storeUrl,
      isAndroid: Platform.isAndroid,
      packageName: packageInfo.packageName,
      appStoreId: const String.fromEnvironment('APP_STORE_ID'),
    );
  }
}

/// Reads one platform's entry out of the manifest body.
///
/// Returns null for anything that is not a JSON object with an entry for this
/// platform, which the caller treats as "nothing to say".
AppUpdateInfo? parseUpdateManifest(
  String body, {
  required bool isAndroid,
}) {
  try {
    final Object? decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    final Object? entry = decoded[isAndroid ? 'android' : 'ios'];
    if (entry is! Map<String, dynamic>) {
      return null;
    }

    return AppUpdateInfo.fromJson(entry);
  } catch (_) {
    return null;
  }
}

/// Turns a manifest entry and the running version into a decision.
///
/// `minSupported` is checked first, so an entry that sets it above `latest` by
/// mistake still forces rather than nags.
UpdateCheck decideUpdate({
  required String currentVersion,
  required AppUpdateInfo info,
}) {
  if (currentVersion.isEmpty) {
    return UpdateCheck.none;
  }

  if (isNewerVersion(info.minSupportedVersion, currentVersion)) {
    return UpdateCheck(
      urgency: UpdateUrgency.forced,
      currentVersion: currentVersion,
      info: info,
    );
  }

  if (isNewerVersion(info.latestVersion, currentVersion)) {
    return UpdateCheck(
      urgency: UpdateUrgency.optional,
      currentVersion: currentVersion,
      info: info,
    );
  }

  return UpdateCheck.none;
}
