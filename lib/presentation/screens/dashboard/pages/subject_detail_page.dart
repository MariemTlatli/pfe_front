import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:front/presentation/provider/discovery_provider.dart';

class SubjectDetailPage extends StatefulWidget {
  final String subjectId;
  final String userId;

  const SubjectDetailPage({Key? key, required this.subjectId, required this.userId}) : super(key: key);

  @override
  State<SubjectDetailPage> createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends State<SubjectDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscoveryProvider>().selectSubject(widget.subjectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<DiscoveryProvider>();
    final provider = notifier.state;
    final subject = provider.selectedSubject;
    final detail = provider.selectedSubjectDetail;

    if (subject == null || provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Extract progress data safely
    final progress = detail?.progress ?? {};
    final percentage = (progress['percentage'] as num?)?.toDouble() ?? 0.0;
    final totalComp = progress['total_competences'] as int? ?? 0;
    final compCount = subject.competencesCount > 0 ? subject.competencesCount : totalComp;

    return Scaffold(
      appBar: AppBar(
        title: Text(subject.name),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => notifier.selectSubject(widget.subjectId)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Domain Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: Text(subject.domainName, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(height: 12),
            Text(subject.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (subject.description != null)
              Text(subject.description!, style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5)),
            const SizedBox(height: 24),
            
            // Stats Row
            Row(
              children: [
                _statCard(Icons.book, '$compCount Competences'),
                const SizedBox(width: 12),
                _statCard(Icons.timeline, subject.hasCurriculum ? 'Curriculum' : 'En preparation'),
              ],
            ),
            const SizedBox(height: 24),
            
            // Progress Section
            const Text('Progression globale', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: Colors.grey[50],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${(percentage * 100).toInt()}% complete', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                        Text('${progress['completed_competences'] ?? 0}/$totalComp competences', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      color: Colors.blue,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // CTA or Next Tasks
            const Text('Parcours dapprentissage', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.blue.shade700, Colors.blue.shade900]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  const Icon(Icons.psychology, size: 54, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text(
                    'Pret a commencer ?',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Votre parcours est pret. Suivez le guide IA pour maitriser ce sujet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                       // Demo navigation
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade900,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Commencer la premiere lecon', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.blue, size: 24),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
