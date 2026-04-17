// lib/presentation/screens/exercice_uno/widgets/quiz/quiz_view.dart
import 'package:flutter/material.dart';
import '../../models/quiz_models.dart';
import 'quiz_option_card.dart';
import 'uno_card_hand.dart';
import 'target_selector_dialog.dart';
import '../../services/quiz_controller.dart';

import 'package:provider/provider.dart';

class QuizView extends StatelessWidget {
  final QuizQuestion question;
  final int currentIndex;
  final int totalQuestions;
  final int? selectedIndex;
  final Function(int) onSelected;
  final VoidCallback onSubmit;

  const QuizView({
    super.key,
    required this.question,
    required this.currentIndex,
    required this.totalQuestions,
    required this.selectedIndex,
    required this.onSelected,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<QuizController>();
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProgress(),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(question.question, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ...question.options.asMap().entries.map((e) => QuizOptionCard(
                    option: e.value, isSelected: selectedIndex == e.key, onTap: () => onSelected(e.key))),
                  if (controller.plus4Hints.isNotEmpty) _buildHintsPanel(controller.plus4Hints),
                  const SizedBox(height: 24),
                  const Text("Tes cartes spéciales :", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  UnoCardHand(
                    status: controller.specialCards,
                    onUse: (type) async {
                      if (type == 'plus2') {
                        final targets = await controller.getPotentialTargets();
                        if (targets.isNotEmpty) {
                          final String? targetId = await showDialog<String>(
                            context: context,
                            builder: (ctx) => TargetSelectorDialog(targets: targets),
                          );
                          if (targetId != null) {
                            final error = await controller.useSpecialCard('plus2', targetId: targetId);
                            if (error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.redAccent));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🚀 Attaque +2 envoyée !"), backgroundColor: Colors.green));
                            }
                          }
                        }
                      } else {
                        final error = await controller.useSpecialCard(type);
                        if (error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.redAccent));
                        } else {
                          String msg = "Carte utilisée !";
                          if (type == 'skip') msg = "⏭️ Question sautée !";
                          if (type == 'joker') msg = "🃏 Difficulté ajustée !";
                          if (type == 'plus4') msg = "🪄 4 indices générés par l'IA !";
                          if (type == 'reverse') msg = "🔁 Bouclier d'inversion activé !";
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
                        }
                      }
                    },


                  ),
                ],
              ),
            ),
          ),


          const SizedBox(height: 16),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return LinearProgressIndicator(
      value: (currentIndex + 1) / totalQuestions,
      backgroundColor: Colors.white10,
      color: Colors.amber,
      minHeight: 6,
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: selectedIndex != null ? onSubmit : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
      ),
      child: const Text('Valider', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildHintsPanel(List<String> hints) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Text("Aide Premium +4", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          ...hints.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${e.key + 1}.", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(child: Text(e.value, style: const TextStyle(color: Colors.white, fontSize: 14))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

