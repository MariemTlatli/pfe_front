import 'dart:math';
import 'package:flutter/material.dart';

/// Dialogue stylisé pour l'attribution d'une carte Skip (Passe ton tour/Bloque).
class SkipCardDialog extends StatelessWidget {
  const SkipCardDialog({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const SkipCardDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sélection aléatoire d'une image de carte Skip/Bloque
    final randomImage = [
      'lib/presentation/screens/exercice_uno/card_img/bbloque.png',
      'lib/presentation/screens/exercice_uno/card_img/jbloque.png',
      'lib/presentation/screens/exercice_uno/card_img/vbloque.png',
    ][Random().nextInt(3)];

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.blueAccent.withOpacity(0.7), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                    child: Column(
                      children: [
                        const Text(
                          "CONSOLATION ! 🛡️",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "L'exercice était difficile, voici une carte pour t'aider :",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 20),
                        
                        Container(
                          height: 150,
                          width: 100,
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(
                            randomImage,
                            fit: BoxFit.contain,
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        const Text(
                          "CARTE PASSE",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    top: 10,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
