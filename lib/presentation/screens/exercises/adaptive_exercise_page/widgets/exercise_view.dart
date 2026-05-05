import 'package:flutter/material.dart';
import 'package:front/data/models/exercise_model.dart';
import 'package:front/presentation/screens/exercice_uno/services/quiz_controller.dart';
import 'package:front/presentation/screens/exercice_uno/widgets/quiz/target_selector_dialog.dart';
import 'package:front/presentation/screens/exercice_uno/widgets/quiz/uno_card_hand.dart';
import 'package:front/presentation/screens/exercises/adaptive_exercise_page/widgets/exercice_hints.dart';
import 'package:front/presentation/screens/exercises/adaptive_exercise_page/widgets/uno_hand_wrapper.dart';
import 'package:provider/provider.dart';
import '../adaptive_exercise_controller.dart';
import 'exercise_header.dart';
import 'question_card.dart';
import 'answer_options.dart';
import 'hints_section.dart';
import 'result_card.dart';

class ExerciseView extends StatelessWidget {
  final AdaptiveExerciseModel exercise;
  final AdaptiveExerciseController controller;

  const ExerciseView({
    Key? key,
    required this.exercise,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final quizController = context.watch<QuizController>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExerciseHeader(
            typeFormatted: exercise.typeFormatted,
            estimatedTimeFormatted: exercise.estimatedTime.toString(),
          ),
          const SizedBox(height: 15),
          QuestionCard(question: exercise.question),
          const SizedBox(height: 24),
          AnswerOptions(
            exercise: exercise,
            selectedAnswer: controller.selectedAnswer,
            selectedMultipleAnswers: controller.selectedMultipleAnswers,
            showResult: controller.showResult,
            onSingleAnswerSelected: controller.selectSingleAnswer,
            onMultipleAnswersSelected: controller.updateMultipleAnswers,
            onTextChanged: controller.updateTextAnswer,
          ),
          // --- GESTION DES INDICES ---
          const SizedBox(height: 16),
          // Si on a utilisé une carte +4 (Indices Premium IA)
          if (quizController.plus4Hints.isNotEmpty)
            buildHintsPanel(quizController.plus4Hints)
          else if (exercise.hints.isNotEmpty)
            // Sinon on affiche les indices standards de l'exercice
            HintsSection(
              hints: exercise.hints,
              initialHintsShown: controller.hintsShown,
              onHintShown: (val) => controller.incrementHint(val),
            ),

          const SizedBox(height: 24),


          UnoHandWrapper(
            quizController: quizController,
            exerciseId: exercise.id,
            adaptiveController: controller,
          ),
          if (controller.showResult)
            ResultCard(
              isCorrect: controller.isCorrect,
              feedbackMessage: controller.feedbackMessage,
            ),
        ],
      ),
    );
  }
}
