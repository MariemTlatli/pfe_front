import 'package:flutter/material.dart';
import 'package:front/presentation/screens/exercice_uno/widgets/bleu_btn.dart';
import 'package:front/presentation/widgets/uno_button.dart';

class ExerciseActionButtons extends StatelessWidget {
  final bool canGoPrevious;
  final bool showResult;
  final bool isSubmitting;
  final bool hasAnswer;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onValidate;
  final bool isLastExercise;

  const ExerciseActionButtons({
    Key? key,
    required this.canGoPrevious,
    required this.showResult,
    required this.isSubmitting,
    required this.hasAnswer,
    required this.onPrevious,
    required this.onNext,
    required this.onValidate,
    required this.isLastExercise,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        children: [
          if (canGoPrevious && !showResult) ...[
            Expanded(
              child: BleuBtn(label: "Retour", onPressed: onPrevious)
              
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: showResult ? _buildNextButton() : _buildValidateButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return BleuBtn(
      label: isLastExercise ? 'TERMINER' : 'SUIVANT',
      onPressed: onNext,
    );

    // 
  }

  Widget _buildValidateButton() {
    bool canPress = hasAnswer && !isSubmitting;
    return UnoButton(
      label: isSubmitting ? 'VÉRIFICATION...' : 'VALIDER',
      isLoading: isSubmitting,
      isEnabled: canPress,
      onPressed: canPress ? onValidate : null,
    );

    
  }

}
