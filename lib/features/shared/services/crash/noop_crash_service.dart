import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:slapp/features/shared/services/crash/crash_service.dart';

// STACK_NO_CRASH
// The crash backend for an app that has not picked one yet. Call sites still go
// through `crashService`, so adding Sentry or Crashlytics later is a swap of this
// annotation and not a refactor of every catch block.
//
// It prints in debug and does nothing in release. Silently swallowing an error
// during development is how a template teaches somebody that errors do not happen.
// @Injectable(as: CrashService)
@Injectable()
class NoopCrashService implements CrashService {
  @override
  void logError({required dynamic error, required StackTrace stackTrace}) {
    if (kDebugMode) {
      debugPrint('crash (not reported, no backend selected): $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
