// lib/providers/emotion_provider.dart

import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:front/data/data_sources/emotion_remote_data_source.dart';
import 'package:front/data/models/emotion_result.dart';
import 'package:front/data/models/exercise_model.dart';
import 'package:front/data/models/exercise_submission.dart';

/// Provider pour la gestion de l'état de détection d'émotions.
class EmotionProvider extends ChangeNotifier {
  final EmotionRemoteDataSource _dataSource;

  EmotionProvider({required EmotionRemoteDataSource dataSource})
    : _dataSource = dataSource;

  // ── État ──────────────────────────────────────
  EmotionResult? _currentEmotion;
  bool _isLoading = false;
  bool _isApiHealthy = false;
  String? _errorMessage;
  DateTime? _lastPredictionTime;

  // ── BUFFER DE CAPTURES ─────────────────────────
  final List<EmotionCaptureModel> _captures = []; // ← EmotionCaptureModel
  static const int _maxCaptures = 10;

  // ── Getters ───────────────────────────────────
  EmotionResult? get currentEmotion => _currentEmotion;
  bool get isLoading => _isLoading;
  bool get isApiHealthy => _isApiHealthy;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  DateTime? get lastPredictionTime => _lastPredictionTime;

  /// Liste des captures (lecture seule)
  List<EmotionCaptureModel> get captures =>
      List.unmodifiable(_captures); // ← Model

  /// Vérifie si une nouvelle prédiction est nécessaire
  bool get shouldPredictAgain {
    if (_lastPredictionTime == null) return true;
    return DateTime.now().difference(_lastPredictionTime!).inSeconds >= 5;
  }

  /// Retourne l'émotion dominante (la plus fréquente)
  EmotionCaptureModel? get dominantCapture {
    if (_captures.isEmpty) return null;

    final counts = <String, int>{};
    for (final capture in _captures) {
      counts[capture.emotion] = (counts[capture.emotion] ?? 0) + 1;
    }

    final dominant = counts.entries.reduce((a, b) => a.value > b.value ? a : b);

    final lastDominant = _captures.reversed.firstWhere(
      (c) => c.emotion == dominant.key,
      orElse: () => _captures.last,
    );

    return lastDominant;
  }

  /// Calcule la confiance moyenne
  double get averageConfidence {
    if (_captures.isEmpty) return 0.0;
    final total = _captures.fold(0.0, (sum, c) => sum + c.confidence);
    return total / _captures.length;
  }

  /// Détecte la frustration
  bool get isFrustrationDetected {
    return _captures.any(
      (c) => [
        'fear',
        'angry',
        'sad',
        'frustrated',
      ].contains(c.emotion.toLowerCase()),
    );
  }

  // ── Actions sur le buffer ─────────────────────

  /// Ajoute une capture au buffer
  void addCapture(EmotionCaptureModel capture) {
    // ← Model
    _captures.add(capture);

    // Limite FIFO
    if (_captures.length > _maxCaptures) {
      _captures.removeAt(0);
    }

    notifyListeners();
  }

  /// Ajoute une capture depuis un EmotionResult
  void addCaptureFromResult(EmotionResult result) {
    addCapture(
      EmotionCaptureModel(
        // ← Model
        emotion: result.emotion,
        confidence: result.confidence,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Vide le buffer
  void clearCaptures() {
    _captures.clear();
    notifyListeners();
  }

  /// ✨ NOUVELLE MÉTHODE : Prépare les données pour la soumission
  EmotionDataModel prepareEmotionSubmissionData() {
    // Si aucune capture, retourner des données neutres
    if (_captures.isEmpty) {
      return EmotionDataModel.neutral();
    }

    // Calculer l'émotion dominante
    final dominantCap = dominantCapture!;

    // Calculer la confiance moyenne
    final avgConf = averageConfidence;

    // Détecter la frustration
    final hasFrustration = isFrustrationDetected;

    return EmotionDataModel(
      dominantEmotion: dominantCap.emotion,
      confidence: dominantCap.confidence,
      emotionHistory: List.from(_captures), // Copie du buffer
      frustrationDetected: hasFrustration,
      averageConfidence: avgConf,
    );
  }

  // ── Actions API ───────────────────────────────

  /// Vérifie la santé de l'API
  Future<void> checkApiHealth() async {
    try {
      print('🔍 Vérification santé API émotions...');
      _isApiHealthy = await _dataSource.checkHealth();
      print(_isApiHealthy ? '✅ API prête' : '⚠️ API non prête');
      notifyListeners();
    } catch (e) {
      _isApiHealthy = false;
      _errorMessage = 'API inaccessible';
      print('❌ Erreur health check: $e');
      notifyListeners();
    }
  }

  /// Prédit l'émotion à partir d'une image
  Future<void> predictEmotion({required Uint8List imageBytes}) async {
    if (!_isApiHealthy) {
      _errorMessage = 'API non disponible';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('📤 Envoi image pour prédiction...');
      final result = await _dataSource.predictEmotion(imageBytes: imageBytes);

      _currentEmotion = result;
      _lastPredictionTime = DateTime.now();
      _isLoading = false;

      print(
        '✅ Émotion détectée: ${result.emoji} ${result.emotion} (${result.confidence.toStringAsFixed(2)})',
      );
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erreur: ${e.toString()}';
      print('❌ Erreur prédiction: $e');
      notifyListeners();
    }
  }

  /// Réinitialise l'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Réinitialise l'émotion courante ET le buffer
  void clearEmotion() {
    _currentEmotion = null;
    _lastPredictionTime = null;
    clearCaptures();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
