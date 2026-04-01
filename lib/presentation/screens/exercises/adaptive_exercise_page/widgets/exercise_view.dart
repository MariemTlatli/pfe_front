import 'package:flutter/material.dart';
import 'package:front/data/models/exercise_model.dart';
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExerciseHeader(
            typeFormatted: exercise.typeFormatted,
            estimatedTimeFormatted: exercise.estimatedTimeFormatted,
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          HintsSection(
            hints: exercise.hints,
            initialHintsShown: controller.hintsShown,
            onHintShown: (val) => controller.incrementHint(val),
          ),
          const SizedBox(height: 24),
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
