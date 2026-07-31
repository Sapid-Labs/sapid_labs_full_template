import 'package:injectable/injectable.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:slapp/features/shared/services/crash/crash_service.dart';

// STACK_SENTRY
// Sentry is the default crash backend for every Sapid Labs app. Crashlytics has no
// read API, so no tool can ask it what is crashing. See docs/tech-stack.md in fun-money.
@Injectable(as: CrashService)
class SentryCrashService implements CrashService {
  @override
  void logError({required dynamic error, required StackTrace stackTrace}) {
    Sentry.captureException(error, stackTrace: stackTrace);
  }
}
