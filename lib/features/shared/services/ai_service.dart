import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:slapp/features/shared/services/custom_http_client.dart';

@lazySingleton
class AIService {
  /// Creates a custom HTTP client with default headers
  CustomHttpClient createCustomHttpClient() {
    return CustomHttpClient(
      defaultHeaders: {
        'User-Agent': 'SuppConnect/1.0',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-Android-Package': 'com.sapidlabs.suppconnect',
        'X-Android-Cert': kDebugMode
            ? 'E9:B0:61:17:39:A8:4A:05:0D:57:E2:5A:CA:0B:06:27:59:93:EE:5F'
                .replaceAll(':', '')
            : 'E9:B0:61:17:39:A8:4A:05:0D:57:E2:5A:CA:0B:06:27:59:93:EE:5F'
                .replaceAll(":", '')
        // Add any other headers you want to include with every request
        // 'Authorization': 'Bearer your-token',
        // 'X-Custom-Header': 'your-value',
      },
    );
  }

  Future<dynamic> generateStructuredResponse(String prompt) async {
    try {
      final apiKey = Platform.isAndroid
          ? const String.fromEnvironment('GEMINI_API_KEY_ANDROID')
          : const String.fromEnvironment('GEMINI_API_KEY_IOS');

      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro:generateContent');

      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
          'responseSchema': {
            'type': 'OBJECT',
            'properties': {
              'name': {'type': 'STRING'},
              'brand': {'type': 'STRING'},
              'form': {
                'type': 'STRING',
                'enum': ['capsule', 'powder', 'liquid', 'gummy', 'tablet']
              },
            },
            'required': ['name'],
          }
        }
      };

      final response = await http.post(
        url,
        headers: {
          'x-goog-api-key': apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final content =
            responseData['candidates']?[0]?['content']?['parts']?[0]?['text'];

        if (content != null) {
          final productJson = jsonDecode(content);
          return productJson;
        }
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
      }

      return null;
    } catch (error) {
      print('Error generating structured output: $error');
      return null;
    }
  }
}
