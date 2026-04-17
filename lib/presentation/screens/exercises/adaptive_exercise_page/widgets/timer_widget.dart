import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../adaptive_exercise_controller.dart';

class ExerciseTimerWidget extends StatelessWidget {
  const ExerciseTimerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AdaptiveExerciseController>(
      builder: (context, controller, _) {
        final remaining = controller.remainingSeconds;
        final isLow = remaining < 10;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isLow ? Colors.red.withOpacity(0.2) : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isLow ? Colors.redAccent : Colors.white24,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer,
                size: 18,
                color: isLow ? Colors.redAccent : Colors.white70,
              ),
              const SizedBox(width: 8),
              Text(
                _formatTime(remaining),
                style: TextStyle(
                  color: isLow ? Colors.redAccent : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
