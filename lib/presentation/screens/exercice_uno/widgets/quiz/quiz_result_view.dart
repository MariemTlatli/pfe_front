// lib/presentation/screens/exercice_uno/widgets/quiz/quiz_result_view.dart
import 'package:flutter/material.dart';

class QuizResultView extends StatelessWidget {
  final int score;
  final int total;
  final VoidCallback onRestart;

  const QuizResultView({
    super.key,
    required this.score,
    required this.total,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (score / total * 100).toInt();
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildScoreBadge(percentage),
            const SizedBox(height: 32),
            Text(
              percentage >= 70 ? 'Excellent !' : 'Continue tes efforts !',
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu as obtenu $score sur $total bonnes réponses.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 48),
            _buildRestartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBadge(int percentage) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.amber, width: 4),
        boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 20)],
      ),
      child: Center(
        child: Text(
          '$percentage%',
          style: const TextStyle(color: Colors.amber, fontSize: 36, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildRestartButton() {
    return OutlinedButton(
      onPressed: onRestart,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.amber),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: const Text('Recommencer', style: TextStyle(color: Colors.amber, fontSize: 18)),
    );
  }
}
