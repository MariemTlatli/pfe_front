import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:front/core/api/api_consumer.dart';
import 'package:front/data/models/emotion_result.dart';
import 'package:dio/dio.dart';  // ← Doit déjà être présent

/// DataSource pour l'API de détection d'émotions.
/// Suit exactement le pattern de CurriculumRemoteDataSource.
class EmotionRemoteDataSource {
  final ApiConsumer apiConsumer;

  EmotionRemoteDataSource({required this.apiConsumer});

  /// Options avec timeout pour les requêtes d'inférence ML
  Options get _mlOptions => Options(
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        connectTimeout: const Duration(seconds: 10),
        contentType: 'multipart/form-data',
      );

  /// GET - Vérifier si l'API est accessible (health check)
  Future<bool> checkHealth() async {
    try {
      print('🔍 Vérification santé API émotions...');

      final response = await apiConsumer.get(
        'emotions/health',
      );

      final data = response as Map<String, dynamic>;
      final isHealthy = data['status'] == 'ok' && data['model_loaded'] == true;

      print(isHealthy
          ? '✅ API émotions prête'
          : '⚠️ API accessible mais modèle non chargé');

      return isHealthy;
    } catch (e) {
      print('❌ Erreur health check: $e');
      rethrow;
    }
  }

  /// POST - Prédire l'émotion à partir d'une image
  /// Envoie l'image en multipart/form-data avec la clé 'file'
  Future<EmotionResult> predictEmotion({
    required Uint8List imageBytes,
    String filename = 'capture.jpg',
  }) async {
    try {
      print('📤 Envoi image pour prédiction (${imageBytes.length} bytes)...');

      // Créer le FormData comme attendu par Flask
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          imageBytes,
          filename: filename,
          contentType: DioMediaType.parse('image/jpeg'),  // ← Correction ici
        ),
      });

      final response = await apiConsumer.post(
        'emotions/predict',
        data: formData,
        options: _mlOptions,
      );

      print('✅ Prédiction reçue avec succès');

      return EmotionResult.fromJson(
        response as Map<String, dynamic>,
      );
    } catch (e) {
      print('❌ Erreur prédiction émotion: $e');
      rethrow;
    }
  }
}