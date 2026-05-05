import 'package:flutter/material.dart';
import '../../../../data/models/subject_model.dart';
import 'enroll_button.dart';

class SubjectCardV2 extends StatelessWidget {
  final SubjectModel subject;
  final String userId;

  const SubjectCardV2({
    Key? key,
    required this.subject,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220, // Hauteur adaptée pour une carte UNO
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Image de fond (Carte UNO tournée horizontalement)
            Positioned.fill(
              child: RotatedBox(
                quarterTurns: 1, // Rotation de 90 degrés
                child: Image.asset(
                  'assets/images/carte.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // Overlay pour la lisibilité
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Contenu de la carte
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/curriculum-path',
                    arguments: {
                      'subjectId': subject.id,
                      'subjectName': subject.name,
                      'userId': userId,
                      'hasCurriculum': subject.hasCurriculum
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              subject.name.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.black,
                                    offset: Offset(2, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Text(
                          subject.description ?? "Explorez ce domaine passionnant",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const Spacer(),
                      EnrollButton(subject: subject, userId: userId),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
