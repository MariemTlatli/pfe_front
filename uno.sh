#!/bin/bash

echo "=========================================="
echo "  Création structure exercice_uno"
echo "=========================================="

# Création des dossiers
mkdir -p front/lib/presentation/screens/exercice_uno/models
mkdir -p front/lib/presentation/screens/exercice_uno/widgets

echo "[OK] Dossiers créés"

# ============================================
# card_collection.dart
# ============================================
cat > front/lib/presentation/screens/exercice_uno/models/card_collection.dart << 'EOF'
class CardCollection {
  final StackCard card;
  final int quantity;
  final String displayName;

  const CardCollection({
    required this.card,
    required this.quantity,
    String? displayName,
  }) : displayName = displayName ?? card.label ?? card.id;

  bool get hasStock => quantity > 0;

  CardCollection copyWith({int? quantity}) {
    return CardCollection(
      card: card,
      quantity: quantity ?? this.quantity,
      displayName: displayName,
    );
  }
}
EOF
echo "[OK] card_collection.dart"

# ============================================
# card_item.dart
# ============================================
cat > front/lib/presentation/screens/exercice_uno/widgets/card_item.dart << 'EOF'
import 'package:flutter/material.dart';
import '../models/card_collection.dart';

class CardItem extends StatelessWidget {
  final CardCollection collection;
  final bool isSelected;
  final VoidCallback onTap;

  const CardItem({
    super.key,
    required this.collection,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = collection.hasStock;

    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.transparent,
            width: 3,
          ),
        ),
        child: Stack(
          children: [
            _buildCardImage(isAvailable),
            _buildQuantityBadge(),
            if (!isAvailable) _buildUnavailableOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildCardImage(bool isAvailable) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Opacity(
        opacity: isAvailable ? 1.0 : 0.4,
        child: Image.asset(
          collection.card.assetPath,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.red.shade800,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_not_supported, color: Colors.white54),
            const SizedBox(height: 4),
            Text(
              collection.displayName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityBadge() {
    return Positioned(
      top: 4,
      right: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'x${collection.quantity}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildUnavailableOverlay() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        color: Colors.black38,
        child: const Center(
          child: Icon(Icons.lock, color: Colors.white54, size: 30),
        ),
      ),
    );
  }
}
EOF
echo "[OK] card_item.dart"

# ============================================
# card_grid.dart
# ============================================
cat > front/lib/presentation/screens/exercice_uno/widgets/card_grid.dart << 'EOF'
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

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.65,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: collections.length,
      itemBuilder: (context, index) {
        final collection = collections[index];
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
    );
  }
}
EOF
echo "[OK] card_grid.dart"

# ============================================
# card_dialog.dart
# ============================================
cat > front/lib/presentation/screens/exercice_uno/widgets/card_dialog.dart << 'EOF'
import 'package:flutter/material.dart';
import '../models/card_collection.dart';
import 'card_grid.dart';

class CardDialog extends StatefulWidget {
  final List<CardCollection> collections;

  const CardDialog({super.key, required this.collections});

  static Future<CardCollection?> show(
    BuildContext context,
    List<CardCollection> collections,
  ) {
    return showDialog<CardCollection>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CardDialog(collections: collections),
    );
  }

  @override
  State<CardDialog> createState() => _CardDialogState();
}

class _CardDialogState extends State<CardDialog> {
  String? _selectedCardId;

  CardCollection? get _selectedCollection {
    if (_selectedCardId == null) return null;
    return widget.collections.firstWhere(
      (c) => c.card.id == _selectedCardId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E2C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              Flexible(
                child: CardGrid(
                  collections: widget.collections,
                  selectedCardId: _selectedCardId,
                  onCardSelected: (collection) {
                    setState(() {
                      _selectedCardId = collection.card.id;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Choisir une carte',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white70,
            side: const BorderSide(color: Colors.white70),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _selectedCollection != null
              ? () => Navigator.of(context).pop(_selectedCollection)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Utiliser cette carte'),
        ),
      ],
    );
  }
}
EOF
echo "[OK] card_dialog.dart"

echo ""
echo "=========================================="
echo "  TERMINÉ ! Fichiers créés"
echo "=========================================="
echo ""
echo "N'oubliez pas d'importer StackCard dans card_collection.dart"
echo "Lancez: flutter run"