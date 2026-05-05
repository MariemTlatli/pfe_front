import 'exercise_competence_model.dart';
import 'adaptive_exercise_model.dart';
import 'exercise_detail_model.dart';
import 'saint_context_model.dart';

class AdaptiveExercisesResponseModel {
  final ExerciseCompetenceModel competence;
  final String competenceId;
  final List<AdaptiveExerciseModel> exercises;
  final List<ExerciseDetailModel> details;
  final List<String> lessonTitles;
  final SAINTContextModel saintContext;
  final int lessonsCount, requested, generated, errors;
  final String message;

  AdaptiveExercisesResponseModel({
    required this.competence, required this.competenceId,
    required this.exercises, required this.details,
    required this.lessonTitles, required this.saintContext,
    required this.lessonsCount, required this.requested,
    required this.generated, required this.errors,
    required this.message,
  });

  factory AdaptiveExercisesResponseModel.fromJson(Map<String, dynamic> json) {
    return AdaptiveExercisesResponseModel(
      competence: ExerciseCompetenceModel.fromJson(json['competence'] ?? {}),
      competenceId: json['competence_id'] ?? '',
      exercises: (json['exercises'] as List? ?? []).map((e) => AdaptiveExerciseModel.fromJson(e)).toList(),
      details: (json['details'] as List? ?? []).map((e) => ExerciseDetailModel.fromJson(e)).toList(),
      lessonTitles: (json['lesson_titles'] as List? ?? []).cast<String>(),
      saintContext: SAINTContextModel.fromJson(json['saint_context'] ?? {}),
      lessonsCount: json['lessons_count'] ?? 0,
      requested: json['requested'] ?? 0,
      generated: json['generated'] ?? 0,
      errors: json['errors'] ?? 0,
      message: json['message'] ?? '',
    );
  }

  bool get allGenerated => generated == requested && errors == 0;
  AdaptiveExerciseModel? getExercise(int index) => (index >= 0 && index < exercises.length) ? exercises[index] : null;
}
