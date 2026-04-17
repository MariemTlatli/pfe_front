import 'package:flutter/material.dart';
import 'package:front/presentation/screens/exercice_uno/services/quiz_controller.dart';
import 'package:front/presentation/screens/exercice_uno/widgets/mascot_dialog.dart';
import 'package:front/presentation/screens/exercice_uno/widgets/quiz/target_selector_dialog.dart';
import 'package:front/presentation/screens/exercice_uno/widgets/quiz/uno_card_hand.dart';

import '../adaptive_exercise_controller.dart';

class UnoHandWrapper extends StatelessWidget {
  final QuizController quizController;
  final String exerciseId;
  final AdaptiveExerciseController adaptiveController;

  const UnoHandWrapper({
    Key? key,
    required this.quizController,
    required this.exerciseId,
    required this.adaptiveController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: UnoCardHand(
        status: quizController.specialCards,
        onUse: (type) async {
          if (type == 'plus2') {
            final targets = await quizController.getPotentialTargets();
            if (targets.isEmpty) return;
            
            final String? targetId = await showDialog<String>(
              context: context,
              builder: (ctx) => TargetSelectorDialog(targets: targets),
            );
            
            if (targetId != null) {
              final err = await quizController.useSpecialCard('plus2', targetId: targetId);
              _handleResult(context, err, "🚀 Attaque +2 envoyée !");
            }
          } else {
            final err = await quizController.useSpecialCard(type, exerciseId: exerciseId);
            if (err == null) {              
              String successMsg = "Carte utilisée !";
              if (type == 'skip') {
                successMsg = "⏭️ Question sautée !";
                adaptiveController.nextExercise();
              }
              if (type == 'joker') successMsg = "🃏 Difficulté ajustée !";
              if (type == 'plus4') successMsg = "🪄 Indices générés !";
              if (type == 'reverse') successMsg = "🔁 Bouclier activé !";
              _handleResult(context, null, successMsg);
            } else {
              _handleResult(context, err, "");
            }
          }
        },
      ),
    );
  }


  void _handleResult(BuildContext context, String? error, String successMsg) {

  // 🎯 LOGIQUE ICI
  final message = error ?? successMsg;

  if (error != null) {
    debugPrint("❌ Erreur: $error");
  } else {
    String video2 = "assets/+2.mp4"; 
    String video4 = "assets/+4.mp4"; 
    String videoSkip = "assets/skip.mp4"; 
    String videoReverse = "assets/reverse.mp4"; 
    String videoJoker = "assets/wild.mp4"; 
    
    // On peut changer la vidéo selon le type de message/carte
    if (message.contains("+2")) {
        MascotDialog.show(context, videoPath: video2);
    } else if (message.contains("sautée")) {
        MascotDialog.show(context, videoPath: videoSkip);
    } else if (message.contains("Difficulté")) {
        MascotDialog.show(context, videoPath: videoJoker);
    } else if (message.contains("Indices")) {
        MascotDialog.show(context, videoPath: video4);
    } else if (message.contains("Bouclier")) {
        MascotDialog.show(context, videoPath: videoReverse);
    } else {
        MascotDialog.show(context, videoPath: videoReverse);
    }
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: error != null ? Colors.redAccent : Colors.green,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
}
