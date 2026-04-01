import 'package:flutter/material.dart';

class AdaptationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String encouragement;
  final VoidCallback onContinue;

  const AdaptationDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.encouragement,
    required this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.auto_fix_high, color: Colors.blue, size: 32),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          if (encouragement.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      encouragement,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onContinue();
          },
          child: const Text('Continuer'),
        ),
      ],
    );
  }
}
