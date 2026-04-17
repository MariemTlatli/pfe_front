// lib/presentation/screens/exercice_uno/models/quiz_models.dart

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String competenceId;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.competenceId,
  });
}

class QuizResult {
  final int score;
  final int total;
  final List<bool> results;

  QuizResult({
    required this.score,
    required this.total,
    required this.results,
  });
}
