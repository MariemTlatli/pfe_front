// lib/presentation/screens/exercice_uno/widgets/quiz/uno_card_hand.dart
import 'package:flutter/material.dart';
import 'package:front/data/models/special_cards_model.dart';
import 'uno_card_item.dart';

class UnoCardHand extends StatelessWidget {
  final SpecialCardsStatus? status;
  final Function(String) onUse;

  const UnoCardHand({super.key, required this.status, required this.onUse});

  @override
  Widget build(BuildContext context) {
    if (status == null || !status!.hasSpecialCards) {
      return const SizedBox(height: 120, child: Center(child: Text("Pas de cartes spéciales", style: TextStyle(color: Colors.white70))));
    }

    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (status!.skipCards > 0)
            UnoCardItem(
              type: 'skip',
              quantity: status!.skipCards,
              color: Colors.blue,
              imagePath: 'lib/presentation/screens/exercice_uno/card_img/bbloque.png',
              onTap: () => onUse('skip'),
            ),
          if (status!.jokerCards > 0)
            UnoCardItem(
              type: 'joker',
              quantity: status!.jokerCards,
              color: Colors.purple,
              imagePath: 'lib/presentation/screens/exercice_uno/card_img/s4c.png',
              onTap: () => onUse('joker'),
            ),
          if (status!.plus2Cards > 0)
            UnoCardItem(
              type: '+2',
              quantity: status!.plus2Cards,
              color: Colors.red,
              imagePath: 'lib/presentation/screens/exercice_uno/card_img/v+2.png',
              onTap: () => onUse('plus2'),
            ),
          if (status!.plus4Cards > 0)
            UnoCardItem(
              type: '+4',
              quantity: status!.plus4Cards,
              color: Colors.black,
              imagePath: 'lib/presentation/screens/exercice_uno/card_img/s+4.png',
              onTap: () => onUse('plus4'),
            ),
          if (status!.reverseCards > 0)
            UnoCardItem(
              type: 'rev',
              quantity: status!.reverseCards,
              color: Colors.green,
              imagePath: 'lib/presentation/screens/exercice_uno/card_img/jinverse.png',
              onTap: () => onUse('reverse'),
            ),

        ],
      ),
    );
  }
}
