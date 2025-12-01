import 'package:slapp/features/shared/services/crash/firebase_crash_service.dart';
import 'package:slapp/features/shared/services/crash/sentry_crash_service.dart';

abstract class CrashService {
  void logError({required dynamic error, required StackTrace stackTrace}) async {
    FirebaseCrashService().logError(error: error, stackTrace: stackTrace);
    SentryCrashService().logError(error: error, stackTrace: stackTrace);
  }
}
