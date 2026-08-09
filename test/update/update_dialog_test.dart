import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slapp/features/update/models/app_update_info.dart';
import 'package:slapp/features/update/ui/update_available_dialog.dart';

/// The popup is pumped rather than described, because the difference between
/// the two urgencies is entirely in what the user can do: an optional prompt
/// must be escapable and a forced one must not be.
void main() {
  Future<void> pump(WidgetTester tester, Widget dialog) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Builder(builder: (BuildContext context) => dialog)),
      ),
    );
    await tester.pumpAndSettle();
  }

  const UpdateCheck optional = UpdateCheck(
    urgency: UpdateUrgency.optional,
    currentVersion: '1.3.0',
    info: AppUpdateInfo(latestVersion: '1.4.0', releaseNotes: 'Faster sync.'),
  );

  const UpdateCheck forced = UpdateCheck(
    urgency: UpdateUrgency.forced,
    currentVersion: '1.1.0',
    info: AppUpdateInfo(latestVersion: '1.4.0', minSupportedVersion: '1.2.0'),
  );

  testWidgets('an optional prompt shows both versions and a way out',
      (WidgetTester tester) async {
    await pump(
      tester,
      const UpdateAvailableDialog(
        check: optional,
        storeUrl: 'https://example.com/app',
      ),
    );

    expect(find.text('New version available'), findsOneWidget);
    expect(find.textContaining('1.4.0'), findsOneWidget);
    expect(find.textContaining('1.3.0'), findsOneWidget);
    expect(find.text('Faster sync.'), findsOneWidget);
    expect(find.text('Later'), findsOneWidget);
    expect(find.text('Update now'), findsOneWidget);
  });

  testWidgets('a forced prompt offers no way out',
      (WidgetTester tester) async {
    await pump(
      tester,
      const UpdateAvailableDialog(
        check: forced,
        storeUrl: 'https://example.com/app',
      ),
    );

    expect(find.text('Update required'), findsOneWidget);
    expect(
      find.text('Later'),
      findsNothing,
      reason: 'Below minSupported the build does not work, so a dismiss '
          'button would only send the user back into a broken app.',
    );
    expect(find.text('Update now'), findsOneWidget);

    // byType cannot be used here: PopScope is generic, so the runtime type of
    // the built widget is not the raw name written in the source.
    expect(
      find.byWidgetPredicate(
        (Widget widget) => widget is PopScope && !widget.canPop,
      ),
      findsOneWidget,
      reason: 'The system back gesture must not dismiss a forced update.',
    );
  });

  testWidgets('the button is hidden when no store URL resolves',
      (WidgetTester tester) async {
    await pump(tester, const UpdateAvailableDialog(check: forced));

    expect(
      find.text('Update now'),
      findsNothing,
      reason: 'A dead button on a dialog that cannot be dismissed traps the '
          'user in a dialog they can do nothing about.',
    );
  });

  testWidgets('Update now runs the callback and closes the optional prompt',
      (WidgetTester tester) async {
    int calls = 0;

    // Shown through showDialog so there is a route to pop, which is what the
    // optional prompt is expected to do after handing off to the store.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => UpdateAvailableDialog(
                  check: optional,
                  onUpdate: () async => calls++,
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('New version available'), findsOneWidget);

    await tester.tap(find.text('Update now'));
    await tester.pumpAndSettle();

    expect(calls, 1);
    expect(find.text('New version available'), findsNothing);
  });
}
