import 'package:front/data/models/exercise_model.dart';

class AdaptiveExerciseMockData {
  static List<AdaptiveExerciseModel> getMockExercises() {
    return [
      AdaptiveExerciseModel(
        id: '69c9034a9c9b32a1d9fff2a0',
        type: 'vrai_faux',
        question: 'La Terre est plate.',
        options: ['Vrai', 'Faux'],
        hints: ['Pensez aux photos de la NASA et aux voyages spatiaux !'],
        difficulty: 0.2,
        estimatedTime: 30,
      ),
      AdaptiveExerciseModel(
        id: '69c9034a9c9b32a1d9fff2a0',
        type: 'vrai_faux',
        question: 'La Terre est plate.',
        options: ['Vrai', 'Faux'],
        hints: ['Pensez aux photos de la NASA et aux voyages spatiaux !'],
        difficulty: 0.2,
        estimatedTime: 30,
      ),
      AdaptiveExerciseModel(
        id: '69c9034a9c9b32a1d9fff2a0',
        type: 'vrai_faux',
        question: 'La Terre est plate.',
        options: ['Vrai', 'Faux'],
        hints: ['Pensez aux photos de la NASA et aux voyages spatiaux !'],
        difficulty: 0.2,
        estimatedTime: 30,
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
