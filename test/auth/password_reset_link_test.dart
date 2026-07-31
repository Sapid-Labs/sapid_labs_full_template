import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:slapp/features/auth/utils/password_reset_link.dart';

/// The password-reset mail is the one link in this app we cannot correct after
/// sending. Supabase does not reject a redirect it has not been told about — it
/// quietly substitutes the project's Site URL — and neither platform manifest
/// errors when it does not claim the scheme. So every failure here is silent,
/// and reads to the user as "the reset link does nothing".
///
/// These read the platform files off disk rather than mocking them: the file
/// that ships is the one that matters. The fourth party, the Redirect URLs
/// allow-list on the Supabase project, is out of reach from here and has to be
/// set by hand for each app built from this template.
void main() {
  final redirect = Uri.parse(passwordResetRedirectUrl);
  final manifest =
      File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
  final plist = File('ios/Runner/Info.plist').readAsStringSync();
  final router = File('lib/app/router.dart').readAsStringSync();

  test('the redirect is a custom scheme, not https', () {
    // An https redirect would need App Links verification to reach the app and
    // would open a browser until it had it. No app in this portfolio has a
    // verified claim, so https here is a link that opens the wrong thing.
    expect(redirect.scheme, isNotEmpty);
    expect(redirect.scheme, isNot('https'));
    expect(redirect.host, isNotEmpty);
  });

  test('the scheme is one a platform can register', () {
    // Lowercase, and no space. This is why the scheme is its own constant
    // rather than `appName.toLowerCase()`.
    expect(redirect.scheme, matches(RegExp(r'^[a-z][a-z0-9+.-]*$')));
  });

  test('Android claims the scheme and host', () {
    expect(manifest, contains('android:scheme="${redirect.scheme}"'));
    expect(manifest, contains('android:host="${redirect.host}"'));
  });

  test('iOS registers the scheme in the case the app actually sends', () {
    expect(plist, contains('<string>${redirect.scheme}</string>'));
  });

  test('the router answers the path the mail link carries', () {
    expect(router, contains("path: '${redirect.path}'"));
  });
}
