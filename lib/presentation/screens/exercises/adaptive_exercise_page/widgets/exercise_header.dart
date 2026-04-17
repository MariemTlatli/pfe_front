import 'package:flutter/material.dart';
import 'package:front/presentation/screens/exercises/adaptive_exercise_page/widgets/timer_widget.dart';

class ExerciseHeader extends StatelessWidget {
  final String typeFormatted;
  final String estimatedTimeFormatted;

  const ExerciseHeader({
    Key? key,
    required this.typeFormatted,
    required this.estimatedTimeFormatted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildPill(
          typeFormatted,
          const Color(0xFF00A2E8).withOpacity(0.2),
          const Color(0xFF00A2E8),
          Icons.category,
        ),
        const SizedBox(width: 8),

        const ExerciseTimerWidget(),
        const SizedBox(width: 8),
        _buildPill(
          "temps estimé : " + estimatedTimeFormatted,
          Colors.white.withOpacity(0.05),
          Colors.white54,
          Icons.timer,
        ),
      ],
    );
  }

  Widget _buildPill(String label, Color bg, Color text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: text.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: text),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: text,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );

  }
}
