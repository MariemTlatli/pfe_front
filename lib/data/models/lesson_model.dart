class LessonModel {
  final String id;
  final String competenceId;
  final String title;
  final String content;
  final int order;
  final int? estimatedTime;
  final DateTime? createdAt;

  LessonModel({
    required this.id,
    required this.competenceId,
    required this.title,
    required this.content,
    required this.order,
    this.estimatedTime,
    this.createdAt,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      competenceId: json['competence_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      order: json['order'] as int? ?? 1,
      estimatedTime: json['estimated_time'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'competence_id': competenceId,
      'title': title,
      'content': content,
      'order': order,
      'estimated_time': estimatedTime,
      'created_at': createdAt?.toIso8601String(),
    };
  }


}
  // =============================================================================
// LESSON RESPONSE MODELS
// Modèles pour la réponse des leçons (GET et POST)
// =============================================================================


/// Compétence simplifiée (dans la réponse des leçons)
class LessonCompetenceModel {
  final String id;
  final String code;
  final String name;
  final String description;
  final int level;

  LessonCompetenceModel({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.level,
  });

  factory LessonCompetenceModel.fromJson(Map<String, dynamic> json) {
    return LessonCompetenceModel(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      level: json['level'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'level': level,
    };
  }
}

/// Réponse complète des leçons (GET et POST)
class LessonsResponseModel {
  final LessonCompetenceModel competence;
  final List<LessonModel> lessons;
  final int count;
  final bool hasLessons;

  LessonsResponseModel({
    required this.competence,
    required this.lessons,
    required this.count,
    required this.hasLessons,
  });

  factory LessonsResponseModel.fromJson(Map<String, dynamic> json) {
    // Parser la compétence
    final competence = LessonCompetenceModel.fromJson(
      json['competence'] as Map<String, dynamic>? ?? {},
    );

    // Parser les leçons
    final lessonsList = <LessonModel>[];
    if (json['lessons'] != null) {
      for (final lesson in json['lessons'] as List) {
        lessonsList.add(
          LessonModel.fromJson(lesson as Map<String, dynamic>),
        );
      }
    }

    // Trier par ordre
    lessonsList.sort((a, b) => a.order.compareTo(b.order));

    return LessonsResponseModel(
      competence: competence,
      lessons: lessonsList,
      count: json['count'] as int? ?? lessonsList.length,
      hasLessons: json['has_lessons'] as bool? ?? lessonsList.isNotEmpty,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'competence': competence.toJson(),
      'lessons': lessons.map((l) => l.toJson()).toList(),
      'count': count,
      'has_lessons': hasLessons,
    };
  }

  /// Temps total estimé pour toutes les leçons
  int get totalEstimatedTime =>
      lessons.fold(0, (sum, lesson) => sum + (lesson.estimatedTime ?? 0));

  /// Temps total formaté (ex: "1h 15min")
  String get totalEstimatedTimeFormatted {
    final total = totalEstimatedTime;
    if (total >= 60) {
      final hours = total ~/ 60;
      final minutes = total % 60;
      return minutes > 0 ? '${hours}h ${minutes}min' : '${hours}h';
    }
    return '${total}min';
  }

  /// Récupérer une leçon par son ordre
  LessonModel? getLessonByOrder(int order) {
    try {
      return lessons.firstWhere((l) => l.order == order);
    } catch (_) {
      return null;
    }
  }

  /// Récupérer la première leçon
  LessonModel? get firstLesson => lessons.isNotEmpty ? lessons.first : null;

  /// Récupérer la dernière leçon
  LessonModel? get lastLesson => lessons.isNotEmpty ? lessons.last : null;
}