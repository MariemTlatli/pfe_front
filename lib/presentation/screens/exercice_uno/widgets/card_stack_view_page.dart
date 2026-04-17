import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:front/presentation/screens/exercice_uno/models/card_model.dart';
import 'package:front/presentation/screens/exercice_uno/widgets/carte.dart';

Widget buildArcHand(BuildContext context, List<String> assetPaths) {
  final int cardCount = assetPaths.length;

  // 🛡️ Cas particulier : 0 carte
  if (cardCount == 0) {
    return const SizedBox.shrink();
  }

  // 🛡️ Cas particulier : 1 seule carte → pas de rotation
  if (cardCount == 1) {
    return SizedBox(
      width: 100,
      height: 150,
      child: GestureDetector(
        onTap: () => _msg(context, '🃏 Carte 1'),
        child: CardImage(
          card: StackCard(
            id: 'card_0',
            imageProvider: '',
            assetPaths: [assetPaths.first],
            face: CardFace.faceUp,
            label: 'Carte 1',
            rotation: 0,
          ),
          width: 100,
          height: 130,
        ),
      ),
    );
  }

  // 🎨 Paramètres de l'éventail
  final double maxAngle = 0.5; // ~28° d'ouverture totale (ajustable)
  final double horizontalSpacing = 60.0; // Espacement entre cartes
  final double verticalOffset = 40.0; // Courbure vers le bas
  final double centerIndex = (cardCount - 1) / 2.0;

  return SizedBox(
    width: cardCount * horizontalSpacing + 100,
    height: 280, // Plus haut pour l'arc
    child: Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: assetPaths.asMap().entries.map((entry) {
        final int index = entry.key;
        final String assetPath = entry.value;

        // Position relative au centre : [-centerIndex, +centerIndex]
        final double position = index - centerIndex;

        // 🔄 Position normalisée entre -1 et 1
        final double normalizedPos = position / centerIndex;

        // 📐 Angle de rotation (plus prononcé)
        final double angle = normalizedPos * maxAngle;

        // ↔️ Translation horizontale
        final double xOffset = position * horizontalSpacing;

        // ↕️ Courbure verticale (parabole)
        // final double yOffset =
        //     -math.pow(normalizedPos, 2).toDouble() * verticalOffset;
        final double yOffset =
            (math.pow(position, 2) * verticalOffset) /
            (centerIndex * centerIndex);
        final card = StackCard(
          id: 'card_$index',
          imageProvider: '',
          assetPaths: [assetPath],
          face: CardFace.faceUp,
          label: 'Carte ${index + 1}',
          rotation: angle,
        );

        return Transform.translate(
          offset: Offset(xOffset, yOffset),
          child: Transform.rotate(
            angle: angle,
            child: GestureDetector(
              onTap: () => _msg(context, '🃏 Carte ${index + 1}'),
              child: CardImage(card: card, width: 100, height: 150),
            ),
          ),
        );
      }).toList(),
    ),
  );
}

void _msg(BuildContext ctx, String txt) {
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(txt)));
}
