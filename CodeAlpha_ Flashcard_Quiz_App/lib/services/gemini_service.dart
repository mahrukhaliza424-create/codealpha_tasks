import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static Future<String> explainConcept(String answer) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_api_key_here') {
      return "AI Explanation requires a valid Gemini API Key in the .env file.";
    }

    try {
      final prompt = 'Explain this concept simply, ideally using a brief, real-world analogy (max 2 sentences): $answer';
      final responseText = await _generateContent(prompt, apiKey);
      return responseText ?? "Could not generate an explanation.";
    } catch (e) {
      return "Error reaching Gemini AI: $e";
    }
  }

  static Future<List<Map<String, String>>> generateFlashcardsFromText(String text) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_api_key_here') {
      throw Exception("Valid Gemini API Key required in .env file to generate cards.");
    }

    try {
      final prompt = '''
      You are a flashcard generator. Extract the most important concepts from the following text and generate question-answer pairs.
      Return ONLY a JSON array of objects, where each object has a "question" string and an "answer" string.
      Maximum 10 pairs.
      
      Text:
      $text
      ''';
      
      final responseText = await _generateContent(prompt, apiKey);
      
      if (responseText != null) {
        final startIndex = responseText.indexOf('[');
        final endIndex = responseText.lastIndexOf(']');
        
        if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
          final jsonString = responseText.substring(startIndex, endIndex + 1);
          final List<dynamic> jsonList = jsonDecode(jsonString);
          return jsonList.map((item) => {
            'question': item['question']?.toString() ?? '',
            'answer': item['answer']?.toString() ?? '',
          }).toList();
        }
      }
      
      return [];
    } catch (e) {
      throw Exception("Error generating flashcards: $e");
    }
  }

  static Future<String?> _generateContent(String prompt, String apiKey) async {
    final endpointsToTry = [
      'https://generativelanguage.googleapis.com/v1/models/',
      'https://generativelanguage.googleapis.com/v1beta/models/'
    ];
    final modelsToTry = [
      'gemini-3.5-flash',
      'gemini-3.1-flash-lite',
      'gemini-2.5-flash',
      'gemini-1.5-flash',
      'gemini-1.5-pro',
    ];
    String lastError = "";

    for (String endpoint in endpointsToTry) {
      for (String model in modelsToTry) {
      final client = HttpClient();
      try {
        final url = Uri.parse('$endpoint$model:generateContent?key=$apiKey');
        final request = await client.postUrl(url);
        request.headers.contentType = ContentType.json;
        
        request.write(jsonEncode({
          "contents": [{
            "parts": [{"text": prompt}]
          }]
        }));
        
        final response = await request.close();
        final responseBody = await response.transform(utf8.decoder).join();
        
        if (response.statusCode == 200) {
          final data = jsonDecode(responseBody);
          final text = data['candidates']?[0]['content']?['parts']?[0]['text'];
          if (text != null) return text;
        } else {
          lastError = "HTTP ${response.statusCode}: $responseBody";
          // If it's a 404 model not found error, loop continues to next model
          if (response.statusCode != 404) {
            throw Exception(lastError);
          }
        }
      } catch (e) {
        lastError = e.toString();
        // Socket exceptions are network errors, no point trying other models
        if (lastError.contains("SocketException")) {
          throw Exception(lastError);
        }
      } finally {
        client.close();
      }
    }
    }
    
    throw Exception("Tried multiple Gemini models and endpoints but all failed. Last error: $lastError");
  }
}
