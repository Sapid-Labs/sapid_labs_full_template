import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the two ways the stack scheme goes wrong without anything erroring.
///
/// Selection is by annotation: every swappable service carries a `// STACK_<NAME>`
/// marker, the chosen implementation has `@Injectable(as: Interface)` (or the
/// `@Singleton` / `@LazySingleton` form), and its rivals have that line commented out
/// with a plain annotation in its place. Two active registrations for one interface
/// compile without complaint and throw at startup, which is a runtime failure a code
/// review is bad at catching.
///
/// The scheme replaced an older one that read `STACK_PAAS`, `STACK_ANALYTICS` and
/// `STACK_CRASHLYTICS` out of `assets/config.json`. Nothing reads those keys any more,
/// so a doc that still tells someone to set one sends them to a switch that is not
/// wired to anything. That is the harder failure of the two: it looks like it worked.
void main() {
  /// Annotation forms injectable accepts with an interface.
  final registration =
      RegExp(r'@(Injectable|Singleton|LazySingleton)\(\s*as:\s*(\w+)');

  /// The keys the old config-driven scheme used. None of them select anything now.
  const retiredKeys = ['STACK_PAAS', 'STACK_ANALYTICS', 'STACK_CRASHLYTICS'];

  List<File> dartFiles() => Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  test('exactly one implementation is registered against each interface', () {
    final claims = <String, List<String>>{};

    for (final file in dartFiles()) {
      // Generated output re-states every registration, so reading it would double
      // every count. The source annotations are the thing under test.
      if (file.path.endsWith('.config.dart') || file.path.endsWith('.g.dart')) {
        continue;
      }

      for (final line in file.readAsLinesSync()) {
        // A commented-out rival is the correct state, not a violation.
        if (line.trimLeft().startsWith('//')) continue;

        final match = registration.firstMatch(line);
        if (match == null) continue;

        claims.putIfAbsent(match.group(2)!, () => []).add(file.path);
      }
    }

    final conflicts = <String>[];
    claims.forEach((interface, files) {
      if (files.length > 1) {
        conflicts.add('$interface is claimed by ${files.join(' and ')}');
      }
    });

    expect(
      conflicts,
      isEmpty,
      reason: 'Two implementations registered against the same interface. get_it '
          'throws at startup. Comment out the losing annotation and leave a plain '
          '@Injectable() / @Singleton() / @LazySingleton() in its place, then run '
          './tool/codegen.sh.',
    );
  });

  test('no code reads a retired STACK_* config key', () {
    final offenders = <String>[];

    for (final file in dartFiles()) {
      final source = file.readAsStringSync();
      for (final key in retiredKeys) {
        if (source.contains(key)) offenders.add('${file.path} reads $key');
      }
    }

    expect(offenders, isEmpty,
        reason: 'These keys select nothing. Use the annotation scheme.');
  });

  test('no doc tells anyone to set a retired STACK_* config key', () {
    final docs = <File>[
      ...Directory('.')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.md')),
      ...Directory('stack')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.md')),
      File('assets/config.example.json'),
    ].where((f) => f.existsSync()).toList();

    final offenders = <String>[];
    for (final file in docs) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        for (final key in retiredKeys) {
          // The keys are named in prose in a few places precisely to say they are
          // dead. A JSON key or a bare mention with no such disclaimer is the bug.
          if (!lines[i].contains(key)) continue;
          final saysItIsDead = lines[i].contains('no ') ||
              lines[i].contains('not ') ||
              lines[i].contains('retired') ||
              lines[i].contains('older scheme') ||
              lines[i].contains('select nothing');
          if (!saysItIsDead) {
            offenders.add('${file.path}:${i + 1} mentions $key');
          }
        }
      }
    }

    expect(offenders, isEmpty,
        reason: 'Rewrite the step to swap the annotation instead. See stack/SENTRY.md '
            'for the shape a current guide has.');
  });
}
