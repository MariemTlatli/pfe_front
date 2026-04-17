// lib/presentation/screens/exercice_uno/widgets/quiz/target_selector_dialog.dart
import 'package:flutter/material.dart';

class TargetSelectorDialog extends StatelessWidget {
  final List<dynamic> targets;

  const TargetSelectorDialog({super.key, required this.targets});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text('Choisir une cible (+2)', style: TextStyle(color: Colors.white)),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: targets.length,
          itemBuilder: (context, index) {
            final target = targets[index];
            return ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.red, child: Icon(Icons.person, color: Colors.white)),
              title: Text(target['username'] ?? 'Utilisateur', style: const TextStyle(color: Colors.white)),
              subtitle: Text('ID: ${target['_id']}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
              onTap: () => Navigator.of(context).pop(target['_id']),

            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler', style: TextStyle(color: Colors.amber))),
      ],
    );
  }
}
