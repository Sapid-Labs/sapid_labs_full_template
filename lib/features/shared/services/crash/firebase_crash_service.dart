import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:injectable/injectable.dart';
import 'package:slapp/app/get_it.dart';
import 'package:slapp/features/shared/services/crash/crash_service.dart';

@firebaseCrashlyticsEnv
@Injectable(as: CrashService)
class FirebaseCrashService implements CrashService {
  @override
  void logError({required dynamic error, required StackTrace stackTrace}) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
}
