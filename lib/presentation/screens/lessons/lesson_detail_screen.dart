import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../provider/lesson_provider.dart';
import '../../provider/auth_provider.dart';

class LessonDetailScreen extends StatelessWidget {
  final String competenceId;
  final String competenceName;

  const LessonDetailScreen({
    Key? key,
    required this.competenceId,
    required this.competenceName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LessonProvider>();
    final state = provider.state;
    final lesson = state.selectedLesson;

    if (lesson == null) {
      return const Scaffold(body: Center(child: Text("Sélectionnez une leçon")));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Leçon ${lesson.order}", style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          _buildProgressIndicator(state),
          Expanded(child: _buildMarkdownContent(lesson.content)),
          _buildBottomNavigation(context, provider, state),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(LessonState state) {
    final progress = state.selectedLesson!.order / state.lessonsCount;
    return LinearProgressIndicator(value: progress, minHeight: 4, backgroundColor: Colors.grey[200], color: Colors.blue);
  }

  Widget _buildMarkdownContent(String content) {
    return Markdown(
      data: content,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
        p: const TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF333333)),
        code: TextStyle(backgroundColor: Colors.grey[100], fontFamily: 'monospace'),
        codeblockDecoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context, LessonProvider provider, LessonState state) {
    final canGoNext = provider.canGoNext;
    final userId = context.read<AuthProvider>().userId ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
      child: Row(
        children: [
          if (provider.canGoPrevious)
            IconButton(onPressed: () => provider.previousLesson(), icon: const Icon(Icons.chevron_left, size: 32)),
          const Spacer(),
          if (canGoNext)
            ElevatedButton.icon(
              onPressed: () => provider.nextLesson(),
              icon: const Icon(Icons.arrow_forward),
              label: const Text("SUIVANT", style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            )
          else
            ElevatedButton.icon(
              onPressed: () => _finishLessons(context, userId),
              icon: const Icon(Icons.check_circle),
              label: const Text("TERMINER", style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            ),
        ],
      ),
    );
  }

  void _finishLessons(BuildContext context, String userId) {
    Navigator.pop(context); // Detail
    Navigator.pop(context); // List
    Navigator.pushReplacementNamed(context, '/competence-ready', arguments: {
      'competenceId': competenceId, 
      'competenceName': competenceName, 
      'userId': userId
    });
  }
}
