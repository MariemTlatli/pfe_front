import 'package:flutter/material.dart';
import 'package:front/presentation/widgets/uno_card.dart';
import 'widgets/competence_path_widget.dart';

class CurriculumPathScreen extends StatelessWidget {
  final String subjectId;
  final String subjectName;
  final String userId;
  final bool hasCurriculum;

  const CurriculumPathScreen({
    Key? key,
    required this.subjectId,
    required this.subjectName,
    required this.userId,
    required this.hasCurriculum,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          // Assurez-vous que le chemin correspond à l'endroit où vous avez sauvegardé l'image
          image: AssetImage('assets/images/auth_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: UnoCard(
            height: 45,
            width: 220,
            label:subjectName,
            onTap: () {}, // Optional action
            content: Center(
              child: Text(
               subjectName,
                style: TextStyle(
                  color: Color(0xFF424242),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),
            ),
          ), 
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Container(
  decoration: BoxDecoration(
    color: const Color(0xFFFF6B4A), // Orange/corail
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: Colors.white,
      width: 2,
    ),
  ),
  child: Center(
    child: IconButton(
      onPressed: () => Navigator.pop(context),
      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
      constraints: const BoxConstraints(
        minWidth: 40,
        minHeight: 40,
      ),
    ),
  ),
),
        ),
        body: CompetencePathWidget(
          subjectId: subjectId,
          hasCurriculumInitial: hasCurriculum,
          userId: userId,
        ),
      ),
    );
  }
}
