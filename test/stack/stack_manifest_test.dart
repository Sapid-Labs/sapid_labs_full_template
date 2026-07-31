import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards `tool/stack.py` against the template moving underneath it.
///
/// The script deletes files. Every path it names is a string in a python file
/// that no Dart compiler ever looks at, so renaming a service is a change that
/// compiles, ships, and then quietly stops removing the provider it was supposed
/// to remove — leaving an unused SDK in the merged Android manifest, which is
/// exactly the AD_ID problem this whole cleanup started from.
///
/// So: every path in the script's manifest must exist, every provider must own
/// exactly one commented-out `as: Interface` annotation, and no interface may
/// have two live registrations.
void main() {
  final script = File('tool/stack.py');

  /// `'lib/features/...dart'` and `'stack/....md'` literals in the manifest.
  final pathLiteral = RegExp(r"'((?:lib/|stack/)[\w./]+\.(?:dart|md))'");

  /// The manifest builds dart paths as `AUTH + 'file.dart'`, so the prefix
  /// constants have to be resolved before the paths can be checked.
  Map<String, String> prefixes(String source) {
    final out = <String, String>{};
    for (final match
        in RegExp(r"^(\w+) = '([\w/]+/)'", multiLine: true).allMatches(source)) {
      out[match.group(1)!] = match.group(2)!;
    }
    return out;
  }

  test('tool/stack.py exists and is executable', () {
    expect(script.existsSync(), isTrue);
    // Joe runs this from a fresh clone. A file without the bit set fails with
    // "permission denied", which reads as a broken script rather than a chmod.
    final mode = script.statSync().mode;
    expect(mode & 0x40, isNot(0), reason: 'chmod +x tool/stack.py');
  });

  test('every file the script would delete is really there', () {
    final source = script.readAsStringSync();
    final resolved = prefixes(source);

    final missing = <String>[];
    for (final match in RegExp(
            r"(?:(\w+) \+ )?'((?:lib/|stack/)?[\w./]+\.(?:dart|md))'")
        .allMatches(source)) {
      final prefix = match.group(1);
      final tail = match.group(2)!;
      final path =
          prefix == null ? tail : '${resolved[prefix] ?? '$prefix/'}$tail';
      if (!path.startsWith('lib/') && !path.startsWith('stack/')) continue;
      if (!File(path).existsSync()) missing.add(path);
    }

    expect(missing, isEmpty,
        reason: 'tool/stack.py names files that no longer exist. Fix the '
            'manifest in CATEGORIES, or the script silently keeps a provider '
            'the child app asked it to remove.');
  });

  test('every swappable service carries a togglable annotation', () {
    // One live `@X(as: Interface)` or one commented-out one. Neither is the bug
    // the script cannot fix: it only ever uncomments a line that is there.
    final swappable = Directory('lib/features')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('_service.dart'))
        // The interfaces name the scheme in their doc comments, which is not a
        // registration. Only an implementation can carry one.
        .where((f) => !f.readAsStringSync().contains('abstract class'))
        .where((f) => f.readAsStringSync().contains('// STACK_'))
        .toList();

    expect(swappable, isNotEmpty);

    final offenders = <String>[];
    for (final file in swappable) {
      final source = file.readAsStringSync();
      final has = RegExp(r'//\s*@(Injectable|Singleton|LazySingleton)\(\s*as:')
              .hasMatch(source) ||
          RegExp(r'^@(Injectable|Singleton|LazySingleton)\(\s*as:',
                  multiLine: true)
              .hasMatch(source);
      if (!has) offenders.add(file.path);
    }

    expect(offenders, isEmpty,
        reason: 'A file marked // STACK_ with no `as: Interface` annotation, '
            'live or commented, cannot be activated by tool/stack.py.');
  });

  test('main.dart STACK blocks are balanced', () {
    // An unclosed BEGIN makes the script comment out the rest of the file.
    final lines = File('lib/main.dart').readAsLinesSync();
    var open = 0;
    for (final line in lines) {
      if (RegExp(r'//\s*STACK_\w+:BEGIN\s*$').hasMatch(line)) open++;
      if (RegExp(r'//\s*STACK_\w+:END\s*$').hasMatch(line)) open--;
      expect(open, anyOf(0, 1), reason: 'nested or unclosed STACK block');
    }
    expect(open, 0, reason: 'a STACK block in lib/main.dart is never closed');
  });
}
