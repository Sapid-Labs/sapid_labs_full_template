import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every failure in this family is silent, which is why it needs a test rather
/// than a code review.
///
/// A key that comes out of `assets/config.json` through
/// `--dart-define-from-file` is an empty string when the file, or that one key,
/// is missing. Nothing errors. The analyzer is happy, the build is happy, and
/// the app starts. Two shapes then lose money or data with no log line:
///
///  * a backend init wrapped in `if (String.fromEnvironment(...) == '...')`,
///    which skips `Firebase.initializeApp` entirely and throws on the first
///    query (fun-money #339, found in vault_messages);
///  * `Purchases.configure` handed an empty key inside a `try` whose `catch`
///    only calls `debugPrint`, which leaves every user on the free tier
///    (fun-money #346, found here and in abis_recipes).
///
/// Read `lib/` off disk rather than calling anything: the defect is in the
/// source's shape, and both shapes run fine in a test harness.
void main() {
  final lib = Directory('lib');

  List<File> dartFiles() => lib
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  /// Strip `//` and `///` comments. Both tests below look for the names of
  /// calls, and those names also appear in the comments that explain why the
  /// calls are written the way they are.
  List<String> codeLines(File file) => file
      .readAsLinesSync()
      .map((l) => l.replaceFirst(RegExp(r'//.*'), ''))
      .toList();

  const inits = [
    'Firebase.initializeApp(',
    'Supabase.initialize(',
    'Purchases.configure(',
  ];

  test('no backend init is guarded by a String.fromEnvironment branch', () {
    final offenders = <String>[];

    for (final file in dartFiles()) {
      final lines = codeLines(file);
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (!line.contains('fromEnvironment')) continue;
        if (!RegExp(r'\bif\s*\(').hasMatch(line)) continue;

        // Look at the next few lines only. A guard that reaches further than
        // that is a different smell and this test is not the place for it.
        final window = lines.skip(i).take(8).join('\n');
        for (final init in inits) {
          if (window.contains(init)) {
            offenders.add('${file.path}:${i + 1} guards $init');
          }
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'A missing config key must not silently skip a backend. '
          'Initialise unconditionally, or report the missing key.\n'
          '${offenders.join('\n')}',
    );
  });

  test('Purchases.configure is never reached with an empty key', () {
    for (final file in dartFiles()) {
      final source = codeLines(file).join('\n');
      if (!source.contains('Purchases.configure(')) continue;

      expect(
        source.contains('isEmpty'),
        isTrue,
        reason: '${file.path} calls Purchases.configure but never checks the '
            'API key for emptiness. A release build missing '
            'assets/config.json then configures RevenueCat with "", the '
            'catch swallows it, and nobody can subscribe.',
      );
      expect(
        source.contains('reportMissingPurchasesKey') ||
            source.contains('Sentry.captureMessage'),
        isTrue,
        reason: '${file.path} checks for an empty RevenueCat key but does not '
            'report it. An empty key in a release build is an outage, not a '
            'configuration choice, so it has to reach Sentry.',
      );
    }
  });
}
