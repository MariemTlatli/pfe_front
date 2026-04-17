import 'package:flutter/material.dart';
import 'package:front/presentation/screens/exercice_uno/widgets/mascot_dialog.dart';
import 'package:front/presentation/screens/home/success_secreen.dart';
import '../adaptive_exercise_controller.dart';
import '../dialogs/adaptation_dialog.dart';

class AdaptiveDecisionUtils {
  static void showDecisionDialog({
    required BuildContext context,
    required DecisionEvent event,
    required AdaptiveExerciseController controller,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        if (event.actionType == DecisionActionType.takeBreak) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            title: const Text('Pause recommandée', style: TextStyle(color: Colors.white)),
            content: Text(event.message, style: const TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Continuer', style: TextStyle(color: Colors.amber)),
              ),
            ],
          );
        } else if (event.actionType == DecisionActionType.nextCompetence) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            title: const Text('Bravo ! 🎉', style: TextStyle(color: Colors.white)),
            content: Text(event.message, style: const TextStyle(color: Colors.white70)),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('Terminer'),
              ),
            ],
          );
        } else if (event.actionType == DecisionActionType.timeOut) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.redAccent),
            ),
            title: const Row(
              children: [
                Icon(Icons.timer_off, color: Colors.redAccent),
                SizedBox(width: 10),
                Text('Temps écoulé !', style: TextStyle(color: Colors.white)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "L'exercice est considéré comme raté.",
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // On affiche directement la vidéo ici pour un effet "intégré"
                SizedBox(
                  height: 180,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: const MascotVideo(videoPath: "assets/temps_ecoulee.mp4"),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  event.encouragement,
                  style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () {
                  Navigator.pop(ctx);
                  controller.nextExercise();
                },
                child: const Text('Passer au suivant', style: TextStyle(color: Colors.white)),
              ),
            ],
          );

        } else {

          return AdaptationDialog(
            title: 'Adaptation',
            message: event.message,
            encouragement: event.encouragement,
            onContinue: () => controller.nextExercise(),
          );
        }
      },
    );
  }
}
