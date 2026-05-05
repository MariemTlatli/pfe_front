import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/lesson_provider.dart';
import 'widgets/lesson_status_view.dart';
import 'widgets/lesson_header.dart';
import 'widgets/lesson_card_v2.dart';

class LessonsListScreen extends StatefulWidget {
  final String competenceId;
  final String competenceName;
  final bool hasLessons;

  const LessonsListScreen({
    Key? key,
    required this.competenceId,
    required this.competenceName,
    required this.hasLessons,
  }) : super(key: key);

  @override
  State<LessonsListScreen> createState() => _LessonsListScreenState();
}

class _LessonsListScreenState extends State<LessonsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LessonProvider>().loadOrGenerateLessons(
        competenceId: widget.competenceId,
        hasLessons: widget.hasLessons,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LessonProvider>();
    final state = provider.state;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(widget.competenceName, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.regenerateLessons(competenceId: widget.competenceId),
          ),
        ],
      ),
      body: _buildBody(state, provider),
    );
  }

  Widget _buildBody(LessonState state, LessonProvider provider) {
    if (state.isLoading || state.isGenerating) {
      return LessonStatusView(state: state);
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.error!),
            ElevatedButton(
              onPressed: () => provider.clearError(),
              child: const Text("Réessayer"),
            ),
          ],
        ),
      );
    }

    if (!state.hasLessons) {
      return const Center(child: Text("Aucune leçon trouvée"));
    }

    return Column(
      children: [
        // LessonHeader(state: state),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.lessons.length,
            itemBuilder: (context, index) {
              final lesson = state.lessons[index];
              return LessonCardV2(lesson: lesson, index: index);
            },
          ),
        ),
      ],
    );
  }
}
