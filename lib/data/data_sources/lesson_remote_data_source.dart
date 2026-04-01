import 'package:dio/dio.dart';
import 'package:front/core/api/api_consumer.dart';
import 'package:front/data/models/lesson_model.dart';

/// Data Source pour la génération et récupération des leçons
class LessonRemoteDataSource {
  final ApiConsumer apiConsumer;

  LessonRemoteDataSource({required this.apiConsumer});

  /// Options avec timeout long pour les opérations LLM (génération IA)
  Options get _llmOptions => Options(
        receiveTimeout: const Duration(minutes: 30),
        sendTimeout: const Duration(minutes: 30),
        connectTimeout: const Duration(minutes: 30),

      );

  /// GET - Récupérer les leçons existantes d'une compétence
  Future<LessonsResponseModel> getLessons({
    required String competenceId,
  }) async {
    try {
      print('📥 Récupération des leçons pour $competenceId...');

      final response = await apiConsumer.get(
        'lessons/competence/$competenceId',
      );

      print('✅ Leçons récupérées avec succès');

      return LessonsResponseModel.fromJson(
        response as Map<String, dynamic>,
      );
    } catch (e) {
      print('❌ Erreur récupération leçons: $e');
      rethrow;
    }
  }

  /// POST - Générer les leçons pour une compétence via Ollama
  Future<LessonsResponseModel> generateLessons({
    required String competenceId,
  }) async {
    try {
      print('🚀 Génération des leçons pour $competenceId...');

      final response = await apiConsumer.post(
        'lessons/generate/$competenceId',
        options: _llmOptions,
      );

      print('✅ Leçons générées avec succès');

      return LessonsResponseModel.fromJson(
        response as Map<String, dynamic>,
      );
    } catch (e) {
      print('❌ Erreur génération leçons: $e');
      rethrow;
    }
  }
}