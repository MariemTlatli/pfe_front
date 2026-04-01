import 'package:flutter/material.dart';

class ResultCard extends StatelessWidget {
  final bool isCorrect;
  final String feedbackMessage;

  const ResultCard({
    Key? key,
    required this.isCorrect,
    required this.feedbackMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isCorrect ? Colors.green : Colors.red),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isCorrect ? 'Bonne réponse ! 🎉' : 'Mauvaise réponse 😕',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isCorrect
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
          if (feedbackMessage.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              feedbackMessage,
              style: TextStyle(
                fontSize: 14,
                color: isCorrect ? Colors.green.shade600 : Colors.red.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
