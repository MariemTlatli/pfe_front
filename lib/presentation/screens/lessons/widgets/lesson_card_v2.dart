import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/lesson_model.dart';
import '../../../provider/lesson_provider.dart';
import '../lesson_detail_screen.dart';

class LessonCardV2 extends StatelessWidget {
  final LessonModel lesson;
  final int index;

  const LessonCardV2({Key? key, required this.lesson, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.red, Colors.blue, Colors.green, Colors.yellow[700]!];
    final color = colors[index % colors.length];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 70,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 4)],
          ),
          child: Center(
            child: Text(
              "${lesson.order}",
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        title: Text(lesson.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text("${lesson.estimatedTime ?? 15} mins", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          final lessonProvider = context.read<LessonProvider>();
          lessonProvider.selectLesson(lesson);
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider.value(
                value: lessonProvider,
                child: LessonDetailScreen(
                  competenceId: lesson.competenceId, 
                  competenceName: lesson.title
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
