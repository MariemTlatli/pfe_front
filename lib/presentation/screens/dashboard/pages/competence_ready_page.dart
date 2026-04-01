import 'package:flutter/material.dart';
import 'package:front/presentation/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:front/presentation/provider/zpd_provider.dart';
import 'package:front/data/models/zpd_models.dart';

class CompetenceReadyPage extends StatefulWidget {
  final String competenceId;
  final String competenceName;
  final String userId;

  const CompetenceReadyPage({
    Key? key,
    required this.competenceId,
    required this.competenceName,
    required this.userId,
  }) : super(key: key);

  @override
  State<CompetenceReadyPage> createState() => _CompetenceReadyPageState();
}

class _CompetenceReadyPageState extends State<CompetenceReadyPage> {
  @override
  void initState() {
    super.initState();
    // Chargement initial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalysis();
    });
  }

  Future<void> _loadAnalysis() async {
    final provider = context.read<ZPDProvider>();
    
    // Force le rechargement depuis la base de données
    provider.clearAnalysis(); 
    
    await provider.analyzeCompetence(
      competenceId: widget.competenceId,
      userId: widget.userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.competenceName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser l\'analyse',
            onPressed: _loadAnalysis,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAnalysis,
        child: Consumer<ZPDProvider>(
          builder: (context, provider, _) {
            final state = provider.state;

            // Chargement initial seulement (si pas de données)
            if (state.isLoading && !state.hasAnalysis) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Analyse de votre niveau...'),
                  ],
                ),
              );
            }

            // Erreur
            if (state.error != null && !state.hasAnalysis) {
              return _buildErrorState(state.error!, provider);
            }

            // Analyse chargée (ou en cours mais avec anciennes données)
            if (state.hasAnalysis) {
              return Stack(
                children: [
                  _buildAnalysisContent(state.analysis!),
                  if (state.isLoading)
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                ],
              );
            }

            // État vide
            return const Center(
              child: Text('Aucun exercice n\'a été fait pour cette compétence'),
            );
          },
        ),
      ),
    );
  }

  /// Widget d'erreur
  Widget _buildErrorState(String error, ZPDProvider provider) {
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
                _loadAnalysis();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  /// Contenu principal
  Widget _buildAnalysisContent(CompetenceZPDAnalysisModel analysis) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec zone ZPD
          _buildZoneHeader(analysis),

          const SizedBox(height: 24),

          // Niveau de maîtrise
          _buildMasteryCard(analysis),

          const SizedBox(height: 16),

          // Métriques SAINT+
          _buildSaintMetricsCard(analysis.saintMetrics),

          const SizedBox(height: 16),

          // Recommandations
          _buildRecommendationsCard(analysis),

          const SizedBox(height: 24),

          // Bouton d'action
          _buildActionButton(analysis),
        ],
      ),
    );
  }

  /// Header avec zone ZPD
  Widget _buildZoneHeader(CompetenceZPDAnalysisModel analysis) {
    final zoneColors = {
      'mastered': Colors.green,
      'zpd': Colors.blue,
      'frustration': Colors.orange,
    };
    final zoneIcons = {
      'mastered': Icons.check_circle,
      'zpd': Icons.school,
      'frustration': Icons.warning,
    };

    final color = zoneColors[analysis.effectiveZone] ?? Colors.grey;
    final icon = zoneIcons[analysis.effectiveZone] ?? Icons.help;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 64, color: color),
          const SizedBox(height: 12),
          Text(
            analysis.zoneLabel,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            analysis.description,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Card niveau de maîtrise
  Widget _buildMasteryCard(CompetenceZPDAnalysisModel analysis) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Votre niveau',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${(analysis.masteryLevel * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Maîtrise actuelle',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                _buildProgressRing(analysis.masteryLevel, analysis.thresholds),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: analysis.masteryLevel,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                analysis.masteryLevel >= analysis.thresholds.mastered
                    ? Colors.green
                    : analysis.masteryLevel >= analysis.thresholds.learning
                        ? Colors.blue
                        : Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Seuil apprentissage: ${(analysis.thresholds.learning * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'Maîtrise: ${(analysis.thresholds.mastered * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Anneau de progression
  Widget _buildProgressRing(double mastery, ZPDThresholdsModel thresholds) {
    final color = mastery >= thresholds.mastered
        ? Colors.green
        : mastery >= thresholds.learning
            ? Colors.blue
            : Colors.orange;

    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: mastery,
            strokeWidth: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Text(
            '${(mastery * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Card métriques SAINT+
  Widget _buildSaintMetricsCard(SAINTMetricsModel metrics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.psychology, size: 20),
                SizedBox(width: 8),
                Text(
                  'Analyse IA (SAINT+)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
              icon: Icons.speed,
              label: 'Probabilité de réussite',
              value: '${(metrics.pCorrect * 100).toStringAsFixed(0)}%',
              color: metrics.pCorrect >= 0.7
                  ? Colors.green
                  : metrics.pCorrect >= 0.4
                      ? Colors.orange
                      : Colors.red,
            ),
            const Divider(),
            _buildMetricRow(
              icon: Icons.replay,
              label: 'Tentatives estimées',
              value: '${metrics.estimatedAttempts.value}',
              subtitle: metrics.estimatedAttempts.label,
            ),
            const Divider(),
            _buildMetricRow(
              icon: Icons.lightbulb,
              label: 'Besoin d\'indice',
              value: metrics.hintProbability.level.toUpperCase(),
              color: metrics.hintProbability.level == 'fort'
                  ? Colors.orange
                  : metrics.hintProbability.level == 'moyen'
                      ? Colors.blue
                      : Colors.green,
            ),
            const Divider(),
            _buildMetricRow(
              icon: Icons.favorite,
              label: 'Engagement',
              value: metrics.engagement.level.toUpperCase(),
              subtitle: metrics.engagement.description,
            ),
            const Divider(),
            _buildMetricRow(
              icon: Icons.verified_user,
              label: 'Confiance analyse',
              value: metrics.confidence.level.toUpperCase(),
              subtitle: '${metrics.confidence.nInteractions} interactions',
            ),
          ],
        ),
      ),
    );
  }

  /// Ligne de métrique
  Widget _buildMetricRow({
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14)),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: (color ?? Colors.blue).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color ?? Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Card recommandations
  Widget _buildRecommendationsCard(CompetenceZPDAnalysisModel analysis) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.recommend, size: 20),
                SizedBox(width: 8),
                Text(
                  'Recommandations',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRecommendationItem(
              icon: Icons.fitness_center,
              label: 'Difficulté optimale',
              value: '${(analysis.optimalDifficulty * 100).toStringAsFixed(0)}%',
            ),
            const SizedBox(height: 12),
            _buildRecommendationItem(
              icon: Icons.format_list_numbered,
              label: 'Exercices minimum',
              value: '${analysis.difficultyParams.minExercises}',
            ),
            const SizedBox(height: 12),
            const Text(
              'Types d\'exercices recommandés :',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: analysis.recommendedExerciseTypes.map((type) {
                return Chip(
                  label: Text(type),
                  backgroundColor: Colors.blue.shade50,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Item de recommandation
  Widget _buildRecommendationItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 8),
        Text(label),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  /// Bouton d'action
  Widget _buildActionButton(CompetenceZPDAnalysisModel analysis) {
    final buttonColors = {
      'mastered': Colors.green,
      'zpd': Colors.blue,
      'frustration': Colors.orange,
    };
    final buttonTexts = {
      'mastered': 'Réviser les exercices',
      'zpd': 'Commencer les exercices',
      'frustration': 'Revoir les bases',
    };

    final color = buttonColors[analysis.effectiveZone] ?? Colors.blue;
    final text = buttonTexts[analysis.effectiveZone] ?? 'Continuer';

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          final authProvider = context.read<AuthProvider>();
          final userId = authProvider.userId;

          Navigator.pushNamed(
            context,
            '/adaptive-exercises',
            arguments: {
              'competenceId': widget.competenceId,
              'competenceName': widget.competenceName,
              'userId': userId,
              'count': analysis.difficultyParams.minExercises,
            },
          ).then((_) {
            // Recharger l'analyse quand on revient des exercices
            _loadAnalysis();
          });
        },
        icon: const Icon(Icons.play_arrow),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}