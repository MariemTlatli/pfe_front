import 'dart:math';
import 'package:flutter/material.dart';

/// Dialogue stylisé pour annoncer l'attribution d'une carte +2.
/// Design cohérent avec MascotDialog (Glassmorphism, bords dorés).
class PlusTwoDialog extends StatelessWidget {
  const PlusTwoDialog({Key? key}) : super(key: key);

  /// Affiche le dialogue
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const PlusTwoDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sélection aléatoire d'une image de carte +2 parmi les couleurs UNO
    final randomImage = [
      'lib/presentation/screens/exercice_uno/card_img/j+2.png',
      'lib/presentation/screens/exercice_uno/card_img/b+2.png',
      'lib/presentation/screens/exercice_uno/card_img/v+2.png',
      'lib/presentation/screens/exercice_uno/card_img//r+2.png',
    ][Random().nextInt(4)];

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E), // Fond sombre premium
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.amber.withOpacity(0.7), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.2),
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
                          "EXCEPTIONNEL ! 🎉",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Difficulté maîtrisée. Tu gagnes un bonus :",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 20),
                        
                        // Zone d'image (remplace MascotVideo)
                        Container(
                          height: 150,
                          width: 100,
                          padding: const EdgeInsets.all(8),
                          child: Hero(
                            tag: 'bonus_card',
                            child: Image.asset(
                              randomImage,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        const Text(
                          "UNE CARTE +2",
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                  // Bouton de fermeture en haut à droite
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
