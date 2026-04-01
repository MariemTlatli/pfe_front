import 'package:flutter/material.dart';
import 'package:front/data/models/subject_model.dart';

class SubjectCard extends StatelessWidget {
  final SubjectModel subject;
  final VoidCallback onTap;
  final VoidCallback? onEnroll;
  final bool isLoading;
  final String userId;

  const SubjectCard({
    Key? key,
    required this.subject,
    required this.onTap,
    required this.userId,
    this.onEnroll,
    this.isLoading = false,
    
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isEnrolled = subject.isEnrolled;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isEnrolled ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isEnrolled ? Icons.check_circle : Icons.book,
                    color: isEnrolled ? Colors.green : Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    subject.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (subject.description != null)
              Text(
                subject.description!,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${subject.competencesCount} competences',
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
                if (isEnrolled && subject.progress != null)
                  Text(
                    '${(subject.progress! * 100).toInt()}% complete',
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : (isEnrolled ? onTap : onEnroll),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEnrolled ? Colors.blue : Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(isEnrolled ? 'Continuer' : 'Sinscrire'),
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (){
                  Navigator.pushReplacementNamed(
                                      context,
                                      '/curriculum',
                                     arguments: {
                                                  'subjectId': subject.id,
                                                  'hasCurriculum': subject.hasCurriculum, // ← NOUVEAU
                                                },
                                    );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEnrolled ? Colors.blue : Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text("GO"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
