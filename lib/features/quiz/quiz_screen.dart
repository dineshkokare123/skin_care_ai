import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skin_care_ai/core/app_theme.dart';
import '../admin/admin_mock.dart';
import 'providers/quiz_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../routine/providers/routine_provider.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentIndex = 0;
  final Map<String, String> _answers = {};

  void _answer(List<QuizQuestion> questions, String answer) {
    setState(() {
      _answers[questions[_currentIndex].id] = answer;
      if (_currentIndex < questions.length - 1) {
        _currentIndex++;
      } else {
        // Quiz Finished
        final skinType = _answers['q1'] ?? 'Normal'; // Fallback logic is loose here, relying on ID consistency or simple assumption
        final concern = _answers['q2'] ?? 'General Care';
        
        // Trigger dynamic routine generation
        // Note: For a strictly dynamic quiz, we might need AI to interpret the answers too.
        // For now, we pass the raw text answers which the Routine AI should be able to handle.
        ref.read(routineProvider.notifier).generateRoutine(skinType, concern);
        
        context.go('/routine'); // Go to Routine
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(quizQuestionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Skin Analysis", style: AppTheme.lightTheme.textTheme.displayMedium?.copyWith(fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
      ),
      body: questionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (err, stack) => Center(child: Text("Error loading quiz: $err")),
        data: (questions) {
          if (questions.isEmpty) return const Center(child: Text("No questions available."));

          final question = questions[_currentIndex];
          final progress = (_currentIndex + 1) / questions.length;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(value: progress, color: AppTheme.accent, backgroundColor: AppTheme.secondary),
                const SizedBox(height: 32),
                Text(
                  question.question,
                  style: AppTheme.lightTheme.textTheme.displayMedium,
                ),
                const SizedBox(height: 32),
                ...question.options.map((option) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ElevatedButton(
                    onPressed: () => _answer(questions, option),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.surface,
                      foregroundColor: AppTheme.textDark,
                      elevation: 1,
                      side: const BorderSide(color: AppTheme.secondary),
                    ),
                    child: Text(option),
                  ),
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}
