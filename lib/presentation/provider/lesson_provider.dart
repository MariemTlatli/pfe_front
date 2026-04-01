import 'package:flutter/material.dart';
import 'package:front/data/data_sources/lesson_remote_data_source.dart';
import 'package:front/data/models/lesson_model.dart';

/// État des leçons
class LessonState {
  final LessonsResponseModel? lessonsResponse;
  final LessonModel? selectedLesson;
  final bool isLoading;
  final bool isGenerating;
  final String? error;
  final String? currentCompetenceId;
  final String? statusMessage;

  LessonState({
    this.lessonsResponse,
    this.selectedLesson,
    this.isLoading = false,
    this.isGenerating = false,
    this.error,
    this.currentCompetenceId,
    this.statusMessage,
  });

  LessonState copyWith({
    LessonsResponseModel? lessonsResponse,
    LessonModel? selectedLesson,
    bool? isLoading,
    bool? isGenerating,
    String? error,
    String? currentCompetenceId,
    String? statusMessage,
  }) {
    return LessonState(
      lessonsResponse: lessonsResponse ?? this.lessonsResponse,
      selectedLesson: selectedLesson ?? this.selectedLesson,
      isLoading: isLoading ?? this.isLoading,
      isGenerating: isGenerating ?? this.isGenerating,
      error: error,
      currentCompetenceId: currentCompetenceId ?? this.currentCompetenceId,
      statusMessage: statusMessage,
    );
  }

  /// Vérifie si des leçons sont chargées
  bool get hasLessons => lessonsResponse != null && lessonsResponse!.lessons.isNotEmpty;

  /// Récupère les leçons ou liste vide
  List<LessonModel> get lessons => lessonsResponse?.lessons ?? [];

  /// Récupère la compétence associée
  LessonCompetenceModel? get competence => lessonsResponse?.competence;

  /// Nombre de leçons
  int get lessonsCount => lessonsResponse?.count ?? 0;

  /// Temps total estimé formaté
  String get totalTime => lessonsResponse?.totalEstimatedTimeFormatted ?? '0min';
}

/// Provider pour la gestion des leçons
class LessonProvider extends ChangeNotifier {
  final LessonRemoteDataSource _dataSource;
  final Function(String competenceId, int lessonsCount)? onLessonsGenerated; // ← NOUVEAU
  LessonState _state = LessonState();
  LessonState get state => _state;

  LessonProvider({required LessonRemoteDataSource dataSource, this.onLessonsGenerated,})
      : _dataSource = dataSource;

  void _updateState(LessonState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Méthode principale : Charge ou génère les leçons selon hasLessons
  Future<bool> loadOrGenerateLessons({
    required String competenceId,
    required bool hasLessons,
  }) async {
    if (hasLessons) {
      return await _getLessons(competenceId: competenceId);
    } else {
      return await _generateLessons(competenceId: competenceId);
    }
  }

  /// GET - Récupérer les leçons existantes
  Future<bool> _getLessons({required String competenceId}) async {
    _updateState(_state.copyWith(
      isLoading: true,
      isGenerating: false,
      error: null,
      currentCompetenceId: competenceId,
      statusMessage: 'Chargement des leçons...',
    ));

    try {
      final response = await _dataSource.getLessons(
        competenceId: competenceId,
      );

      _updateState(_state.copyWith(
        lessonsResponse: response,
        selectedLesson: response.firstLesson,
        isLoading: false,
        statusMessage: 'Leçons chargées avec succès',
      ));

      return true;
    } catch (e) {
      _updateState(_state.copyWith(
        isLoading: false,
        error: _formatError(e),
        statusMessage: null,
      ));
      return false;
    }
  }

/// POST - Générer les leçons via Ollama
  Future<bool> _generateLessons({required String competenceId}) async {
    _updateState(_state.copyWith(
      isLoading: false,
      isGenerating: true,
      error: null,
      currentCompetenceId: competenceId,
      statusMessage: 'Génération des leçons en cours...',
    ));

    try {
      final response = await _dataSource.generateLessons(
        competenceId: competenceId,
      );

      _updateState(_state.copyWith(
        lessonsResponse: response,
        selectedLesson: response.firstLesson,
        isGenerating: false,
        statusMessage: 'Leçons générées avec succès',
      ));

      // ← NOUVEAU : Notifier le callback après génération réussie
      if (onLessonsGenerated != null) {
        onLessonsGenerated!(competenceId, response.count);
      }

      return true;
    } catch (e) {
      _updateState(_state.copyWith(
        isGenerating: false,
        error: _formatError(e),
        statusMessage: null,
      ));
      return false;
    }
  }

  /// Régénérer les leçons (forcer la regénération)
  Future<bool> regenerateLessons({required String competenceId}) async {
    return await _generateLessons(competenceId: competenceId);
  }

  /// Sélectionner une leçon
  void selectLesson(LessonModel lesson) {
    _updateState(_state.copyWith(selectedLesson: lesson));
  }

  /// Revenir à la liste (désélectionner la leçon courante)
  void clearSelectedLesson() {
    _updateState(
      LessonState(
        lessonsResponse: _state.lessonsResponse,
        selectedLesson: null,
        isLoading: _state.isLoading,
        isGenerating: _state.isGenerating,
        error: _state.error,
        currentCompetenceId: _state.currentCompetenceId,
        statusMessage: _state.statusMessage,
      ),
    );
  }

  /// Sélectionner une leçon par son ordre
  void selectLessonByOrder(int order) {
    final lesson = _state.lessonsResponse?.getLessonByOrder(order);
    if (lesson != null) {
      _updateState(_state.copyWith(selectedLesson: lesson));
    }
  }

  /// Passer à la leçon suivante
  bool nextLesson() {
    if (_state.selectedLesson == null || _state.lessonsResponse == null) {
      return false;
    }

    final currentOrder = _state.selectedLesson!.order;
    final nextLesson = _state.lessonsResponse!.getLessonByOrder(currentOrder + 1);

    if (nextLesson != null) {
      _updateState(_state.copyWith(selectedLesson: nextLesson));
      return true;
    }
    return false;
  }

  /// Revenir à la leçon précédente
  bool previousLesson() {
    if (_state.selectedLesson == null || _state.lessonsResponse == null) {
      return false;
    }

    final currentOrder = _state.selectedLesson!.order;
    final prevLesson = _state.lessonsResponse!.getLessonByOrder(currentOrder - 1);

    if (prevLesson != null) {
      _updateState(_state.copyWith(selectedLesson: prevLesson));
      return true;
    }
    return false;
  }

  /// Vérifier si on peut aller à la leçon suivante
  bool get canGoNext {
    if (_state.selectedLesson == null || _state.lessonsResponse == null) {
      return false;
    }
    return _state.selectedLesson!.order < _state.lessonsResponse!.count;
  }

  /// Vérifier si on peut revenir à la leçon précédente
  bool get canGoPrevious {
    if (_state.selectedLesson == null) return false;
    return _state.selectedLesson!.order > 1;
  }

  /// Effacer l'erreur
  void clearError() {
    _updateState(_state.copyWith(error: null));
  }

  /// Effacer les leçons
  void clearLessons() {
    _updateState(LessonState());
  }

  /// Formater les erreurs
  String _formatError(dynamic error) {
    final errorString = error.toString();

    if (errorString.contains('503')) {
      return 'Service Ollama indisponible. Vérifiez que Ollama est lancé.';
    }
    if (errorString.contains('404')) {
      return 'Compétence introuvable.';
    }
    if (errorString.contains('timeout') ||
        errorString.contains('TimeoutException')) {
      return 'La génération a pris trop de temps. Réessayez.';
    }
    if (errorString.contains('FormatException') ||
        errorString.contains('type \'String\' is not a subtype of type')) {
      return 'Format de réponse invalide. Vérifiez la réponse backend des leçons.';
    }

    return 'Erreur: $errorString';
  }
}