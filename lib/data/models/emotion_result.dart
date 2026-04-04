import 'package:flutter/material.dart';

/// Modèle pour la réponse de l'API de prédiction d'émotions.
/// Suit le pattern de tes autres modèles (fromJson, typage fort).
class EmotionResult {
  final String emotion;
  final double confidence;
  final Map<String, double> allProbabilities;

  EmotionResult({
    required this.emotion,
    required this.confidence,
    required this.allProbabilities,
  });

  /// Factory pour parser le JSON venant de Flask
  factory EmotionResult.fromJson(Map<String, dynamic> json) {
    final probs = (json['all_probabilities'] as Map<String, dynamic>?)
        ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ?? {};

    return EmotionResult(
      emotion: json['emotion'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      allProbabilities: probs,
    );
  }

  /// Emoji associé à l'émotion (pratique pour l'UI)
  String get emoji {
    const map = {
      'angry': '😠',
      'disgust': '🤢',
      'fear': '😨',
      'happy': '😊',
      'neutral': '😐',
      'sad': '😢',
      'surprise': '😲',
    };
    return map[emotion.toLowerCase()] ?? '😐';
  }

  /// Couleur associée (optionnel, pour le design)
  // ignore: avoid_positional_boolean_parameters
  Color get color {
    const map = {
      'angry': Color(0xFFE57373),
      'disgust': Color(0xFF81C784),
      'fear': Color(0xFF9575CD),
      'happy': Color(0xFFFFD54F),
      'neutral': Color(0xFFBDBDBD),
      'sad': Color(0xFF64B5F6),
      'surprise': Color(0xFFFFB74D),
    };
    return map[emotion.toLowerCase()] ?? const Color(0xFFBDBDBD);
  }

  @override
  String toString() => 'EmotionResult(emotion: $emotion, confidence: $confidence)';
}