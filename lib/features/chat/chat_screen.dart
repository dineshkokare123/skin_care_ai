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
      appBar: AppBar(
        title: const Text("AI Skin Consultant"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const NetworkImage("https://www.transparenttextures.com/patterns/cubes.png"), // Subtle pattern or gradient
            colorFilter: ColorFilter.mode(Colors.grey.withOpacity(0.05), BlendMode.dstATop),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _history.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _history.length) {
                    return _buildTypingIndicator();
                  }

                  final content = _history[index];
                  final isUser = content.role == 'user';
                  final text = content.parts.whereType<TextPart>().map((e) => e.text).join('');
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser) _buildAvatar(false),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isUser ? AppTheme.primary : Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                )
                              ],
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(20),
                                topRight: const Radius.circular(20),
                                bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
                                bottomRight: isUser ? Radius.zero : const Radius.circular(20),
                              ),
                            ),
                            child: MarkdownBody(
                              data: text,
                              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                                p: TextStyle(color: isUser ? Colors.white : AppTheme.textDark, height: 1.5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isUser) _buildAvatar(true),
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: isUser ? AppTheme.accent : AppTheme.secondary,
      child: Icon(
        isUser ? Icons.person : Icons.auto_awesome,
        size: 16,
        color: isUser ? Colors.white : AppTheme.primary,
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 40),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
            ),
            const SizedBox(width: 8),
            Text("AI is typing...", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "Ask about routines, products...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
