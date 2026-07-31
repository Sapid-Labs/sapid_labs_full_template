import 'package:slapp/app/config.dart';

/// Where Supabase sends somebody who taps "reset password" in their mail.
///
/// This one string has to match four things at once, and none of them fails
/// loudly when it does not:
///
///  * the Redirect URLs allow-list on the app's Supabase project. Supabase does
///    not reject a redirect it has not been told about — it quietly replaces it
///    with the project's Site URL, so the user lands in another app or nowhere.
///  * the `android:scheme` and `android:host` filter in
///    `android/app/src/main/AndroidManifest.xml`.
///  * `CFBundleURLSchemes` in `ios/Runner/Info.plist`, lowercase. Apple's
///    guidance is a lowercase scheme, and a capitalised entry alone may never
///    resolve on device.
///  * a path the router answers. It is `/update-password`.
///
/// Both halves come from [AppConfig.urlScheme] and [AppConfig.urlHost] rather
/// than from `appName.toLowerCase()`, which was the earlier pattern: the app
/// name here is 'Sapid Labs', and 'sapid labs' is not a scheme any platform can
/// register.
///
/// `test/auth/password_reset_link_test.dart` reads the platform files off disk
/// and pins them to this constant, so drift breaks the suite rather than the
/// mail.
final String passwordResetRedirectUrl =
    '${AppConfig.urlScheme}://${AppConfig.urlHost}/update-password';
