import 'package:flutter/material.dart';

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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (canGoPrevious && !showResult) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPrevious,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Précédent'),
              ),
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
    return ElevatedButton.icon(
      onPressed: onNext,
      icon: Icon(isLastExercise ? Icons.check : Icons.arrow_forward),
      label: Text(isLastExercise ? 'Terminer' : 'Suivant'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildValidateButton() {
    return ElevatedButton.icon(
      onPressed: hasAnswer && !isSubmitting ? onValidate : null,
      icon: isSubmitting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.check),
      label: Text(isSubmitting ? 'Envoi...' : 'Valider'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        disabledBackgroundColor: Colors.grey.shade400,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
