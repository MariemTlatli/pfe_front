import 'package:flutter/material.dart';
import '../models/card_model.dart';

class CardImage extends StatelessWidget {
  final StackCard card;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const CardImage({
    super.key,
    required this.card,
    this.width = 128,
    this.height = 192,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Transform.rotate(
        angle: card.rotation,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: card.face == CardFace.faceDown
                ? theme.colorScheme.surfaceContainerLowest
                : null,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: card.face == CardFace.faceDown
                  ? theme.colorScheme.surfaceBright
                  : Colors.white,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
            image: card.face == CardFace.faceUp
                ? DecorationImage(
                    image: AssetImage(card.assetPath),
                    fit: BoxFit.cover,
                    onError: (_, __) =>
                        debugPrint('❌ Image non trouvée: ${card.assetPath}'),
                  )
                : null,
          ),
          child: card.face == CardFace.faceDown
              ? _buildFaceDown(theme)
              : _buildFaceUpLabels(),
        ),
      ),
    );
  }

  Widget _buildFaceDown(ThemeData theme) => Center(
    child: Transform.rotate(
      angle: -0.26,
      child: Container(
        width: width * 0.62,
        height: height * 0.67,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 2),
        ),
        child: const Center(
          child: Text(
            'UNO',
            style: TextStyle(
              color: Colors.white24,
              fontWeight: FontWeight.w900,
              fontSize: 24,
              fontFamily: 'Lexend',
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildFaceUpLabels() {
    if (card.label == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Transform.rotate(angle: 3.14, child: _label()),
          ),
        ],
      ),
    );
  }

  Widget _label() => Text(
    card.label!,
    style: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w900,
      fontSize: 20,
      fontFamily: 'Lexend',
    ),
  );
}
