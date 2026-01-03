import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../features/admin/admin_mock.dart';
import 'gemini_service.dart';

class QuizService {
  late final GenerativeModel _model;
  final String apiKey;

  QuizService() : apiKey = AdminConfig.geminiApiKey {
    _model = GeminiService().model;
  }

  Future<List<QuizQuestion>> fetchQuizQuestions() async {
    // If API key is empty/default, return mock data
    if (apiKey == 'YOUR_GEMINI_API_KEY_HERE' || apiKey.isEmpty) {
      return AdminConfig.quizQuestions;
    }

    const prompt = """
    Generate 5 relevant questions for a skincare analysis quiz to determine a user's skin type and concerns.
    Return the response ONLY as a raw JSON list.
    Each object in the list should have these fields:
    - id: String (unique id like 'q1', 'q2')
    - question: String (The question text)
    - options: List<String> (3-4 possible answers)

    Example format:
    [
      {
        "id": "q1",
        "question": "How does your skin feel?",
        "options": ["Oily", "Dry", "Normal"]
      }
    ]
    """;

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      final responseText = response.text;
      if (responseText == null) return AdminConfig.quizQuestions;

      final cleanJson = responseText.replaceAll('```json', '').replaceAll('```', '').trim();
      final List<dynamic> data = jsonDecode(cleanJson);
      
      return data.map((json) => QuizQuestion(
        id: json['id'] ?? 'unknown',
        question: json['question'] ?? 'Unknown Question',
        options: List<String>.from(json['options'] ?? []),
      )).toList();
    } catch (e) {
      print('⚠️ Gemini API Error (Quiz): $e');
      return AdminConfig.quizQuestions;
    }
  }
}
