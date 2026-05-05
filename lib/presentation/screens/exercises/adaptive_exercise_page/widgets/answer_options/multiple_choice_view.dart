import 'package:flutter/material.dart';
import 'package:front/core/services/tts_service.dart';

class MultipleChoiceView extends StatelessWidget {
  final List<String> options;
  final List<String> selectedAnswers;
  final bool showResult;
  final Function(List<String>) onSelected;

  const MultipleChoiceView({
    super.key, required this.options, required this.selectedAnswers,
    required this.showResult, required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SÉLECTION MULTIPLE', style: TextStyle(fontSize: 12, color: Colors.white38, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...options.asMap().entries.map((entry) {
          final option = entry.value;
          final isSelected = selectedAnswers.contains(option);
          final unoColors = [const Color(0xFF00A2E8), const Color(0xFF22B14C), const Color(0xFFFFF200), const Color(0xFFEB1C24)];
          final accentColor = unoColors[entry.key % unoColors.length];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: showResult ? null : () {
                final newList = List<String>.from(selectedAnswers);
                if (isSelected) newList.remove(option); else newList.add(option);
                onSelected(newList);
              },
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isSelected ? accentColor.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isSelected ? accentColor : Colors.white.withOpacity(0.1), width: isSelected ? 2.5 : 1),
                ),
                child: Row(
                  children: [
                    Icon(isSelected ? Icons.check_box : Icons.check_box_outline_blank, color: isSelected ? accentColor : Colors.white24),
                    const SizedBox(width: 16),
                    Expanded(child: Text(option, style: const TextStyle(color: Colors.white, fontSize: 17))),
                    IconButton(icon: const Icon(Icons.volume_up, color: Colors.white38, size: 20), onPressed: () => TtsService().speak(option)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
