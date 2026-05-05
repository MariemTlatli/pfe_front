import 'package:flutter/material.dart';
import 'package:front/presentation/provider/curriculum_provider.dart';
import 'package:front/presentation/widgets/uno_button.dart';
import 'package:front/presentation/widgets/uno_card.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/curriculum_models.dart';
import 'dart:math' as math;

class CompetencePathWidget extends StatefulWidget {
  final String subjectId;
  final bool hasCurriculumInitial;
  final String userId;

  const CompetencePathWidget({
    Key? key,
    required this.subjectId,
    required this.hasCurriculumInitial,
    required this.userId,
  }) : super(key: key);

  @override
  State<CompetencePathWidget> createState() => _CompetencePathWidgetState();
}

class _CompetencePathWidgetState extends State<CompetencePathWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CurriculumProvider>().loadOrGenerateCurriculum(
        subjectId: widget.subjectId,
        hasCurriculum: widget.hasCurriculumInitial,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurriculumProvider>().state;

    if (state.isLoading) {
      return _buildLoading(state.statusMessage ?? "Chargement...");
    }

    if (state.isGenerating) {
      return _buildLoading(state.statusMessage ?? "Génération par l'IA...");
    }

    if (state.error != null) {
      return _buildError(state.error!);
    }

    if (state.curriculum == null) {
      return const Center(child: Text("Aucun curriculum disponible", style: TextStyle(color: Colors.white)));
    }

    final competences = state.curriculum!.competencesByLevel;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // The Winding Path (Road)
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width, competences.length * 150.0),
              painter: PathPainter(),
            ),
            // The Nodes (UNO Cards)
            Column(
              children: List.generate(competences.length, (index) {
                final competence = competences[index];
                return _buildPathNode(index, competence);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPathNode(int index, CurriculumCompetenceModel competence) {
    // Logic for zig-zag: even index left, odd index right
    final isLeft = index % 2 == 0;
    final alignment = isLeft ? Alignment.centerLeft : Alignment.centerRight;
    final padding = isLeft ? const EdgeInsets.only(left: 40) : const EdgeInsets.only(right: 40);

    return Container(
      height: 150,
      width: double.infinity,
      alignment: alignment,
      padding: padding,
      child: _buildUnoNode(competence, index + 1),
    );
  }

  Widget _buildUnoNode(CurriculumCompetenceModel competence, int number) {
    // UNO Colors cycle
    final colors = [Colors.red, Colors.blue, Colors.green, Colors.yellow[700]!];
    final color = colors[number % colors.length];

    return GestureDetector(
      onTap: () => _showCompetenceDetail(competence),
      child: Transform.rotate(
        angle: (number % 2 == 0 ? 1 : -1) * 0.05,
        child: Container(
          width: 100,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                // Inner White Oval (UNO Style)
                Center(
                  child: Transform.rotate(
                    angle: -0.5,
                    child: Container(
                      width: 60,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.elliptical(60, 80)),
                      ),
                    ),
                  ),
                ),
                // Number
                Center(
                  child: Text(
                    "$number",
                    style: TextStyle(
                      color: color,
                      fontSize: 40,
                      // fontWeight: FontWeight.black,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                // Small corner numbers
                Positioned(
                  top: 4,
                  left: 4,
                  child: Text("$number", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Transform.rotate(
                    angle: math.pi,
                    child: Text("$number", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 20),
          Text(message, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<CurriculumProvider>().regenerateCurriculum(subjectId: widget.subjectId),
              child: const Text("Réessayer la génération"),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompetenceDetail(CurriculumCompetenceModel competence) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
      
      
       Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(227, 6, 126, 224),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child:
        
         Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                 UnoCard(
            height: 45,
            width: 220,
            label: competence.name,
            onTap: () {}, // Optional action
            content: Center(
              child: Text(
                competence.name,
                style: TextStyle(
                  color: Color(0xFF424242),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
                const Spacer(),

                Container(
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
      icon: const Icon(Icons.close, color: Colors.white),
      constraints: const BoxConstraints(
        minWidth: 40,
        minHeight: 40,
      ),
    ),
  ),
),
              ],
            ),
           const SizedBox(height: 8),
            Text(competence.description, style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: 15 , fontWeight: FontWeight.w400)),
            const SizedBox(height: 24),
             UnoButton(
                          label: "Démarrer cette étape",
                          isLoading: false,
                          isEnabled: true,
                          onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    '/lessons',
                    arguments: {
                      'competenceId': competence.id,
                      'competenceName': competence.name,
                      'hasLessons': competence.hasLessons,
                    },
                  );
                },
                        ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 4, 8, 107)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 35
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final stepHeight = 150.0;
    final totalSteps = (size.height / stepHeight).floor();
    
    // Start slightly below top
    path.moveTo(size.width / 2, 0);

    for (int i = 0; i < totalSteps; i++) {
        final isLeft = i % 2 == 0;
        final startX = isLeft ? 90.0 : size.width - 90.0;
        final endX = !isLeft ? 90.0 : size.width - 90.0;
        final startY = i * stepHeight + 75;
        final endY = (i + 1) * stepHeight + 75;

        if (i == 0) {
            path.quadraticBezierTo(size.width / 2, 75, startX, 75);
        }

        // Draw curve to next node
        path.quadraticBezierTo(
            isLeft ? size.width : 0, // Control point
            startY + stepHeight / 2,
            endX,
            endY
        );
    }

    // Draw a "dashed" or "dotted" effect for the road
    canvas.drawPath(path, paint);
    
    // Road marks
    final dashPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
      
    canvas.drawPath(path, dashPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
