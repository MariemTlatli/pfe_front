// lib/presentation/provider/adaptive_exercise_provider.dart

import 'package:flutter/material.dart';
import 'package:front/data/data_sources/adaptive_exercise_remote_data_source.dart';
import 'package:front/data/models/exercise_model.dart';
import 'package:front/data/models/exercise_submission.dart';

/// État des exercices adaptatifs
class AdaptiveExerciseState {
  final AdaptiveExercisesResponseModel? exercisesResponse;
  final AdaptiveExerciseModel? currentExercise;
  final int currentIndex;
  final bool isGenerating;
  final String? error;
  final String? currentCompetenceId;
  final String? statusMessage;

  // ══════════════════════════════════════════════════════════════
  // NOUVEAUX CHAMPS POUR LA SOUMISSION
  // ══════════════════════════════════════════════════════════════
  final bool isSubmitting;
  final Map<String, dynamic>? lastDecision;
  final bool? lastSubmissionCorrect;
  final String? lastFeedbackMessage;

  AdaptiveExerciseState({
    this.exercisesResponse,
    this.currentExercise,
    this.currentIndex = 0,
    this.isGenerating = false,
    this.error,
    this.currentCompetenceId,
    this.statusMessage,
    // Nouveaux champs
    this.isSubmitting = false,
    this.lastDecision,
    this.lastSubmissionCorrect,
    this.lastFeedbackMessage,
  });

  AdaptiveExerciseState copyWith({
    AdaptiveExercisesResponseModel? exercisesResponse,
    AdaptiveExerciseModel? currentExercise,
    int? currentIndex,
    bool? isGenerating,
    String? error,
    String? currentCompetenceId,
    String? statusMessage,
    // Nouveaux champs
    bool? isSubmitting,
    Map<String, dynamic>? lastDecision,
    bool? lastSubmissionCorrect,
    String? lastFeedbackMessage,
  }) {
    return AdaptiveExerciseState(
      exercisesResponse: exercisesResponse ?? this.exercisesResponse,
      currentExercise: currentExercise ?? this.currentExercise,
      currentIndex: currentIndex ?? this.currentIndex,
      isGenerating: isGenerating ?? this.isGenerating,
      error: error,
      currentCompetenceId: currentCompetenceId ?? this.currentCompetenceId,
      statusMessage: statusMessage,
      // Nouveaux champs
      isSubmitting: isSubmitting ?? this.isSubmitting,
      lastDecision: lastDecision ?? this.lastDecision,
      lastSubmissionCorrect:
          lastSubmissionCorrect ?? this.lastSubmissionCorrect,
      lastFeedbackMessage: lastFeedbackMessage ?? this.lastFeedbackMessage,
    );
  }

  /// Vérifie si des exercices sont chargés
  bool get hasExercises =>
      exercisesResponse != null && exercisesResponse!.exercises.isNotEmpty;

  /// Liste des exercices
  List<AdaptiveExerciseModel> get exercises =>
      exercisesResponse?.exercises ?? [];

  /// Nombre total d'exercices
  int get totalExercises => exercises.length;

  /// Contexte SAINT+
  SAINTContextModel? get saintContext => exercisesResponse?.saintContext;

  /// Compétence
  ExerciseCompetenceModel? get competence => exercisesResponse?.competence;

  /// Leçons
  List<String> get lessonTitles => exercisesResponse?.lessonTitles ?? [];

  /// Progression (ex: "2 / 5")
  String get progressText => '$currentIndex / $totalExercises';

  /// Progression en pourcentage
  double get progressPercentage =>
      totalExercises > 0 ? currentIndex / totalExercises : 0.0;

  /// Peut aller au suivant ?
  bool get canGoNext => currentIndex < totalExercises;

  /// Peut revenir en arrière ?
  bool get canGoPrevious => currentIndex > 1;

  /// Est le dernier exercice ?
  bool get isLastExercise => currentIndex == totalExercises;

  // ══════════════════════════════════════════════════════════════
  // NOUVEAUX GETTERS POUR LA DÉCISION
  // ══════════════════════════════════════════════════════════════

  /// Action recommandée par le backend
  String? get recommendedAction => lastDecision?['action'] as String?;

  /// Message d'encouragement
  String? get encouragementMessage => lastDecision?['encouragement'] as String?;

  /// Prochaine étape recommandée
  Map<String, dynamic>? get nextStep =>
      lastDecision?['next_step'] as Map<String, dynamic>?;
}

/// Provider pour les exercices adaptatifs
class AdaptiveExerciseProvider extends ChangeNotifier {
  final AdaptiveExerciseRemoteDataSource _dataSource;

  AdaptiveExerciseState _state = AdaptiveExerciseState();
  AdaptiveExerciseState get state => _state;

  AdaptiveExerciseProvider({
    required AdaptiveExerciseRemoteDataSource dataSource,
  }) : _dataSource = dataSource;

  void _updateState(AdaptiveExerciseState newState) {
    _state = newState;
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════
  // GÉNÉRATION DES EXERCICES
  // ══════════════════════════════════════════════════════════════

  /// Générer des exercices adaptatifs
  Future<bool> generateExercises({
    required String competenceId,
    required String userId,
    int count = 3,
    bool regenerate = false,
  }) async {
    _updateState(
      _state.copyWith(
        isGenerating: true,
        error: null,
        currentCompetenceId: competenceId,
        statusMessage: 'Analyse de votre niveau avec SAINT+...',
      ),
    );

    try {
      final response = await _dataSource.generateExercises(
        competenceId: competenceId,
        userId: userId,
        count: count,
        regenerate: regenerate,
      );

      // Sélectionner le premier exercice
      final firstExercise = response.firstExercise;

      _updateState(
        _state.copyWith(
          exercisesResponse: response,
          currentExercise: firstExercise,
          currentIndex: 1,
          isGenerating: false,
          statusMessage: response.message,
        ),
      );

      return true;
    } catch (e) {
      _updateState(
        _state.copyWith(
          isGenerating: false,
          error: _formatError(e),
          statusMessage: null,
        ),
      );
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // SOUMISSION DE RÉPONSE (NOUVEAU)
  // ══════════════════════════════════════════════════════════════

  /// Soumet une réponse avec les données émotionnelles
  /// Retourne la réponse complète du backend
  Future<Map<String, dynamic>> submitAnswerWithEmotion(
    ExerciseSubmissionModel submission,
  ) async {
    _updateState(_state.copyWith(isSubmitting: true, error: null));

    try {
      print('📤 Envoi de la soumission au backend...');
      print('   - Exercise ID: ${submission.exerciseId}');
      print('   - Answer: ${submission.answer}');
      print('   - Emotion: ${submission.emotionData.dominantEmotion}');

      // Appeler le datasource
      final result = await _dataSource.submitAnswer(submission);

      // Extraire les données de la réponse
      final isCorrect = result['is_correct'] as bool? ?? false;
      final metadata = result['metadata'] as Map<String, dynamic>?;
      final mastery = (metadata?['mastery'] as num?)?.toDouble() ?? 0.0;
      final decision = result;
      final message = result['message'] as String? ?? '';

      print('✅ Réponse reçue:');
      print('   - Correct: $isCorrect');
      print('   - Action: ${decision?['action']}');
      print('   - Message: $message');
      print('   - Mastery: $mastery');

      // Mettre à jour l'état
      _updateState(
        _state.copyWith(
          isSubmitting: false,
          lastDecision: decision,
          lastSubmissionCorrect: isCorrect,
          lastFeedbackMessage: message,
        ),
      );

      return result;
    } catch (e) {
      print('❌ Erreur soumission: $e');

      _updateState(
        _state.copyWith(isSubmitting: false, error: _formatError(e)),
      );

      rethrow;
    }
  }

  // ✅ Méthode pour passer à l'exercice suivant
  void nextExerciseContent() {
    if (_state.currentIndex < _state.exercises.length - 1) {
      _state = _state.copyWith(currentIndex: _state.currentIndex + 1);
      notifyListeners(); // 🔥 Important : notifie l'UI pour rebuild
    }
  }

  // ✅ Méthode utilitaire pour savoir si c'est le dernier exercice
  bool get isLastExercise => _state.currentIndex >= _state.exercises.length - 1;

  // ══════════════════════════════════════════════════════════════
  // NAVIGATION
  // ══════════════════════════════════════════════════════════════

  /// Sélectionner un exercice par index
  void selectExercise(int index) {
    if (index >= 1 && index <= _state.totalExercises) {
      final exercise = _state.exercises[index - 1];
      _updateState(
        _state.copyWith(
          currentExercise: exercise,
          currentIndex: index,
          // Réinitialiser les résultats de soumission
          lastDecision: null,
          lastSubmissionCorrect: null,
          lastFeedbackMessage: null,
        ),
      );
    }
  }

  /// Passer à l'exercice suivant
  bool nextExercise() {
    if (_state.canGoNext) {
      final nextIndex = _state.currentIndex + 1;
      final exercise = _state.exercisesResponse?.getExercise(nextIndex - 1);

      if (exercise != null) {
        _updateState(
          _state.copyWith(
            currentExercise: exercise,
            currentIndex: nextIndex,
            // Réinitialiser les résultats de soumission
            lastDecision: null,
            lastSubmissionCorrect: null,
            lastFeedbackMessage: null,
          ),
        );
        return true;
      }
    }
    return false;
  }

  /// Revenir à l'exercice précédent
  bool previousExercise() {
    if (_state.canGoPrevious) {
      final prevIndex = _state.currentIndex - 1;
      final exercise = _state.exercisesResponse?.getExercise(prevIndex - 1);

      if (exercise != null) {
        _updateState(
          _state.copyWith(
            currentExercise: exercise,
            currentIndex: prevIndex,
            // Réinitialiser les résultats de soumission
            lastDecision: null,
            lastSubmissionCorrect: null,
            lastFeedbackMessage: null,
          ),
        );
        return true;
      }
    }
    return false;
  }

  // ══════════════════════════════════════════════════════════════
  // UTILITAIRES
  // ══════════════════════════════════════════════════════════════

  /// Effacer l'erreur
  void clearError() {
    _updateState(_state.copyWith(error: null));
  }

  /// Effacer tout
  void clearExercises() {
    _updateState(AdaptiveExerciseState());
  }

  /// Effacer le message de statut
  void clearStatusMessage() {
    _updateState(_state.copyWith(statusMessage: null));
  }

  /// Effacer les résultats de la dernière soumission
  void clearLastSubmission() {
    _updateState(
      _state.copyWith(
        lastDecision: null,
        lastSubmissionCorrect: null,
        lastFeedbackMessage: null,
      ),
    );
  }

  /// Formater les erreurs
  String _formatError(dynamic error) {
    final errorString = error.toString();

    if (errorString.contains('503')) {
      return 'Service Ollama indisponible. Vérifiez que le serveur est lancé.';
    }
    if (errorString.contains('404')) {
      return 'Compétence ou leçons introuvables.';
    }
    if (errorString.contains('timeout') ||
        errorString.contains('TimeoutException')) {
      return 'La génération a pris trop de temps. Réessayez.';
    }
    if (errorString.contains('SocketException') ||
        errorString.contains('Connection refused')) {
      return 'Impossible de se connecter au serveur.';
    }

    return 'Erreur: $errorString';
  }
}
