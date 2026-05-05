import 'package:flutter/material.dart';

class BleuBtn extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;

  const BleuBtn({
    super.key,
    required this.label,
    this.onPressed,
  });

  @override
  State<BleuBtn> createState() => _BleuBtnState();
}

class _BleuBtnState extends State<BleuBtn> {
  bool _isPressed = false;

  // Couleurs inspirées de l'image
  static const Color _colorTop = Color(0xFF3ED8E0);  // Bleu turquoise
  static const Color _colorBottom = Color(0xFF7848A2); // Violet
  static const Color _colorText = Color(0xFF43175C);   // Texte violet foncé

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Quand on appuie
      onTapDown: (_) {
        setState(() => _isPressed = true);
      },
      // Quand on relâche
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        // On réduit la marge interne quand on clique pour donner l'impression que le bouton s'enfonce
        padding: EdgeInsets.only(bottom: _isPressed ? 4 : 12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. La partie "3D" du bas (Violet)
            Container(
              height: 60,
              width: double.infinity, 
              decoration: BoxDecoration(
                color: _colorBottom,
                borderRadius: BorderRadius.circular(25),
                // L'ombre portée du bloc complet pour le réalisme
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x2A000000), // Ombre noire légère
                    offset: Offset(0, 4),
                    blurRadius: 4,
                  )
                ],
              ),
            ),

            // 2. La partie du dessus (Bleu)
            // On la translate vers le haut de la différence de padding
            Transform.translate(
              offset: Offset(0, _isPressed ? 0 : -8), 
              child: Container(
                height: 60,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _colorTop,
                  borderRadius: BorderRadius.circular(25),
                  // Bordure légère pour séparer le haut du bas si besoin
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.black.withOpacity(0.1), 
                      width: 1
                    ),
                  ),
                ),
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    color: _colorText,
                    fontSize: 28,
                    fontWeight: FontWeight.w900, // Gras pour l'effet cartoon
                    fontFamily: 'VarelaRound', // Police arrondie recommandée (optionnelle)
                    letterSpacing: 1.2,
                    // Petit effet de relief sur le texte (optionnel)
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        color: Colors.white,
                        blurRadius: 2,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}