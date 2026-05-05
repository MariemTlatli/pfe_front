class ExerciseCompetenceModel {
  final String id;
  final String name;
  final String description;

  ExerciseCompetenceModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory ExerciseCompetenceModel.fromJson(Map<String, dynamic> json) {
    return ExerciseCompetenceModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}
