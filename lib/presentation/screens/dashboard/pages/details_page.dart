import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:front/presentation/provider/curriculum_provider.dart';
import 'package:front/data/models/curriculum_models.dart';

class CurriculumPage extends StatefulWidget {
  final String subjectId;
  final bool hasCurriculum; // ← NOUVEAU

  const CurriculumPage({
    Key? key,
    required this.subjectId,
    required this.hasCurriculum, // ← NOUVEAU
  }) : super(key: key);

  @override
  State<CurriculumPage> createState() => _CurriculumPageState();
}

class _CurriculumPageState extends State<CurriculumPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurriculum();
    });
  }

  Future<void> _loadCurriculum() async {
    final provider = context.read<CurriculumProvider>();
    await provider.loadOrGenerateCurriculum(
      subjectId: widget.subjectId,
      hasCurriculum: widget.hasCurriculum, // ← NOUVEAU
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Curriculum'),
        actions: [
          Consumer<CurriculumProvider>(
            builder: (context, provider, _) {
              final isProcessing =
                  provider.state.isLoading || provider.state.isGenerating;
              return IconButton(
                onPressed: isProcessing
                    ? null
                    : () => provider.regenerateCurriculum(
                          subjectId: widget.subjectId,
                        ),
                icon: const Icon(Icons.refresh),
                tooltip: 'Régénérer le curriculum',
              );
            },
          ),
        ],
      ),
      body: Consumer<CurriculumProvider>(
        builder: (context, provider, _) {
          final state = provider.state;

          // État de génération (long)
          if (state.isGenerating) {
            return _buildGeneratingState(state.statusMessage);
          }

          // État de chargement (rapide)
          if (state.isLoading) {
            return _buildLoadingState(state.statusMessage);
          }

          // État d'erreur
          if (state.error != null) {
            return _buildErrorState(state.error!, provider);
          }

          // Curriculum chargé
          if (provider.state.stats?.totalCompetences != 0) {
            return _buildCurriculumContent(state);
          }

          // État vide
          return const Center(
            child: Text('Aucun curriculum disponible'),
          );
        },
      ),
    );
  }

  /// Widget de génération (long processus IA)
  Widget _buildGeneratingState(String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(strokeWidth: 6),
            ),
            const SizedBox(height: 32),
            Text(
              message ?? 'Génération en cours...',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              '🤖 L\'IA analyse la matière et crée les compétences.\nCette opération peut prendre plusieurs minutes.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Widget de chargement (rapide)
  Widget _buildLoadingState(String? message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            message ?? 'Chargement...',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  /// Widget d'erreur
  Widget _buildErrorState(String error, CurriculumProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              error,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                provider.clearError();
                _loadCurriculum();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  /// Contenu du curriculum
  Widget _buildCurriculumContent(CurriculumState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.stats != null) _buildStatsCard(state.stats!),
          const SizedBox(height: 16),
          const Text(
            'Compétences à acquérir',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...state.competencesByLevel.map(
            (competence) => _buildCompetenceCard(competence),
          ),
          
        ],
      ),
    );
  }

  Widget _buildStatsCard(CurriculumStatsModel stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aperçu du curriculum',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.school,
                  value: '${stats.totalCompetences}',
                  label: 'Compétences',
                ),
                _buildStatItem(
                  icon: Icons.trending_up,
                  value: '${stats.maxLevel}',
                  label: 'Niveaux',
                ),
                
              ],
            ),
            
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildCompetenceCard(CurriculumCompetenceModel competence) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: _buildLevelBadge(competence.level),
        title: Text(
          competence.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          competence.code,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(competence.description, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 16),
                _buildDifficultyInfo(competence.difficultyParams),
                const SizedBox(height: 12),
                if (competence.hasPrerequisites)
                  _buildPrerequisites(competence.prerequisites),
              SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (){
                Navigator.pushNamed(
                  context,
                  '/lessons',
                  arguments: {
                    'competenceId': competence.id,
                    'competenceName': competence.name,
                    'hasLessons': competence.hasLessons, // ← Du modèle mis à jour
                  },
                );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:  Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child:  Text("GO"),
              ),
            ),
              
              ],
              
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelBadge(int level) {
    final colors = [Colors.green, Colors.blue, Colors.orange, Colors.red, Colors.purple];
    final color = colors[(level - 1) % colors.length];

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '$level',
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildDifficultyInfo(DifficultyParamsModel params) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoChip(
            label: 'Difficulté',
            value: '${(params.baseDifficulty * 100).toStringAsFixed(0)}%',
          ),
          _buildInfoChip(label: 'Exercices min', value: '${params.minExercises}'),
          _buildInfoChip(label: 'Pour maîtriser', value: '${params.masteryExercises}'),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required String label, required String value}) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildPrerequisites(List<CurriculumPrerequisiteModel> prerequisites) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Prérequis :', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: prerequisites.map((prereq) {
            return Chip(
              avatar: const Icon(Icons.check_circle, size: 16),
              label: Text(
                '${prereq.competenceCode} - ${prereq.competenceName}',
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: Colors.blue.shade50,
            );
          }).toList(),
        ),
      ],
    );
  }
}