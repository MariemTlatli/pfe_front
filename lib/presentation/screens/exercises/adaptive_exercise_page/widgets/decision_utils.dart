import 'package:flutter/material.dart';
import 'package:front/presentation/screens/exercice_uno/widgets/plus_two_dialog.dart';
import 'package:front/presentation/screens/exercice_uno/widgets/skip_card_dialog.dart';
import 'package:front/presentation/screens/home/success_secreen.dart';
import '../adaptive_exercise_controller.dart';

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
        if (event.isPlusTwoGained ||
            event.isSkipGained ||
            event.lootedCard != null) {
          // 🎁 PRIORITÉ : Affichage du dialogue combiné pour TOUTES les récompenses
          return CombinedRewardDialog(event: event, controller: controller);
        } else if (event.actionType == DecisionActionType.takeBreak) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            title: const Text('Pause recommandée ☕', style: TextStyle(color: Colors.white)),
            content: Text(event.message, style: const TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  controller.nextExercise(); // Va déclencher le pop() du controller
                },
                child: const Text('Prendre une pause', style: TextStyle(color: Colors.amber)),
              ),
            ],
          );
        } else if (event.actionType == DecisionActionType.nextCompetence) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.amber, width: 2)),
            title: const Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.amber, size: 30),
                SizedBox(width: 10),
                Text('Compétence Maîtrisée ! 🎉', style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(event.message, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 20),
                _buildStatsSection(event),
              ],
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                onPressed: () {
                  Navigator.pop(ctx);
                  controller.nextExercise();
                },
                child: const Text('Voir ma progression', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        } else if (event.actionType == DecisionActionType.timeOut) {
          // ... reste inchangé ...
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
                const Icon(
                  Icons.sentiment_dissatisfied,
                  color: Colors.redAccent,
                  size: 80,
                ),
                const SizedBox(height: 16),
                Text(
                  event.encouragement,
                  style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _buildStatsSection(event),
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
          // Affichage standard pour les autres décisions (adapt, continue)
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Analyse Pédagogique', style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  event.message,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                _buildStatsSection(event),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK', style: TextStyle(color: Colors.amber)),
              ),
            ],
          );
        }
      },
    );
  }

  static Widget _buildStatsSection(DecisionEvent event) {
    if (event.newMastery == null && event.newZone == null) return const SizedBox.shrink();

    Color zoneColor;
    String zoneLabel;
    IconData zoneIcon;

    switch (event.newZone?.toLowerCase()) {
      case 'mastered':
        zoneColor = Colors.greenAccent;
        zoneLabel = 'MAÎTRISÉ';
        zoneIcon = Icons.check_circle;
        break;
      case 'frustration':
        zoneColor = Colors.orangeAccent;
        zoneLabel = 'FRUSTRATION';
        zoneIcon = Icons.warning;
        break;
      default:
        zoneColor = Colors.blueAccent;
        zoneLabel = 'ZONE ZPD';
        zoneIcon = Icons.psychology;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Niveau de Maîtrise', style: TextStyle(color: Colors.white60, fontSize: 12)),
              Text(
                '${((event.newMastery ?? 0) * 100).toStringAsFixed(0)}%',
                style: TextStyle(color: zoneColor, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: event.newMastery ?? 0,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(zoneColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(zoneIcon, color: zoneColor, size: 16),
              const SizedBox(width: 8),
              Text(
                'État : ',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
              Text(
                zoneLabel,
                style: TextStyle(color: zoneColor, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Dialogue unifié pour afficher toutes les récompenses gagnées à la fin de l'exercice.
class CombinedRewardDialog extends StatelessWidget {
  final DecisionEvent event;
  final AdaptiveExerciseController controller;

  const CombinedRewardDialog({
    Key? key,
    required this.event,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> rewardsCards = [];

    if (event.isPlusTwoGained) {
      rewardsCards.add(
        _buildCardItem(
          'lib/presentation/screens/exercice_uno/card_img/r+2.png',
          '+2 Bonus',
        ),
      );
    }
    if (event.isSkipGained) {
      rewardsCards.add(
        _buildCardItem(
          'lib/presentation/screens/exercice_uno/card_img/b_pass.png',
          'Skip',
        ),
      );
    }
    if (event.lootedCard != null) {
      final cNum = event.lootedCard!['number'];
      final cCol = event.lootedCard!['color']; // 'r', 'b', 'v', 'j'
      rewardsCards.add(
        _buildCardItem(
          'lib/presentation/screens/exercice_uno/card_img/${cCol}_$cNum.png',
          'Carte $cNum',
        ),
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E), // Fond sombre premium
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.amber.withOpacity(0.7), width: 2.5),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "RÉCOMPENSES 🎉",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              event.message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 20),
            
            // 📊 Ajout des statistiques pédagogiques
            AdaptiveDecisionUtils._buildStatsSection(event),
            const SizedBox(height: 20),

            // Affichage de toutes les cartes gagnées côte à côte
            Wrap(
              spacing: 15,
              runSpacing: 15,
              alignment: WrapAlignment.center,
              children: rewardsCards,
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                // On déclenche toujours l'action suivante (pédagogique) après avoir reçu ses récompenses
                controller.nextExercise();
              },
              child: const Text(
                'Génial !',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardItem(String imagePath, String title) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 120,
          width: 80,
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            errorBuilder: (ctx, _, __) =>
                const Icon(Icons.style, color: Colors.green, size: 50),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.amber,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
