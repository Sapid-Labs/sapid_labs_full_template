import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// iOS Google sign-in runs on Info.plist, not on the Dart config, and it
/// fails silently when the two disagree.
///
/// google_sign_in_ios only builds a GIDConfiguration when it is handed a
/// client id. Off web it is handed none: supabase_auth_service.dart passes
/// `clientId: null` and no GoogleService-Info.plist is bundled. GIDSignIn
/// therefore falls back to its default configuration, which it reads from
/// the keys asserted below.
///
/// The template shipped GIDClientID
/// 359662441201-5ai1r3qbcim5055j2l6jcnupjnetkeo1 - Abi's Recipes' project -
/// until 2026-08-12, and every app scaffolded from it inherited that value
/// beside its own reversed id in CFBundleURLSchemes. Nothing errored at
/// build, analyze or test time; the sign-in simply could not complete.
///
/// The template now ships both keys removed, so these tests hold when they
/// are absent. Once an app adds them, the expectations are derived from the
/// URL scheme rather than restated, so the pair cannot drift apart again.
void main() {
  final plist = File('ios/Runner/Info.plist').readAsStringSync();

  /// The copied value. No app in this family should ever carry it: Abi's
  /// Recipes itself uses a different iOS client.
  const templateLeak = '359662441201-5ai1r3qbcim5055j2l6jcnupjnetkeo1';
  const suffix = '.apps.googleusercontent.com';

  String? valueFor(String key) {
    final match = RegExp(
      '<key>$key</key>\\s*<string>([^<]*)</string>',
    ).firstMatch(plist);
    return match?.group(1);
  }

  group('iOS Google sign-in client ids', () {
    test('no client id copied from the template', () {
      // Both the forward and the reversed form, because the bug shipped as a
      // GIDClientID beside a correct URL scheme.
      expect(
        plist,
        isNot(contains(templateLeak)),
        reason: 'Info.plist carries the template\'s Abi\'s Recipes client id',
      );
    });

    test('GIDClientID is registered as a URL scheme', () {
      // GIDSignIn sends the OAuth redirect to the reversed form of whatever
      // client id it ends up using. If the app does not register that
      // scheme, the callback never comes back and the flow hangs.
      final clientId = valueFor('GIDClientID');
      if (clientId == null) {
        // The template ships without one; an app adds it when it wires
        // Google sign-in. Absent is safe, wrong is not.
        return;
      }
      expect(clientId, endsWith(suffix));

      final reversed = 'com.googleusercontent.apps.'
          '${clientId.substring(0, clientId.length - suffix.length)}';
      expect(
        plist,
        contains('<string>$reversed</string>'),
        reason: 'CFBundleURLSchemes does not register $reversed',
      );
    });

    test('GIDServerClientID is not set on its own', () {
      // A server client id with no GIDClientID beside it means GIDSignIn
      // still has no configuration, so neither value is read.
      if (valueFor('GIDServerClientID') != null) {
        expect(
          valueFor('GIDClientID'),
          isNotNull,
          reason: 'GIDServerClientID is set but GIDClientID is missing',
        );
      }
    });

    test('GIDServerClientID matches SERVER_CLIENT_ID', () {
      // The Dart serverClientId is discarded along with the nil
      // configuration, so this key is the only thing that sets the audience
      // Supabase checks in signInWithIdToken. assets/config.json is
      // gitignored, so only assert when the checkout actually has it.
      final serverClientId = valueFor('GIDServerClientID');
      final config = File('assets/config.json');
      if (serverClientId == null || !config.existsSync()) {
        return;
      }
      final match = RegExp(
        '"SERVER_CLIENT_ID"\\s*:\\s*"([^"]*)"',
      ).firstMatch(config.readAsStringSync());
      final configured = match?.group(1);
      if (configured == null || configured.isEmpty) {
        return;
      }
      expect(serverClientId, configured);
    });
  });
}
