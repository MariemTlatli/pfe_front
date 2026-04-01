import 'package:flutter/material.dart';
import 'package:front/data/data_sources/zpd_remote_data_source.dart';
import 'package:front/data/models/zpd_models.dart';

/// État de l'analyse ZPD
class ZPDState {
  final CompetenceZPDAnalysisModel? analysis;
  final bool isLoading;
  final String? error;
  final String? currentCompetenceId;

  ZPDState({
    this.analysis,
    this.isLoading = false,
    this.error,
    this.currentCompetenceId,
  });

  ZPDState copyWith({
    CompetenceZPDAnalysisModel? analysis,
    bool? isLoading,
    String? error,
    String? currentCompetenceId,
  }) {
    return ZPDState(
      analysis: analysis ?? this.analysis,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentCompetenceId: currentCompetenceId ?? this.currentCompetenceId,
    );
  }

  /// Vérifie si une analyse est chargée
  bool get hasAnalysis => analysis != null;

  /// Niveau de maîtrise
  double get masteryLevel => analysis?.masteryLevel ?? 0.0;

  /// Zone ZPD effective
  String get zone => analysis?.effectiveZone ?? 'frustration';

  /// L'élève est-il prêt ?
  bool get isReady => analysis?.isReady ?? false;

  /// Métriques SAINT+
  SAINTMetricsModel? get saintMetrics => analysis?.saintMetrics;

  /// Difficulté optimale recommandée
  double get optimalDifficulty => analysis?.optimalDifficulty ?? 0.1;

  /// Types d'exercices recommandés
  List<String> get recommendedExerciseTypes =>
      analysis?.recommendedExerciseTypes ?? [];

  /// Nombre d'exercices minimum
  int get minExercises => analysis?.difficultyParams.minExercises ?? 3;

  /// Tentatives estimées
  int get estimatedAttempts =>
      analysis?.saintMetrics.estimatedAttempts.value ?? 3;

  /// Probabilité de besoin d'indice
  String get hintLevel =>
      analysis?.saintMetrics.hintProbability.level ?? 'moyen';

  /// Score d'engagement
  String get engagementLevel =>
      analysis?.saintMetrics.engagement.level ?? 'inconnu';
}

/// Provider pour l'analyse ZPD
class ZPDProvider extends ChangeNotifier {
  final ZPDRemoteDataSource _dataSource;

  ZPDState _state = ZPDState();
  ZPDState get state => _state;

  ZPDProvider({required ZPDRemoteDataSource dataSource})
      : _dataSource = dataSource;

  void _updateState(ZPDState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Analyser une compétence avec SAINT+
  Future<bool> analyzeCompetence({
    required String competenceId,
    required String userId,
    double? masteryLevel,
    Map<String, double>? allMasteries,
  }) async {
    // Vérifier les paramètres
    if (competenceId.isEmpty || userId.isEmpty) {
      _updateState(_state.copyWith(
        isLoading: false,
        error: 'ID de compétence ou utilisateur manquant',
      ));
      return false;
    }

    _updateState(_state.copyWith(
      isLoading: true,
      error: null,
      currentCompetenceId: competenceId,
    ));

    try {
      final analysis = await _dataSource.analyzeCompetence(
        competenceId: competenceId,
        userId: userId,
        masteryLevel: masteryLevel,
        allMasteries: allMasteries,
      );

      _updateState(_state.copyWith(
        analysis: analysis,
        isLoading: false,
      ));

      return true;
    } catch (e) {
      _updateState(_state.copyWith(
        isLoading: false,
        error: _formatError(e),
      ));
      return false;
    }
  }

  /// Effacer l'erreur
  void clearError() {
    _updateState(_state.copyWith(error: null));
  }

  /// Effacer l'analyse
  void clearAnalysis() {
    _updateState(ZPDState());
  }

  /// Formater les erreurs
  String _formatError(dynamic error) {
    final errorString = error.toString();

    if (errorString.contains('404')) {
      return 'Compétence introuvable.';
    }
    if (errorString.contains('400')) {
      return 'Paramètres invalides.';
    }
    if (errorString.contains('timeout') ||
        errorString.contains('TimeoutException')) {
      return 'Temps de réponse dépassé. Réessayez.';
    }

    return 'Erreur: $errorString';
  }
}