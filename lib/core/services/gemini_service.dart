import 'package:google_generative_ai/google_generative_ai.dart';
import '../../features/admin/admin_mock.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    print('Initializing GeminiService with model: gemini-2.5-flash');
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: AdminConfig.geminiApiKey);
  }

  Future<void> _listModels() async {
    // This is a temporary debug helper using a raw request since SDK might not expose listModels easily
    // or just rely on 'try' logic. 
    // Actually, let's just print that we are trying to connect.
    print("Attempting to connect to Gemini API...");
  }

  GenerativeModel get model => _model;

  // Added a direct gen method to mimic the direct usage in viral_news_ai
  Future<String> generateContent(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? '';
    } catch (e) {
      rethrow;
    }
  }
}
