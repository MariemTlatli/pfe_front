import 'package:flutter/material.dart';

class HintsSection extends StatelessWidget {
  final List<String> hints;
  final int initialHintsShown;
  final Function(int) onHintShown;

  const HintsSection({
    Key? key,
    required this.hints,
    required this.initialHintsShown,
    required this.onHintShown,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (hints.isEmpty) return const SizedBox.shrink();

    final bool canShowMore = initialHintsShown < hints.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔘 BOUTON 3D STYLE "SHOP"
        Opacity(
          opacity: canShowMore ? 1.0 : 0.6,
          child: GestureDetector(
            onTap: canShowMore
                ? () => onHintShown(initialHintsShown + 1)
                : null,
            child: Container(
              // Partie basse 3D (Turquoise/Teal)
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: const Color(0xFF00897B),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x2A000000),
                    offset: Offset(0, 4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Container(
                // Partie haute (Vert vif)
                margin: const EdgeInsets.only(
                  bottom: 6,
                ), // Révèle l'épaisseur 3D
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFC8E65A), Color(0xFFA4D63D)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      size: 22,
                      color: Color(0xFF2E4A1E), // Vert forêt foncé
                    ),
                    const SizedBox(width: 10),
                    Text(
                      initialHintsShown == 0
                          ? 'Afficher un indice'
                          : 'Indice suivant ($initialHintsShown/${hints.length})',
                      style: const TextStyle(
                        color: Color(0xFF2E4A1E),
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 📝 ZONE D'AFFICHAGE DES INDICES
        if (initialHintsShown > 0) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 4, 176, 9).withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(initialHintsShown, (i) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: i < initialHintsShown - 1 ? 10 : 0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb,
                        size: 18,
                        color: Color.fromARGB(255, 187, 243, 74),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          hints[i],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ],
    );
  }
}
