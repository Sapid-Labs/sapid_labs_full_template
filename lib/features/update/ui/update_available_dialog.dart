import 'package:flutter/material.dart';
import 'package:slapp/app/config.dart';
import 'package:slapp/app/services.dart';
import 'package:slapp/features/update/models/app_update_info.dart';
import 'package:url_launcher/url_launcher.dart';

/// The "New version available" popup.
///
/// Takes its [check] rather than reading the service, so a widget test can
/// pump it with no get_it registrations and no network. [onUpdate] is the same
/// idea for the button: the default opens the store, and a test passes its own
/// callback instead of tripping over a missing url_launcher plugin.
class UpdateAvailableDialog extends StatelessWidget {
  const UpdateAvailableDialog({
    required this.check,
    this.onUpdate,
    this.storeUrl = '',
    super.key,
  });

  final UpdateCheck check;

  final Future<void> Function()? onUpdate;

  /// Where the button goes. When empty the button is hidden, because a dead
  /// button on a dialog that cannot be dismissed traps the user.
  final String storeUrl;

  bool get _forced => check.urgency == UpdateUrgency.forced;

  Future<void> _update(BuildContext context) async {
    final NavigatorState navigator = Navigator.of(context);

    if (onUpdate != null) {
      await onUpdate!();
    } else if (storeUrl.isNotEmpty) {
      await launchUrl(
        Uri.parse(storeUrl),
        mode: LaunchMode.externalApplication,
      );
    }

    // A forced dialog stays up. The user comes back from the store into the
    // same old build until they actually install the new one, and popping here
    // would leave them inside an app we have already said does not work.
    if (!_forced && navigator.canPop()) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canUpdate = onUpdate != null || storeUrl.isNotEmpty;

    return PopScope(
      canPop: !_forced,
      child: AlertDialog(
        icon: const Icon(Icons.system_update),
        title: Text(_forced ? 'Update required' : 'New version available'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(_message()),
            if (check.info.releaseNotes.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                check.info.releaseNotes,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
        actions: <Widget>[
          if (!_forced)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Later'),
            ),
          if (canUpdate)
            TextButton(
              onPressed: () => _update(context),
              child: const Text('Update now'),
            ),
        ],
      ),
    );
  }

  String _message() {
    final String version = check.info.latestVersion;

    if (_forced) {
      return 'This version of ${AppConfig.appName} is too old to keep '
          'working. Update to $version to carry on.';
    }

    return version.isEmpty
        ? '${AppConfig.appName} has a newer version in the store.'
        : '${AppConfig.appName} $version is in the store. You are on '
            '${check.currentVersion}.';
  }
}

/// Runs the check and shows the popup when there is something to say.
///
/// Call it from the first screen's `initState` inside a post-frame callback --
/// there is no context to show a dialog with before the first frame. It is
/// safe to call on every launch: the optional prompt is remembered per
/// published version, and every failure path shows nothing.
Future<void> maybeShowUpdateDialog(BuildContext context) async {
  final UpdateCheck check = await updateService.check();

  if (!check.shouldShow || !updateService.shouldPrompt(check)) {
    return;
  }

  final String storeUrl = await updateService.resolveStoreUrl(check);

  if (!context.mounted) {
    return;
  }

  await updateService.markPrompted(check);

  await showDialog<void>(
    context: context,
    barrierDismissible: check.urgency != UpdateUrgency.forced,
    builder: (BuildContext context) => UpdateAvailableDialog(
      check: check,
      storeUrl: storeUrl,
    ),
  );
}
