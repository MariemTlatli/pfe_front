import 'package:flutter/material.dart';

class ExerciseProgressBar extends StatelessWidget {
  final double progress;
  final int currentIndex;
  final int totalExercises;

  const ExerciseProgressBar({
    Key? key,
    required this.progress,
    required this.currentIndex,
    required this.totalExercises,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 4),
          Text(
            'Exercice $currentIndex sur $totalExercises',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
