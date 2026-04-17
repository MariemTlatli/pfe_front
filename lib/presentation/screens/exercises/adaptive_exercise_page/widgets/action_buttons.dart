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
              child: TextButton.icon(
                onPressed: onPrevious,
                icon: const Icon(Icons.arrow_back, color: Colors.white54),
                label: const Text(
                  'Retour',
                  style: TextStyle(color: Colors.white54),
                ),
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF00A2E8), Color(0xFF22B14C)],
        ),
      ),
      child: ElevatedButton.icon(
        onPressed: onNext,
        icon: Icon(
          isLastExercise ? Icons.done_all : Icons.arrow_forward,
          color: Colors.white,
        ),
        label: Text(
          isLastExercise ? 'TERMINER' : 'SUIVANT',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildValidateButton() {
    bool canPress = hasAnswer && !isSubmitting;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: canPress
            ? const LinearGradient(
                colors: [Color(0xFFEB1C24), Color(0xFF00A2E8)],
              )
            : null,
        color: !canPress ? Colors.white10 : null,
      ),
      child: ElevatedButton.icon(
        onPressed: canPress ? onValidate : null,
        icon: isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.check_circle_outline, color: Colors.white),
        label: Text(
          isSubmitting ? 'VÉRIFICATION...' : 'VALIDER',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          disabledForegroundColor: Colors.white24,
        ),
      ),
    );
  }

}
