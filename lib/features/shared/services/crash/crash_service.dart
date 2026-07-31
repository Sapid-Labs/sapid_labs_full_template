/// The crash-reporting interface every caught error goes through.
///
/// Keep this a pure interface. It used to carry a `logError` body that built both
/// `FirebaseCrashService()` and `SentryCrashService()` on every call, so the base
/// class imported both vendors and neither file could be deleted from a child app
/// that had picked the other one. Pick the vendor with the `// STACK_<NAME>` marker
/// on the implementation, or run `tool/stack.py`.
abstract class CrashService {
  void logError({required dynamic error, required StackTrace stackTrace});
}
