import 'package:flutter_test/flutter_test.dart';
import 'package:slapp/features/update/models/app_update_info.dart';
import 'package:slapp/features/update/services/store_url.dart';
import 'package:slapp/features/update/services/update_service.dart';
import 'package:slapp/features/update/services/version_compare.dart';

/// The update check is three pure decisions behind one network call, and the
/// decisions are what can be wrong. Each one is tested here without a device,
/// a plugin or a get_it registration.
void main() {
  group('compareVersions', () {
    test('compares segment by segment, not as text', () {
      // The bug this exists to stop: '1.10.0'.compareTo('1.9.0') is negative,
      // so a lexicographic compare tells a user on the newest build to update.
      expect(compareVersions('1.10.0', '1.9.0'), greaterThan(0));
      expect(compareVersions('1.9.0', '1.10.0'), lessThan(0));
      expect(compareVersions('2.0.0', '1.99.99'), greaterThan(0));
    });

    test('ignores the build number and any pre-release tag', () {
      expect(compareVersions('1.4.0+27', '1.4.0'), 0);
      expect(compareVersions('1.4.0-beta.2', '1.4.0'), 0);
      expect(compareVersions('1.4.0+30', '1.4.0+27'), 0);
    });

    test('treats a missing segment as zero', () {
      expect(compareVersions('1.4', '1.4.0'), 0);
      expect(compareVersions('1.4.1', '1.4'), greaterThan(0));
    });

    test('treats an unparseable segment as zero rather than throwing', () {
      // The manifest is remote text. A typo in it must not crash a launch.
      expect(compareVersions('1.x.0', '1.0.0'), 0);
      expect(versionSegments('nonsense'), <int>[0]);
    });
  });

  group('isNewerVersion', () {
    test('is false when either side is empty', () {
      expect(isNewerVersion('', '1.0.0'), isFalse);
      expect(isNewerVersion('2.0.0', ''), isFalse);
    });

    test('is false for the same release', () {
      expect(isNewerVersion('1.4.0', '1.4.0+9'), isFalse);
    });
  });

  group('parseUpdateManifest', () {
    const String body = '''
{
  "android": {
    "latest": "1.4.0",
    "minSupported": "1.2.0",
    "notes": "Faster sync.",
    "storeUrl": "https://play.google.com/store/apps/details?id=com.x.y"
  },
  "ios": { "latest": "1.3.0" }
}
''';

    test('reads the entry for the running platform', () {
      final AppUpdateInfo? android =
          parseUpdateManifest(body, isAndroid: true);
      expect(android?.latestVersion, '1.4.0');
      expect(android?.minSupportedVersion, '1.2.0');
      expect(android?.releaseNotes, 'Faster sync.');
      expect(android?.storeUrl, contains('id=com.x.y'));

      final AppUpdateInfo? ios = parseUpdateManifest(body, isAndroid: false);
      expect(ios?.latestVersion, '1.3.0');
      expect(ios?.minSupportedVersion, isEmpty);
    });

    test('returns null for anything it cannot read', () {
      expect(parseUpdateManifest('<html>404</html>', isAndroid: true), isNull);
      expect(parseUpdateManifest('[]', isAndroid: true), isNull);
      expect(parseUpdateManifest('{}', isAndroid: true), isNull);
      expect(
        parseUpdateManifest('{"android": "1.4.0"}', isAndroid: true),
        isNull,
        reason: 'A string where the object should be is a malformed '
            'manifest, not an entry.',
      );
    });

    test('ignores a field of the wrong type instead of throwing', () {
      final AppUpdateInfo? info = parseUpdateManifest(
        '{"android": {"latest": 14, "notes": null}}',
        isAndroid: true,
      );

      expect(info, isNotNull);
      expect(info?.latestVersion, isEmpty);
      expect(info?.releaseNotes, isEmpty);
    });
  });

  group('decideUpdate', () {
    test('says nothing when the running build is current', () {
      final UpdateCheck check = decideUpdate(
        currentVersion: '1.4.0',
        info: const AppUpdateInfo(latestVersion: '1.4.0'),
      );

      expect(check.urgency, UpdateUrgency.none);
      expect(check.shouldShow, isFalse);
    });

    test('nags when a newer version is published', () {
      final UpdateCheck check = decideUpdate(
        currentVersion: '1.3.0',
        info: const AppUpdateInfo(latestVersion: '1.4.0'),
      );

      expect(check.urgency, UpdateUrgency.optional);
      expect(check.currentVersion, '1.3.0');
    });

    test('forces below minSupported', () {
      final UpdateCheck check = decideUpdate(
        currentVersion: '1.1.0',
        info: const AppUpdateInfo(
          latestVersion: '1.4.0',
          minSupportedVersion: '1.2.0',
        ),
      );

      expect(check.urgency, UpdateUrgency.forced);
    });

    test('forces even when minSupported is above latest by mistake', () {
      final UpdateCheck check = decideUpdate(
        currentVersion: '1.1.0',
        info: const AppUpdateInfo(
          latestVersion: '1.0.0',
          minSupportedVersion: '9.0.0',
        ),
      );

      expect(check.urgency, UpdateUrgency.forced);
    });

    test('says nothing when the manifest is empty', () {
      expect(
        decideUpdate(
          currentVersion: '1.4.0',
          info: const AppUpdateInfo(),
        ).urgency,
        UpdateUrgency.none,
        reason: 'An empty manifest field must never raise a prompt, and '
            'least of all a forced one.',
      );
    });

    test('says nothing when the running version is unknown', () {
      expect(
        decideUpdate(
          currentVersion: '',
          info: const AppUpdateInfo(
            latestVersion: '1.4.0',
            minSupportedVersion: '1.4.0',
          ),
        ).urgency,
        UpdateUrgency.none,
      );
    });
  });

  group('storeUrlFor', () {
    test('prefers the manifest URL', () {
      expect(
        storeUrlFor(
          manifestUrl: 'https://example.com/app',
          isAndroid: true,
          packageName: 'com.x.y',
        ),
        'https://example.com/app',
      );
    });

    test('derives the Play listing from the running package name', () {
      expect(
        storeUrlFor(manifestUrl: '', isAndroid: true, packageName: 'com.x.y'),
        'https://play.google.com/store/apps/details?id=com.x.y',
      );
    });

    test('uses APP_STORE_ID on iOS', () {
      expect(
        storeUrlFor(manifestUrl: '', isAndroid: false, appStoreId: '12345'),
        'https://apps.apple.com/app/id12345',
      );
    });

    test('is empty when nothing resolves', () {
      expect(storeUrlFor(manifestUrl: '', isAndroid: true), isEmpty);
      expect(storeUrlFor(manifestUrl: '', isAndroid: false), isEmpty);
    });
  });
}
