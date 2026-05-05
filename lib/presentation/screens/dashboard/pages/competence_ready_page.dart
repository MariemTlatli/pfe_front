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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.competenceName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.amber),
            tooltip: 'Actualiser l\'analyse',
            onPressed: _loadAnalysis,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/auth_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadAnalysis,
            color: Colors.amber,
            child: Consumer<ZPDProvider>(
              builder: (context, provider, _) {
                final state = provider.state;
    
                if (state.isLoading && !state.hasAnalysis) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.amber),
                        SizedBox(height: 16),
                        Text('Analyse de votre niveau par l\'IA...', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  );
                }
    
                if (state.error != null && !state.hasAnalysis) {
                  return _buildErrorState(state.error!, provider);
                }
    
                if (state.hasAnalysis) {
                  return Stack(
                    children: [
                      _buildAnalysisContent(state.analysis!),
                      if (state.isLoading)
                        const Positioned(
                          top: 0, left: 0, right: 0,
                          child: LinearProgressIndicator(minHeight: 2, backgroundColor: Colors.transparent, valueColor: AlwaysStoppedAnimation<Color>(Colors.amber)),
                        ),
                    ],
                  );
                }
    
                return const Center(
                  child: Text('Aucune donnée disponible', style: TextStyle(color: Colors.white70)),
                );
              },
            ),
          ),
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
    Color color;
    IconData icon;
    
    switch (analysis.effectiveZone.toLowerCase()) {
      case 'mastered':
        color = Colors.greenAccent;
        icon = Icons.check_circle;
        break;
      case 'frustration':
        color = Colors.orangeAccent;
        icon = Icons.warning;
        break;
      default:
        color = Colors.blueAccent;
        icon = Icons.psychology;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, size: 70, color: color),
          const SizedBox(height: 16),
          Text(
            analysis.zoneLabel.toUpperCase(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            analysis.description,
            style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Card niveau de maîtrise
  Widget _buildMasteryCard(CompetenceZPDAnalysisModel analysis) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.leaderboard, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Text(
                'Niveau de Maîtrise',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${(analysis.masteryLevel * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Progression actuelle',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ),
              _buildProgressRing(analysis.masteryLevel, analysis.thresholds),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: analysis.masteryLevel,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(
                analysis.masteryLevel >= analysis.thresholds.mastered
                    ? Colors.greenAccent
                    : analysis.masteryLevel >= analysis.thresholds.learning
                        ? Colors.blueAccent
                        : Colors.orangeAccent,
              ),
              minHeight: 10,
            ),
          ),
        ],
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology, size: 20, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                'Analyse IA (SAINT+)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMetricRow(
            icon: Icons.auto_awesome,
            label: 'Réussite prédite',
            value: '${(metrics.pCorrect * 100).toStringAsFixed(0)}%',
            color: metrics.pCorrect >= 0.7
                ? Colors.greenAccent
                : metrics.pCorrect >= 0.4
                    ? Colors.orangeAccent
                    : Colors.redAccent,
          ),
          const Divider(color: Colors.white10),
          _buildMetricRow(
            icon: Icons.history,
            label: 'Effort estimé',
            value: '${metrics.estimatedAttempts.value} ex.',
            subtitle: metrics.estimatedAttempts.label,
          ),
          const Divider(color: Colors.white10),
          _buildMetricRow(
            icon: Icons.help_outline,
            label: 'Aide nécessaire',
            value: metrics.hintProbability.level.toUpperCase(),
            color: metrics.hintProbability.level == 'fort'
                ? Colors.orangeAccent
                : metrics.hintProbability.level == 'moyen'
                    ? Colors.blueAccent
                    : Colors.greenAccent,
          ),
          const Divider(color: Colors.white10),
          _buildMetricRow(
            icon: Icons.bolt,
            label: 'Engagement',
            value: metrics.engagement.level.toUpperCase(),
            subtitle: metrics.engagement.description,
          ),
        ],
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.white54),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.white38),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (color ?? Colors.blueAccent).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: (color ?? Colors.blueAccent).withOpacity(0.2)),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color ?? Colors.blueAccent,
                fontSize: 13,
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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
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
            _loadAnalysis();
          });
        },
        icon: const Icon(Icons.play_circle_fill, size: 28),
        label: Text(text.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}