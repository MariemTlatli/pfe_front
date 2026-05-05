import 'package:flutter/material.dart';
import 'package:front/data/models/exercise_model.dart';
import 'answer_options/single_choice_view.dart';
import 'answer_options/multiple_choice_view.dart';
import 'answer_options/text_input_view.dart';

class AnswerOptions extends StatelessWidget {
  final AdaptiveExerciseModel exercise;
  final String? selectedAnswer;
  final List<String> selectedMultipleAnswers;
  final bool showResult;
  final Function(String) onSingleAnswerSelected;
  final Function(List<String>) onMultipleAnswersSelected;
  final Function(String) onTextChanged;

  const AnswerOptions({
    super.key, required this.exercise, this.selectedAnswer,
    this.selectedMultipleAnswers = const [], this.showResult = false,
    required this.onSingleAnswerSelected,
    required this.onMultipleAnswersSelected,
    required this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (exercise.type == 'qcm_multiple') {
      return MultipleChoiceView(
        options: exercise.options, 
        selectedAnswers: selectedMultipleAnswers, 
        showResult: showResult, 
        onSelected: onMultipleAnswersSelected
      );
    } else if (exercise.isQCM) {
      return SingleChoiceView(
        options: exercise.options, 
        selectedAnswer: selectedAnswer, 
        showResult: showResult, 
        onSelected: onSingleAnswerSelected
      );
    } else if (exercise.isTextInput) {
      return TextInputView(
        showResult: showResult, 
        onChanged: onTextChanged, 
        hintText: _getHintText()
      );
    }
    return const SizedBox.shrink();
  }

  String _getHintText() {
    if (exercise.type == 'traduction') return 'Écrivez la traduction ici...';
    if (exercise.type == 'error_correction') return 'Écrivez la phrase corrigée ici...';
    return 'Entrez votre réponse...';
  }
}
