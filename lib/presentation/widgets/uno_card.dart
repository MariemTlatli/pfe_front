import 'package:flutter/material.dart';

class UnoCard extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Widget? content;
  final double? width;
  final double? height;

  const UnoCard({
    Key? key,
    required this.label,
    this.onTap,
    this.content,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          // The bottom "3D" part (darker grey)
          color: const Color(0xFF5D5D5D),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 6), // Shows the bottom part
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFFFFF), // Top white
                Color(0xFFE0E0E0), // Bottom light grey
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(
              color: Colors.white,
              width: 1.5,
            ),
          ),
          child: Center(
            child: content ?? 
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF424242), // Dark Grey
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
          ),
        ),
      ),
    );
  }
}
