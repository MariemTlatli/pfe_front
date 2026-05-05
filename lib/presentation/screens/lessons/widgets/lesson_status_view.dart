import 'package:flutter/material.dart';
import '../../../provider/lesson_provider.dart';

class LessonStatusView extends StatelessWidget {
  final LessonState state;

  const LessonStatusView({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isGenerating = state.isGenerating;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogo(isGenerating),
            const SizedBox(height: 32),
            Text(
              state.statusMessage ?? (isGenerating ? "Génération IA..." : "Chargement..."),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const LinearProgressIndicator(borderRadius: BorderRadius.all(Radius.circular(10))),
            if (isGenerating) ...[
              const SizedBox(height: 24),
              const Text(
                "L'intelligence artificielle prépare vos leçons sur mesure. Cela peut prendre quelques instants.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(bool isGenerating) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: isGenerating ? Colors.blueAccent : Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: Icon(
        isGenerating ? Icons.psychology : Icons.menu_book,
        size: 50,
        color: isGenerating ? Colors.white : Colors.blue,
      ),
    );
  }
}
