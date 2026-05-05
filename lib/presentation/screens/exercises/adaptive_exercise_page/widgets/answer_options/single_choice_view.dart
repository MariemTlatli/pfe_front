import 'package:flutter/material.dart';
import 'package:front/core/services/tts_service.dart';

class SingleChoiceView extends StatelessWidget {
  final List<String> options;
  final String? selectedAnswer;
  final bool showResult;
  final Function(String) onSelected;

  const SingleChoiceView({
    super.key,
    required this.options,
    this.selectedAnswer,
    required this.showResult,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Palette UNO : Rouge, Bleu, Vert, Jaune
    final unoColors = [
      const _UnoPalette(base: Color(0xFF8B0000), light: Color.fromARGB(255, 255, 255, 255), medium: Color.fromARGB(255, 238, 235, 235), text: Color(0xFF4A0000)), // Rouge
      const _UnoPalette(base: Color(0xFF0D47A1), light: Color.fromARGB(255, 255, 255, 255), medium: Color.fromARGB(255, 238, 235, 235), text: Color(0xFF0A2E5A)), // Bleu
      const _UnoPalette(base: Color(0xFF1B5E20), light: Color.fromARGB(255, 255, 255, 255), medium: Color.fromARGB(255, 238, 235, 235), text: Color(0xFF0F3D1A)), // Vert
      const _UnoPalette(base: Color(0xFFF57F17), light: Color.fromARGB(255, 255, 255, 255), medium: Color.fromARGB(255, 238, 235, 235), text: Color(0xFF5D4037)), // Jaune
    ];

    return Column(
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = selectedAnswer == option;
        final palette = unoColors[index % unoColors.length];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: showResult ? null : () => onSelected(option),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              // Style UnoCard : conteneur externe pour l'effet 3D
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: palette.base, // Partie "épaisseur" du bas
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Container(
                // Marge inférieure pour révéler la partie 3D (pattern UnoCard)
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  // Gradient vertical comme UnoCard
                  gradient: LinearGradient(
                    colors: [palette.light, palette.medium],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border.all(
                    color: isSelected ? palette.text : Colors.white.withOpacity(0.7),
                    width: isSelected ? 2.5 : 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    // Icône de sélection animée
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      child: Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        key: ValueKey<bool>(isSelected),
                        color: isSelected ? palette.text : palette.text.withOpacity(0.6),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Texte de l'option
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          color: palette.text,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                          fontSize: 17,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    // Bouton TTS
                    IconButton(
                      icon: Icon(
                        Icons.volume_up_outlined,
                        color: palette.text.withOpacity(0.7),
                        size: 22,
                      ),
                      onPressed: () => TtsService().speak(option),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// Helper pour organiser les palettes de couleurs UNO
class _UnoPalette {
  final Color base;    // Couleur de fond 3D (bas)
  final Color light;   // Début du gradient (haut)
  final Color medium;  // Fin du gradient (bas)
  final Color text;    // Couleur du texte et icônes

  const _UnoPalette({
    required this.base,
    required this.light,
    required this.medium,
    required this.text,
  });
}