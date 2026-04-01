import 'package:flutter/material.dart';
import 'package:front/data/models/exercise_model.dart';

class AnswerOptions extends StatelessWidget {
  final AdaptiveExerciseModel exercise;
  final String? selectedAnswer;
  final List<String> selectedMultipleAnswers;
  final bool showResult;
  final Function(String) onSingleAnswerSelected;
  final Function(List<String>) onMultipleAnswersSelected;
  final Function(String) onTextChanged;

  const AnswerOptions({
    Key? key,
    required this.exercise,
    this.selectedAnswer,
    this.selectedMultipleAnswers = const [],
    this.showResult = false,
    required this.onSingleAnswerSelected,
    required this.onMultipleAnswersSelected,
    required this.onTextChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (exercise.type == 'qcm_multiple') {
      return _buildMultipleChoiceOptions();
    } else if (exercise.isQCM) {
      return _buildSingleChoiceOptions();
    } else if (exercise.type == 'texte_a_trous') {
      return _buildTextInput();
    } else if (exercise.isCodeExercise) {
      return _buildCodeEditor();
    }

    return const SizedBox.shrink();
  }

  Widget _buildSingleChoiceOptions() {
    return Column(
      children: exercise.options.map((option) {
        final isSelected = selectedAnswer == option;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: showResult ? null : () => onSingleAnswerSelected(option),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: isSelected ? Colors.blue : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultipleChoiceOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sélectionnez plusieurs réponses :',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        ...exercise.options.map((option) {
          final isSelected = selectedMultipleAnswers.contains(option);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: showResult
                  ? null
                  : () {
                      final newList = List<String>.from(selectedMultipleAnswers);
                      if (isSelected) {
                        newList.remove(option);
                      } else {
                        newList.add(option);
                      }
                      onMultipleAnswersSelected(newList);
                    },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.shade50 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                      color: isSelected ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTextInput() {
    return TextField(
      enabled: !showResult,
      onChanged: onTextChanged,
      decoration: InputDecoration(
        hintText: 'Entrez votre réponse...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      maxLines: 3,
    );
  }

  Widget _buildCodeEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (exercise.codeTemplate != null && exercise.codeTemplate!.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              exercise.codeTemplate!,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: Colors.greenAccent,
              ),
            ),
          ),
        const SizedBox(height: 12),
        TextField(
          enabled: !showResult,
          onChanged: onTextChanged,
          decoration: InputDecoration(
            hintText: 'Écrivez votre code ici...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
          maxLines: 8,
          style: const TextStyle(fontFamily: 'monospace'),
        ),
      ],
    );
  }
}
