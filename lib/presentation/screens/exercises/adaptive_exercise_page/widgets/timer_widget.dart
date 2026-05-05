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

        // Couleurs dynamiques selon l'état du timer (style UnoCard rouge)
        final colorBase = isLow
            ? const Color.fromARGB(255, 228, 1, 1) // Rouge foncé base (alarme)
            : const Color.fromARGB(
                255,
                191,
                26,
                26,
              ); // Rouge foncé base (normal)

        final gradientTop = isLow
            ? const Color.fromARGB(
                255,
                255,
                0,
                0,
              ) // Rouge très clair haut (alarme)
            : const Color.fromARGB(
                255,
                255,
                0,
                25,
              ); // Rouge clair haut (normal)

        final gradientBottom = isLow
            ? const Color.fromARGB(255, 236, 37, 37) // Rouge moyen bas (alarme)
            : const Color.fromARGB(
                255,
                230,
                67,
                67,
              ); // Rouge moyen bas (normal)

        final colorText = const Color.fromARGB(
          255,
          255,
          255,
          255,
        ); // Texte rouge très foncé
        final borderColor = isLow ? const Color(0xFFFFF0F0) : Colors.white;

        return Container(
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            // Partie "3D" du bas (comme UnoCard)
            color: colorBase,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Container(
            // Marge inférieure pour révéler la partie 3D (pattern UnoCard)
            margin: const EdgeInsets.only(bottom: 5),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ), // ← Augmente de 16 à 24 ou plus

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              // Gradient vertical comme UnoCard (mais en rouge)
              gradient: LinearGradient(
                colors: [gradientTop, gradientBottom],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border.all(
                color: borderColor, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timer_outlined, size: 20, color: colorText),
                const SizedBox(width: 8),
                Text(
                  _formatTime(remaining),
                  style: TextStyle(
                    color: colorText,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    fontFamily: 'monospace',
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
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
