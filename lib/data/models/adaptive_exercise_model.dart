class AdaptiveExerciseModel {
  final String id;
  final String type;
  final double difficulty;
  final String question;
  final List<String> options;
  final List<String> hints;
  final int estimatedTime;
  final String? codeTemplate;
  final String? expectedOutput;

  AdaptiveExerciseModel({
    required this.id,
    required this.type,
    required this.difficulty,
    required this.question,
    required this.options,
    required this.hints,
    required this.estimatedTime,
    this.codeTemplate,
    this.expectedOutput,
  });

  factory AdaptiveExerciseModel.fromJson(Map<String, dynamic> json) {
    return AdaptiveExerciseModel(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'qcm',
      difficulty: (json['difficulty'] as num?)?.toDouble() ?? 0.5,
      question: json['question'] as String? ?? '',
      options: json['options'] != null 
          ? (json['options'] as List).map((e) => e is Map ? (e['text'] ?? '').toString() : e.toString()).toList()
          : [],
      hints: json['hints'] != null ? (json['hints'] as List).cast<String>() : [],
      estimatedTime: json['estimated_time'] as int? ?? 60,
      codeTemplate: json['code_template'] as String?,
      expectedOutput: json['expected_output'] as String?,
    );
  }

  String get difficultyPercentage => '${(difficulty * 100).toStringAsFixed(0)}%';

  String get typeFormatted {
    final typeNames = {
      'qcm': 'QCM',
      'qcm_multiple': 'QCM Multiple',
      'vrai_faux': 'Vrai / Faux',
      'traduction': 'Traduction',
      'listening': 'Compréhension Orale',
      'error_correction': 'Correction d\'erreur',
    };
    return typeNames[type] ?? type;
  }

  bool get isQCM => type == 'qcm' || type == 'qcm_multiple' || type == 'vrai_faux';

  bool get isTextInput => 
      type == 'texte_a_trous' || 
      type == 'traduction' || 
      type == 'error_correction' || 
      type == 'listening'; // Si listening attend une réponse texte
}
