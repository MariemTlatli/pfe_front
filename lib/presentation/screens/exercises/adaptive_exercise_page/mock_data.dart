import 'package:front/data/models/exercise_model.dart';

class AdaptiveExerciseMockData {
  static List<AdaptiveExerciseModel> getMockExercises() {
    return [
      AdaptiveExerciseModel(
        id: 'ex_easy',
        type: 'vrai_faux',
        question: 'La Terre est ronde.',
        options: ['Vrai', 'Faux'],
        hints: ['Pensez aux globe-terrestres.'],
        difficulty: 0.2,
        estimatedTime: 30,
      ),
      AdaptiveExerciseModel(
        id: 'ex_medium',
        type: 'choix_multiple',
        question: 'Quelle est la capitale de la France ?',
        options: ['Paris', 'Londres', 'Berlin', 'Madrid'],
        hints: ['La ville lumière.'],
        difficulty: 0.5,
        estimatedTime: 45,
      ),
      AdaptiveExerciseModel(
        id: 'ex_hard',
        type: 'vrai_faux',
        question: 'Le zéro absolu est de 0°C.',
        options: ['Vrai', 'Faux'],
        hints: ['C\'est en Kelvin.'],
        difficulty: 0.8, // DIFFICULTÉ ÉLEVÉE POUR LE BONUS +2
        estimatedTime: 60,
      ),
    ];
  }

  static Map<String, dynamic> getMockSuccessDecision() {
    return {
      'is_correct': true,
      'decision': {
        'status': 'success',
        'response_type': 'next_exercise',
        'message': 'Excellent travail ! Tu maîtrises bien ce concept.',
        'encouragement': 'Continue comme ça, tu es sur la bonne voie !',
        'ui': {
          'auto_proceed': true,
          'delay_seconds': 3,
          'show_hint': false,
        },
        'next_step': {
          'action': 'next_exercise',
          'difficulty': 0.6,
        }
      }
    };
  }
}

final Map<String, dynamic> mockAdaptiveExercisesJson = {
  "competence": {
    "id": "comp_001",
    "name": "Programmation Orientée Objet",
    "description":
        "Comprendre les principes de l'héritage, du polymorphisme et de l'encapsulation.",
  },
  "competence_id": "comp_001",
  "exercises": [
    {
      "id": "ex_qcm_01",
      "type": "qcm",
      "difficulty": 0.4,
      "question":
          "Quel mot-clé est utilisé pour hériter d'une classe en Dart ?",
      "options": ["extends", "implements", "inherits", "super"],
      "hints": [
        "Pensez à la syntaxe standard de l'héritage.",
        "Cela commence par la lettre 'e'.",
      ],
      "estimated_time": 30,
    },
    {
      "id": "ex_trad_02",
      "type": "traduction",
      "difficulty": 0.75,
      "question":
          "Traduisez ce pseudo-code en Dart : 'Si x est supérieur à 10, imprimez \"Grand\", sinon \"Petit\"'.",
      "options": [], // Peut rester vide pour les exercices à saisie libre
      "hints": [
        "Utilisez une instruction if-else.",
        "N'oubliez pas les accolades pour délimiter le bloc.",
      ],
      "estimated_time": 120,
      "code_template":
          "void main() {\n  int x = 15;\n  // Écrivez votre code ici\n}",
      "expected_output": "Grand",
    },
  ],
  "details": [
    {"id": "ex_qcm_01", "status": "generated", "type": "qcm"},
    {"id": "ex_trad_02", "status": "generated", "type": "traduction"},
  ],
  "lesson_titles": [
    "Introduction aux Classes",
    "Héritage et Polymorphisme",
    "Bonnes Pratiques POO",
  ],
  "saint_context": {
    "mastery": 0.68,
    "zone": "zpd",
    "optimal_difficulty": 0.60,
    "hint_level": "moyen",
    "recommended_exercise_types": ["qcm", "traduction", "error_correction"],
    "engagement": "élevé",
    "p_correct": 0.74,
  },
  "lessons_count": 3,
  "requested": 2,
  "generated": 2,
  "errors": 0,
  "message": "2 exercices générés avec succès pour la compétence sélectionnée.",
};
