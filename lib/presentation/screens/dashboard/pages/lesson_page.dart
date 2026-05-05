import 'package:flutter/material.dart';
import 'package:front/presentation/provider/auth_provider.dart';
import 'package:front/presentation/widgets/uno_button.dart';
import 'package:front/presentation/widgets/uno_card.dart';
import 'package:provider/provider.dart';
import 'package:front/presentation/provider/lesson_provider.dart';
import 'package:front/data/models/lesson_model.dart';

class LessonsPage extends StatefulWidget {
  final String competenceId;
  final String competenceName;
  final bool hasLessons;

  const LessonsPage({
    Key? key,
    required this.competenceId,
    required this.competenceName,
    required this.hasLessons,
  }) : super(key: key);

  @override
  State<LessonsPage> createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLessons();
    });
  }

  Future<void> _loadLessons() async {
    final provider = context.read<LessonProvider>();
    await provider.loadOrGenerateLessons(
      competenceId: widget.competenceId,
      hasLessons: widget.hasLessons,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: UnoCard(
          height: 45,
          width: 220,
          label: widget.competenceName,
          onTap: () {}, // Optional action
          content: Center(
            child: Text(
              widget.competenceName,
              style: TextStyle(
                color: Color(0xFF424242),
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        actions: [
          Consumer<LessonProvider>(
            builder: (context, provider, _) {
              final isProcessing =
                  provider.state.isLoading || provider.state.isGenerating;
              return IconButton(
                onPressed: isProcessing
                    ? null
                    : () => provider.regenerateLessons(
                          competenceId: widget.competenceId,
                        ),
                icon: const Icon(Icons.refresh),
                tooltip: 'Régénérer les leçons',
              );
            },
          ),
        ],
      ),
      body: Consumer<LessonProvider>(
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

          // Leçons chargées
          if (state.hasLessons) {
            return _buildLessonsContent(state, provider);
          }

          // État vide
          return const Center(
            child: Text('Aucune leçon disponible'),
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
              '🤖 L\'IA crée des leçons personnalisées.\nCette opération peut prendre quelques minutes.',
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
  Widget _buildErrorState(String error, LessonProvider provider) {
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
                _loadLessons();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  /// Contenu des leçons
  Widget _buildLessonsContent(LessonState state, LessonProvider provider) {
    return UnoCard(
      height: double.infinity,
      width: double.infinity,
      label: widget.competenceName,
      onTap: () {}, // Optional action
      content: Column(
        children: [
        // Liste des leçons ou vue détaillée
        Expanded(
          child: _buildLessonDetail(state, provider)
              
        ),
        ],
      ),
    )
    
    ;
  }
  /// Vue détaillée d'une leçon
  Widget _buildLessonDetail(LessonState state, LessonProvider provider) {
    final lesson = state.selectedLesson!;

    return Column(
      children: [
        // Contenu de la leçon
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre
                Text(
                  lesson.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Durée estimée
                Row(
                  children: [
                    Icon(Icons.timer, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '${lesson.estimatedTime ?? 15} min',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Contenu Markdown (affiché comme texte pour l'instant)
                _buildMarkdownContent(lesson.content),
              ],
            ),
          ),
        ),

        // Bouton suivant en bas
        if (provider.canGoNext)
          UnoButton(
            label: 'Leçon suivante',
            isLoading: false,
            isEnabled: true,
            onPressed: () => provider.nextLesson(),
          ),

        // Container(
        //   width: double.infinity,
        //   padding: const EdgeInsets.all(16),
        //   child: ElevatedButton.icon(
        //     onPressed: () => provider.nextLesson(),
        //     icon: const Icon(Icons.arrow_forward),
        //     label: const Text('Leçon suivante'),
        //     style: ElevatedButton.styleFrom(
        //       padding: const EdgeInsets.symmetric(vertical: 16),
        //     ),
        //   ),
        // ),

        // Bouton terminer si dernière leçon
        // Bouton terminer si dernière leçon
if (!provider.canGoNext && state.selectedLesson != null)
  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    child: Consumer<AuthProvider>( // ← UTILISER AuthProvider
      builder: (context, authProvider, _) {
        final userId = authProvider.userId ?? '';

                return UnoButton(
                  label: "Passer aux exercices",
                  isLoading: false,
                  isEnabled: true,
                  onPressed: () {
            if (userId.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Erreur: utilisateur non connecté'),
                ),
              );
              return;
            }

            Navigator.pushReplacementNamed(
              context,
              '/competence-ready',
              arguments: {
                'competenceId': widget.competenceId,
                'competenceName': widget.competenceName,
                'userId': userId, // ← Depuis AuthProvider
              },
            );
                  },
                );
        
        
                //  ElevatedButton.icon(
                //   onPressed: () {
                //     if (userId.isEmpty) {
                //       ScaffoldMessenger.of(context).showSnackBar(
                //         const SnackBar(
                //           content: Text('Erreur: utilisateur non connecté'),
                //         ),
                //       );
                //       return;
                //     }

                //     Navigator.pushReplacementNamed(
                //       context,
                //       '/competence-ready',
                //       arguments: {
                //         'competenceId': widget.competenceId,
                //         'competenceName': widget.competenceName,
                //         'userId': userId, // ← Depuis AuthProvider
                //       },
                //     );
                //   },
                //   icon: const Icon(Icons.check_circle),
                //   label: const Text('Passer aux exercices'),
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.green,
                //     padding: const EdgeInsets.symmetric(vertical: 16),
                //   ),
                // );
      },
    ),
  ),
      ],
    );
  }

  /// Affichage du contenu Markdown (version simple)
  Widget _buildMarkdownContent(String content) {
    // Version simple : afficher comme texte
    // TODO: Utiliser flutter_markdown pour un meilleur rendu
    
    // Remplacer les éléments Markdown basiques
    final lines = content.split('\n');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        // Titre H1
        if (line.startsWith('# ')) {
          return Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              line.substring(2),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
        
        // Titre H2
        if (line.startsWith('## ')) {
          return Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Text(
              line.substring(3),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
        
        // Code block
        if (line.startsWith('```')) {
          return const SizedBox(height: 4);
        }
        
        // Liste
        if (line.startsWith('- ')) {
          return Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Text(
                    line.substring(2),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        }
        
        // Texte gras
        if (line.contains('**')) {
          return Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              line.replaceAll('**', ''),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }
        
        // Ligne vide
        if (line.trim().isEmpty) {
          return const SizedBox(height: 8);
        }
        
        // Texte normal
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            line,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        );
      }).toList(),
    );
  }
}