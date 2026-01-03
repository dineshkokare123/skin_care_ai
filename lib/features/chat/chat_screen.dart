import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:skin_care_ai/core/app_theme.dart';
import '../admin/admin_mock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/admin/providers/product_provider.dart';
import '../../core/services/gemini_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Content> _history = [];
  bool _isLoading = false;
  
  late final GenerativeModel _model;
  late final ChatSession _chat;

  @override
  void initState() {
    super.initState();
    _model = GeminiService().model;
    
    // Get current marketplace products to give AI context
    final products = ref.read(productProvider);
    final productContext = products.map((p) => "- ${p.name} (${p.category}): ${p.description}").join("\n");

    _chat = _model.startChat(history: [
      Content.text("""
${AdminConfig.aiSystemPrompt}

CURRENT MARKETPLACE PRODUCTS:
$productContext

You are aware of these products and can recommend them if they fit the user's skin profile.
      """),
    ]);
  }

  Future<void> _sendMessage() async {
    final text = _controller.text;
    if (text.isEmpty) return;

    setState(() {
      _history.add(Content.text(text));
      _isLoading = true;
      _controller.clear();
    });

    try {
      final response = await _chat.sendMessage(Content.text(text));
      setState(() {
        _history.add(Content.model([TextPart(response.text ?? "")]));
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Gemini Error: $e');
      String errorMsg = "Error: ${e.toString()}";
      
      if (e.toString().contains("quota") || e.toString().contains("429")) {
        errorMsg = "The AI is a bit busy (Quota Limit). Please try again in 1 minute!";
      } else if (e.toString().contains("not found")) {
        errorMsg = "Model configuration error. Please contact the administrator.";
      }

      setState(() {
        _history.add(Content.model([TextPart(errorMsg)]));
        _isLoading = false;
      });
    }
  }

  // Remove the old fallback method

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Skin Consultant")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final content = _history[index];
                final isUser = content.role == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 300),
                    decoration: BoxDecoration(
                      color: isUser ? AppTheme.primary : AppTheme.secondary,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isUser ? Radius.zero : null,
                        bottomLeft: isUser ? null : Radius.zero,
                      ),
                    ),
                    child: MarkdownBody(
                      data: content.parts.whereType<TextPart>().map((e) => e.text).join(''),
                      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                        p: TextStyle(color: isUser ? Colors.white : Colors.black87),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Ask about your skin...",
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  color: AppTheme.primary,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
