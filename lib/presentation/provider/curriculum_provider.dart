import 'package:flutter/material.dart';
import 'package:front/data/data_sources/generate_subject.dart';
import 'package:front/data/models/curriculum_models.dart';

/// État du curriculum
class CurriculumState {
  final CurriculumResponseModel? curriculum;
  final bool isLoading;
  final bool isGenerating;
  final String? error;
  final String? currentSubjectId;
  final String? statusMessage;

  CurriculumState({
    this.curriculum,
    this.isLoading = false,
    this.isGenerating = false,
    this.error,
    this.currentSubjectId,
    this.statusMessage,
  });

  CurriculumState copyWith({
    CurriculumResponseModel? curriculum,
    bool? isLoading,
    bool? isGenerating,
    String? error,
    String? currentSubjectId,
    String? statusMessage,
  }) {
    return CurriculumState(
      curriculum: curriculum ?? this.curriculum,
      isLoading: isLoading ?? this.isLoading,
      isGenerating: isGenerating ?? this.isGenerating,
      error: error,
      currentSubjectId: currentSubjectId ?? this.currentSubjectId,
      statusMessage: statusMessage,
    );
  }

  bool get hasCurriculum => curriculum != null;

  List<CurriculumCompetenceModel> get competences =>
      curriculum?.competences ?? [];

  CurriculumStatsModel? get stats => curriculum?.stats;

  List<CurriculumCompetenceModel> get competencesByLevel =>
      curriculum?.competencesByLevel ?? [];
}

/// Provider pour la gestion du curriculum
class CurriculumProvider extends ChangeNotifier {
  final CurriculumRemoteDataSource _dataSource;

  CurriculumState _state = CurriculumState();
  CurriculumState get state => _state;

  CurriculumProvider({required CurriculumRemoteDataSource dataSource})
      : _dataSource = dataSource;

  void _updateState(CurriculumState newState) {
    _state = newState;
    notifyListeners();
  }
  /// Met à jour le statut des leçons d'une compétence (après génération)
void updateCompetenceLessonsStatus({
  required String competenceId,
  required bool hasLessons,
  required int lessonsCount,
}) {
  if (_state.curriculum == null) return;

  // Mettre à jour la compétence concernée
  final updatedCompetences = _state.curriculum!.competences.map((comp) {
    if (comp.id == competenceId) {
      return comp.copyWith(
        hasLessons: hasLessons,
        lessonsCount: lessonsCount,
      );
    }
    return comp;
  }).toList();

  // Mettre à jour le state
  _updateState(_state.copyWith(
    curriculum: CurriculumResponseModel(
      competences: updatedCompetences,
      stats: _state.curriculum!.stats,
      message: _state.curriculum!.message,
    ),
  ));
}
  /// Méthode principale : Charge ou génère le curriculum selon hasCurriculum
  Future<bool> loadOrGenerateCurriculum({
    required String subjectId,
    required bool hasCurriculum,
  }) async {
    if (hasCurriculum) {
      return await _getCurriculum(subjectId: subjectId);
    } else {
      return await _generateCurriculum(subjectId: subjectId);
    }
  }

  /// GET - Récupérer un curriculum existant
  Future<bool> _getCurriculum({required String subjectId}) async {
    _updateState(_state.copyWith(
      isLoading: true,
      isGenerating: false,
      error: null,
      currentSubjectId: subjectId,
      statusMessage: 'Chargement du curriculum...',
    ));

    try {
      final curriculum = await _dataSource.getCurriculum(
        subjectId: subjectId,
      );

      _updateState(_state.copyWith(
        curriculum: curriculum,
        isLoading: false,
        statusMessage: 'Curriculum chargé avec succès',
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
  
  /// POST - Générer le curriculum (2 requêtes)
  Future<bool> _generateCurriculum({
    required String subjectId,
    bool regenerate = false,
  }) async {
    _updateState(_state.copyWith(
      isLoading: false,
      isGenerating: true,
      error: null,
      currentSubjectId: subjectId,
      statusMessage: 'Génération du curriculum en cours...',
    ));

    try {
      final curriculum = await _dataSource.generateCurriculum(
        subjectId: subjectId,
        regenerate: regenerate,
      );

      _updateState(_state.copyWith(
        curriculum: curriculum,
        isGenerating: false,
        statusMessage: curriculum.message ?? 'Curriculum généré avec succès',
      ));

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

  /// Régénérer le curriculum (forcer la regénération)
  Future<bool> regenerateCurriculum({required String subjectId}) async {
    return await _generateCurriculum(
      subjectId: subjectId,
      regenerate: true,
    );
  }

  void clearError() {
    _updateState(_state.copyWith(error: null));
  }

  void clearCurriculum() {
    _updateState(CurriculumState());
  }

  String _formatError(dynamic error) {
    final errorString = error.toString();

    if (errorString.contains('503')) {
      return 'Service Ollama indisponible. Vérifiez que Ollama est lancé.';
    }
    if (errorString.contains('404')) {
      return 'Matière introuvable.';
    }
    if (errorString.contains('409')) {
      return 'Un curriculum existe déjà. Utilisez regenerate pour le recréer.';
    }
    if (errorString.contains('timeout') ||
        errorString.contains('TimeoutException')) {
      return 'La génération a pris trop de temps. Réessayez.';
    }

    return 'Erreur: $errorString';
  }
}