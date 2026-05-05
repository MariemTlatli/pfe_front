import 'package:flutter/material.dart';

class TextInputView extends StatelessWidget {
  final bool showResult;
  final String? initialValue;
  final Function(String) onChanged;
  final String hintText;

  const TextInputView({
    super.key, required this.showResult, this.initialValue,
    required this.onChanged, this.hintText = 'Entrez votre réponse...',
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: !showResult,
      onChanged: onChanged,
      maxLines: 4,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.amber),
        ),
      ),
    );
  }
}
