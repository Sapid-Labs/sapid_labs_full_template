import 'package:injectable/injectable.dart';
import 'package:slapp/features/shared/services/crash/crash_service.dart';

// STACK_SENTRY
// @Injectable(as: CrashService)
@Injectable()
class SentryCrashService implements CrashService {
  @override
  void logError({required dynamic error, required StackTrace stackTrace}) {
    // Implement Sentry error logging here
    // Sentry.captureException(error, stackTrace: stackTrace);
  }
}
