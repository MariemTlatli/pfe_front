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
      children: exercise.options.asMap().entries.map((entry) {
        final option = entry.value;
        final index = entry.key;
        final isSelected = selectedAnswer == option;
        final unoColors = [Color(0xFFEB1C24), Color(0xFF00A2E8), Color(0xFF22B14C), Color(0xFFFFF200)];
        final accentColor = unoColors[index % unoColors.length];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: showResult ? null : () => onSingleAnswerSelected(option),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isSelected 
                    ? accentColor.withOpacity(0.2) 
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? accentColor : Colors.white.withOpacity(0.1),
                  width: isSelected ? 2.5 : 1,
                ),
              ),
              child: Row(
                children: [
                   Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: isSelected ? accentColor : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: isSelected ? accentColor : Colors.white24, width: 2),
                    ),
                    child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.black) : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
          'SÉLECTION MULTIPLE',
          style: TextStyle(fontSize: 12, color: Colors.white38, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const SizedBox(height: 12),
        ...exercise.options.asMap().entries.map((entry) {
          final option = entry.value;
          final index = entry.key;
          final isSelected = selectedMultipleAnswers.contains(option);
          final unoColors = [Color(0xFF00A2E8), Color(0xFF22B14C), Color(0xFFFFF200), Color(0xFFEB1C24)];
          final accentColor = unoColors[index % unoColors.length];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: showResult
                  ? null
                  : () {
                      final newList = List<String>.from(selectedMultipleAnswers);
                      if (isSelected) newList.remove(option); else newList.add(option);
                      onMultipleAnswersSelected(newList);
                    },
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isSelected ? accentColor.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? accentColor : Colors.white.withOpacity(0.1),
                    width: isSelected ? 2.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        color: isSelected ? accentColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: isSelected ? accentColor : Colors.white24, width: 2),
                      ),
                      child: isSelected ? const Icon(Icons.check, size: 18, color: Colors.black) : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
