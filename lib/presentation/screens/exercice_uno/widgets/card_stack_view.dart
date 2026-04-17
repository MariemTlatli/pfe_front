import 'package:flutter/material.dart';
import 'package:front/presentation/screens/exercice_uno/widgets/carte.dart';
import '../models/card_model.dart';

class CardStackView extends StatelessWidget {
  final StackCard drawCard;
  final StackCard discardCard;
  final VoidCallback? onDrawTap;
  final VoidCallback? onDiscardTap;
  final double cardWidth;
  final double cardHeight;

  const CardStackView({
    super.key,
    required this.drawCard,
    required this.discardCard,
    this.onDrawTap,
    this.onDiscardTap,
    this.cardWidth = 128,
    this.cardHeight = 192,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStack(drawCard, onDrawTap, isDraw: true),
          SizedBox(width: 48),
          _buildStack(discardCard, onDiscardTap, isDraw: false),
        ],
      ),
    );
  }

  Widget _buildStack(
    StackCard card,
    VoidCallback? onTap, {
    required bool isDraw,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(
        width: cardWidth + 12,
        height: cardHeight + 12,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(3, (i) {
          return Transform.translate(
            offset: Offset(i * 2.0, i * 2.0),
            child: CardImage(
              card: isDraw ? card : card.copyWith(rotation: 0.1),
              width: cardWidth,
              height: cardHeight,
              onTap: i == 0 ? onTap : null,
            ),
          );
        }),
      ),
    );
  }
}
