import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/quiz_service.dart';
import '../../admin/admin_mock.dart';

final quizServiceProvider = Provider((ref) => QuizService());

final quizQuestionsProvider = FutureProvider<List<QuizQuestion>>((ref) async {
  final quizService = ref.watch(quizServiceProvider);
  return quizService.fetchQuizQuestions();
});
