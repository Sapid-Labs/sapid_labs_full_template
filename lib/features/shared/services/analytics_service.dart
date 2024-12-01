import 'package:injectable/injectable.dart';

@injectable
class AnalyticsService {

  Future<void> setup() async {
    // Setup logic
  }
  
  void logEvent(String name, {Map<String, dynamic>? parameters}) {
    // Log event
  }
}
