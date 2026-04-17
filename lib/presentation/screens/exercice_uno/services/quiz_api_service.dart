// lib/presentation/screens/exercice_uno/services/quiz_api_service.dart
import 'package:dio/dio.dart';
import 'package:front/core/api/dio_factory.dart';
import 'package:front/data/models/exercise_submission.dart';

class QuizApiService {
  static final Dio _dio = DioFactory.createDio();

  static Future<bool> submitQuizResult(ExerciseSubmissionModel submission) async {
    try {
      final response = await _dio.post(
        'responses/submit',
        data: submission.toJson(),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
