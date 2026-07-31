/// The analytics interface every child app talks to.
///
/// Keep this a pure interface. It used to carry method bodies that constructed
/// `AmplitudeAnalyticsService()` and `FirebaseAnalyticsService()` directly, which
/// defeated the point of the stack scheme: a caller who reached the base class got
/// both vendors regardless of which implementation was registered, and each call
/// built a fresh SDK instance. Pick the vendor with the `// STACK_<NAME>` marker on
/// the implementation, never here.
abstract class AnalyticsService {
  Future<void> setup();

  Future<void> setUserProperties(Map<String, dynamic> properties);

  Future<void> logEvent(String name, {Map<String, dynamic>? parameters});

  void updateVersionId(String? versionId, {String? userId});
}
