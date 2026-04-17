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

  bool get _isSpecialCard {
    final id = collection.card.id.toLowerCase();
    return id.contains('inverse') ||
        id.contains('bloque') ||
        id.contains('+2') ||
        id.contains('+4') ||
        id.contains('4c');
  }

  Color get _borderColor {
    if (isSelected) return Colors.cyan;
    if (_isSpecialCard) return Colors.amber.shade600;
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = collection.hasStock;

    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor, width: isSelected ? 3 : 2),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.cyan.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            if (_isSpecialCard && !isSelected)
              BoxShadow(
                color: Colors.amber.withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Stack(
          children: [
            _buildCardImage(isAvailable),
            _buildQuantityBadge(),
            if (_isSpecialCard) _buildSpecialBadge(),
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
      color: _isSpecialCard ? Colors.amber.shade900 : Colors.red.shade800,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isSpecialCard ? Icons.star : Icons.image_not_supported,
              color: Colors.white54,
            ),
            const SizedBox(height: 4),
            Text(
              collection.displayName,
              textAlign: TextAlign.center,
              style: TextStyle(
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
          color: _isSpecialCard ? Colors.amber : Colors.red,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 2,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          'x${collection.quantity}',
          style: TextStyle(
            color: _isSpecialCard ? Colors.black87 : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialBadge() {
    return Positioned(
      top: 4,
      left: 4,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.amber,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.5),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Text('✨', style: TextStyle(fontSize: 12)),
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
