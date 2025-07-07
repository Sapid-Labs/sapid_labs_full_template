import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:slapp/app/get_it.dart';
import 'package:slapp/features/shared/services/ai_service.dart';

@firebase
@LazySingleton(as: AIService)
class FirebaseAIService implements AIService {
  @override
  Future<String?> generateText(String prompt) async {
    try {
      final model =
          FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash');

      final content = [Content.text(prompt)];

      final response = await model.generateContent(content);
      debugPrint(response.text);

      return response.text;
    } catch (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack);
      return null;
    }
  }

  @override
  Future<String?> generateStructuredResponse(
      String prompt, dynamic jsonSchema) async {
    try {
      final model = FirebaseAI.googleAI().generativeModel(
          model: 'gemini-2.5-flash',
          generationConfig: GenerationConfig(
              responseMimeType: 'application/json',
              responseSchema: jsonSchema));

      final response = await model.generateContent([Content.text(prompt)]);

      return response.text;
    } catch (error, stack) {
      debugPrint('Error generating structured output: $error');
      FirebaseCrashlytics.instance.recordError(error, stack);

      return null;
    }
  }
}
