import 'package:flutter/material.dart';
import '../models/card_collection.dart';
import 'card_item.dart';

class CardGrid extends StatelessWidget {
  final List<CardCollection> collections;
  final String? selectedCardId;
  final ValueChanged<CardCollection> onCardSelected;

  const CardGrid({
    super.key,
    required this.collections,
    required this.selectedCardId,
    required this.onCardSelected,
  });

  // Détecte si une carte est spéciale
  bool _isSpecialCard(String cardId) {
    return cardId.contains('inverse') ||
        cardId.contains('bloque') ||
        cardId.contains('+2') ||
        cardId.contains('+4') ||
        cardId.contains('4c');
  }

  // Obtient le nom lisible d'une carte spéciale
  String _getSpecialCardName(String assetPath) {
    if (assetPath.contains('inverse')) return '🔄 Inverse';
    if (assetPath.contains('bloque')) return '⛔ Bloque';
    if (assetPath.contains('+2')) return '➕ +2';
    if (assetPath.contains('+4')) return '➕➕ +4';
    if (assetPath.contains('4c')) return '🎨 Changeur';
    return 'Spéciale';
  }

  @override
  Widget build(BuildContext context) {
    // Séparer les cartes normales et spéciales
    final normalCards = collections
        .where((c) => !_isSpecialCard(c.card.id))
        .toList();
    final specialCards = collections
        .where((c) => _isSpecialCard(c.card.id))
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cartes normales
          if (normalCards.isNotEmpty) ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.65,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: normalCards.length,
              itemBuilder: (context, index) {
                final collection = normalCards[index];
                return Column(
                  children: [
                    Expanded(
                      child: CardItem(
                        collection: collection,
                        isSelected: collection.card.id == selectedCardId,
                        onTap: () => onCardSelected(collection),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Tooltip(
                      message: collection.displayName,
                      child: Text(
                        collection.displayName,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],

          // Cartes spéciales
          if (specialCards.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 8.0,
              ),
              child: Text(
                'Cartes Spéciales',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.65,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: specialCards.length,
              itemBuilder: (context, index) {
                final collection = specialCards[index];
                final specialName = _getSpecialCardName(
                  collection.card.assetPath,
                );
                return Column(
                  children: [
                    Expanded(
                      child: CardItem(
                        collection: collection,
                        isSelected: collection.card.id == selectedCardId,
                        onTap: () => onCardSelected(collection),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Tooltip(
                      message: specialName,
                      child: Text(
                        specialName,
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
