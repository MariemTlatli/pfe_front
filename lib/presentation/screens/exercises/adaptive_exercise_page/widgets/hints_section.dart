import 'package:flutter/material.dart';

class HintsSection extends StatelessWidget {
  final List<String> hints;
  final int initialHintsShown;
  final Function(int) onHintShown;

  const HintsSection({
    Key? key,
    required this.hints,
    required this.initialHintsShown,
    required this.onHintShown,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (hints.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () {
            if (initialHintsShown < hints.length) {
              onHintShown(initialHintsShown + 1);
            }
          },
          icon: const Icon(Icons.lightbulb_outline, size: 18),
          label: Text(
            initialHintsShown == 0
                ? 'Afficher un indice'
                : 'Indice suivant ($initialHintsShown/${hints.length})',
          ),
        ),
        if (initialHintsShown > 0)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < initialHintsShown; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb,
                          size: 16,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            hints[i],
                            style: TextStyle(color: Colors.amber.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
