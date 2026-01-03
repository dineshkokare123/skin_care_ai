import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../features/admin/admin_mock.dart';

import 'gemini_service.dart';

class BlogService {
  late final GenerativeModel _model;
  final String apiKey;

  BlogService()
      : apiKey = AdminConfig.geminiApiKey {
    _model = GeminiService().model;
  }

  Future<List<BlogPost>> fetchLatestBlogs() async {
    // If API key is empty/default, skip API call
    if (apiKey == 'YOUR_GEMINI_API_KEY_HERE' || apiKey.isEmpty) {
      print('⚠️ Using static blogs - Add your Gemini API key to AdminConfig.geminiApiKey');
      return AdminConfig.blogPosts;
    }

    const prompt = """
    Generate 3 engaging and educational skincare blog posts.
    Return the response ONLY as a raw JSON list. 
    Each object in the list should have these fields:
    - title: String (Catchy title)
    - summary: String (Short 1 sentence summary)
    - content: String (3-4 paragraphs of detailed advice)
    - imageUrl: String (Use a placeholder URL like 'https://source.unsplash.com/random?skincare')

    Example format:
    [
      {
        "title": "...",
        "summary": "...",
        "content": "...",
        "imageUrl": "..."
      }
    ]
    """;

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      final responseText = response.text;
      if (responseText == null) return AdminConfig.blogPosts;

      final cleanJson = responseText.replaceAll('```json', '').replaceAll('```', '').trim();
      final List<dynamic> data = jsonDecode(cleanJson);
      
      return data.map((json) => BlogPost(
        title: json['title'] ?? 'No Title',
        summary: json['summary'] ?? '',
        content: json['content'] ?? '',
        imageUrl: json['imageUrl'] ?? '',
      )).toList();
    } catch (e) {
      print('⚠️ Gemini API Error: $e');
      return AdminConfig.blogPosts;
    }
  }

  // Remove the old fallback method
}
