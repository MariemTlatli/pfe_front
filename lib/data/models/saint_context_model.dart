class SAINTContextModel {
  final double mastery;
  final String zone;
  final double optimalDifficulty;
  final String hintLevel;
  final List<String> recommendedExerciseTypes;
  final String engagement;
  final double pCorrect;

  SAINTContextModel({
    required this.mastery,
    required this.zone,
    required this.optimalDifficulty,
    required this.hintLevel,
    required this.recommendedExerciseTypes,
    required this.engagement,
    required this.pCorrect,
  });

  factory SAINTContextModel.fromJson(Map<String, dynamic> json) {
    final types = <String>[];
    if (json['recommended_exercise_types'] != null) {
      types.addAll((json['recommended_exercise_types'] as List).cast<String>());
    }

    return SAINTContextModel(
      mastery: (json['mastery'] as num?)?.toDouble() ?? 0.0,
      zone: json['zone'] as String? ?? 'zpd',
      optimalDifficulty: (json['optimal_difficulty'] as num?)?.toDouble() ?? 0.5,
      hintLevel: json['hint_level'] as String? ?? 'moyen',
      recommendedExerciseTypes: types,
      engagement: json['engagement'] as String? ?? 'inconnu',
      pCorrect: (json['p_correct'] as num?)?.toDouble() ?? 0.5,
    );
  }

  String get masteryPercentage => '${(mastery * 100).toStringAsFixed(0)}%';
  String get pCorrectPercentage => '${(pCorrect * 100).toStringAsFixed(0)}%';
}
