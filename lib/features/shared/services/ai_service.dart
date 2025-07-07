import 'package:slapp/features/shared/services/firebase_ai_service.dart';

abstract class AIService {
  Future<String?> generateText(String prompt) async {
    FirebaseAIService().generateText(prompt);
    return null;
  }

  Future<String?> generateStructuredResponse(
      String prompt, dynamic jsonSchema) async {
    FirebaseAIService().generateStructuredResponse(prompt, jsonSchema);
    return null;
  }
}
