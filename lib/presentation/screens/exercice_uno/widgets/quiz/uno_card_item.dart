import 'package:flutter/material.dart';

class UnoCardItem extends StatelessWidget {
  final String type;
  final int quantity;
  final VoidCallback onTap;
  final Color color;
  final String? imagePath; // Nouveau paramètre optionnel

  const UnoCardItem({
    super.key,
    required this.type,
    required this.quantity,
    required this.onTap,
    required this.color,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Stack(
          children: [
            // Image ou couleur de fond
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: imagePath != null
                  ? Image.asset(
                      imagePath!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(color: color),
            ),
            // Badge de quantité
            Positioned(
              right: 4,
              bottom: 4,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: Colors.white,
                child: Text(
                  quantity.toString(),
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
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