import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:dartantic_interface/dartantic_interface.dart' show ChatMessage;
import 'package:injectable/injectable.dart';
import 'package:json_schema/json_schema.dart' show JsonSchema;
import 'package:slapp/features/feedback/models/feedback.dart';

@lazySingleton
class AIService {
  Future<String?> generateText(String prompt) async {
    try {
      final agent = Agent(
        'google:gemini-2.5-flash', // or 'google', 'anthropic', 'ollama', etc.
      );

      final result = await agent.send(
        prompt,
        history: [
          // ChatMessage.system(prompt),
        ],
      );
      print(result.output);

      return result.output;
    } catch (error) {
      print('Error generating text: $error');
      return null;
    }
  }

  Future<Feedback?> generateStructuredResponse(String prompt) async {
    try {
      final agent = Agent(
        'google:gemini-2.5-flash', // or 'google', 'anthropic', 'ollama', etc.
      );

      final response = await agent.sendFor<Feedback>(
        prompt,
        /* history: [ChatMessage.system('You are a helpful assistant.')], */
        outputSchema: JsonSchema.create({
          'type': 'object',
          'properties': {
            'content': {'type': 'string'},
            'type': {'type': 'string'},
          },
          'required': ['town', 'country'],
        }),
        outputFromJson: Feedback.fromJson,
      );

      return response.output;
    } catch (error) {
      print('Error generating structured output: $error');
      return null;
    }
  }
}
