// lib/presentation/screens/exercises/adaptive_exercise_page.dart

import 'package:flutter/material.dart';
import 'package:front/data/models/exercise_model.dart';
import 'package:front/data/models/exercise_submission.dart';
import 'package:front/presentation/provider/emotion_provider.dart';
import 'package:front/presentation/screens/dashboard/widgets/emotion_camera_widget.dart';
import 'package:provider/provider.dart';
import 'package:front/presentation/provider/adaptive_exercise_provider.dart';

class AdaptiveExercisePage extends StatefulWidget {
  final String competenceId;
  final String competenceName;
  final String userId;
  final int count;

  const AdaptiveExercisePage({
    Key? key,
    required this.competenceId,
    required this.competenceName,
    required this.userId,
    required this.count,
  }) : super(key: key);

  @override
  State<AdaptiveExercisePage> createState() => _AdaptiveExercisePageState();
}

class _AdaptiveExercisePageState extends State<AdaptiveExercisePage> {
  // ══════════════════════════════════════════════════════════════
  // VARIABLES D'ÉTAT
  // ══════════════════════════════════════════════════════════════

  // ── Réponses ──
  String? _selectedAnswer;
  List<String> _selectedMultipleAnswers = [];

  // ── Résultat ──
  bool _showResult = false;
  bool _isCorrect = false;
  String _feedbackMessage = '';

  // ── Performance ──
  int _hintsShown = 0;
  DateTime? _exerciseStartTime;
  int _timeSpentSeconds = 0;

  // ── Soumission ──
  bool _isSubmitting = false;

  // ══════════════════════════════════════════════════════════════
  // 🧪 MODE TEST
  // ══════════════════════════════════════════════════════════════

  /// Mettre à true pour utiliser les exercices mock (rapide)
  /// Mettre à false pour utiliser la vraie API (lent)
  final bool _useMockData = true;

  // ══════════════════════════════════════════════════════════════
  // 🧪 MOCK EXERCISES DATA
  // ══════════════════════════════════════════════════════════════

  List<AdaptiveExerciseModel>? _mockExercises;
  int _mockCurrentIndex = 0;

  // ══════════════════════════════════════════════════════════════
  // CYCLE DE VIE
  // ══════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_useMockData) {
        // _loadMockExercises();
        _generateExercises();
      } else {
        _generateExercises();
      }
    });
  }

  // ══════════════════════════════════════════════════════════════
  // 🧪 MOCK DATA METHODS
  // ══════════════════════════════════════════════════════════════

  /// Charge des exercices factices pour tester rapidement
  void _loadMockExercises() {
    print('🧪 ══════════════════════════════════════════════════════');
    print('🧪 CHARGEMENT DES EXERCICES MOCK');
    print('🧪 ══════════════════════════════════════════════════════');

    _mockExercises = _createMockExercises();
    _mockCurrentIndex = 0;

    _initializeExercise();

    setState(() {});

    print('✅ ${_mockExercises!.length} exercices MOCK chargés');
  }

  /// Crée 3 exercices factices pour les tests
  List<AdaptiveExerciseModel> _createMockExercises() {
    return [
      // ── Exercice 1 : QCM simple ──
      AdaptiveExerciseModel(
        id: '69caafdea4cc4294998499eb',
        // competenceId: widget.competenceId,
        type: 'vrai_faux',
        question: 'La Terre est plate.',
        options: ['Vrai', 'Faux'],
        // correctAnswer: 'Faux',
        hints: ['Pensez aux photos de la NASA et aux voyages spatiaux !'],
        difficulty: 0.2,
        estimatedTime: 30,
      ),

      // AdaptiveExerciseModel(
      //   id: '69c9034a9c9b32a1d9fff2a0',
      //   // competenceId: widget.competenceId,
      //   type: 'vrai_faux',
      //   question:
      //       'Un module Python peut être importé à plusieurs endroits dans le code',
      //   options: ['Vrai', 'Faux'],
      //   // correctAnswer: 'Faux',
      //   hints: ['Pensez aux implications de la circularité des imports'],
      //   difficulty: 0.1,
      //   estimatedTime: 30,
      // ),

      // AdaptiveExerciseModel(
      //   id: '69c904399c9b32a1d9fff2a1',
      //   // competenceId: widget.competenceId,
      //   type: 'texte_a_trous',
      //   question:
      //       'Créez un module avec une fonction pour multiplier deux nombres et utilisez-le dans votre code principal.',
      //   options: [],
      //   // correctAnswer: ['Python', 'Java', 'JavaScript'],
      //   hints: [
      //     'Définissez un module avec la commande `def`.',
      //     'Utilisez la commande `return` pour retourner la valeur de la fonction.',
      //   ],
      //   difficulty: 0.5,
      //   estimatedTime: 90,
      // ),
    ];
  }

  /// Retourne l'exercice mock actuel
  AdaptiveExerciseModel? get _currentMockExercise {
    if (_mockExercises == null || _mockExercises!.isEmpty) return null;
    if (_mockCurrentIndex >= _mockExercises!.length) return null;
    return _mockExercises![_mockCurrentIndex];
  }

  /// Passe à l'exercice mock suivant
  void _nextMockExercise() {
    if (_mockCurrentIndex < _mockExercises!.length - 1) {
      setState(() {
        _mockCurrentIndex++;
      });
      _resetExerciseState();
    }
  }

  /// Revient à l'exercice mock précédent
  void _previousMockExercise() {
    if (_mockCurrentIndex > 0) {
      setState(() {
        _mockCurrentIndex--;
      });
      _resetExerciseState();
    }
  }

  // ══════════════════════════════════════════════════════════════
  // MÉTHODES PRINCIPALES
  // ══════════════════════════════════════════════════════════════

  /// Génère les exercices au démarrage (vraie API)
  Future<void> _generateExercises() async {
    final provider = context.read<AdaptiveExerciseProvider>();
    await provider.generateExercises(
      competenceId: widget.competenceId,
      userId: widget.userId,
      count: widget.count,
    );

    _initializeExercise();
  }

  /// Initialise l'état pour un nouvel exercice
  void _initializeExercise() {
    _exerciseStartTime = DateTime.now();
    _timeSpentSeconds = 0;
    context.read<EmotionProvider>().clearCaptures();

    print('🎯 Nouvel exercice initialisé - Timer démarré');
  }

  /// Calcule le temps passé sur l'exercice
  void _calculateTimeSpent() {
    if (_exerciseStartTime != null) {
      _timeSpentSeconds = DateTime.now()
          .difference(_exerciseStartTime!)
          .inSeconds;
      print('⏱️ Temps passé: ${_timeSpentSeconds}s');
    }
  }

  /// Réinitialise l'état pour le prochain exercice
  void _resetExerciseState() {
    setState(() {
      _selectedAnswer = null;
      _selectedMultipleAnswers = [];
      _showResult = false;
      _isCorrect = false;
      _feedbackMessage = '';
      _hintsShown = 0;
      _exerciseStartTime = DateTime.now(); // 🕐 Nouveau timer
      _timeSpentSeconds = 0;
      _isSubmitting = false;
    });
    context.read<EmotionProvider>().clearCaptures(); // 🎭 Reset émotions
  }

  /// Prépare les données complètes pour la soumission
  ExerciseSubmissionModel _prepareSubmissionData() {
    final emotionProvider = context.read<EmotionProvider>();

    // Récupérer l'exercice selon le mode
    AdaptiveExerciseModel? exercise;
    String currentZone = 'zpd';
    double currentMastery = 0.5;

    if (_useMockData) {
      exercise = _currentMockExercise;
    } else {
      final exerciseProvider = context.read<AdaptiveExerciseProvider>();
      exercise = exerciseProvider.state.currentExercise;

      final saintContext = exerciseProvider.state.saintContext;
      currentZone = saintContext?.zone ?? 'zpd';

      if (saintContext?.masteryPercentage != null) {
        final masteryStr = saintContext!.masteryPercentage.replaceAll('%', '');
        currentMastery = (double.tryParse(masteryStr) ?? 50.0) / 100.0;
      }
    }

    if (exercise == null) {
      throw Exception('Aucun exercice actuel');
    }

    // Préparer la réponse
    dynamic answer;
    if (_selectedMultipleAnswers.isNotEmpty) {
      answer = List<String>.from(_selectedMultipleAnswers);
    } else {
      answer = _selectedAnswer ?? '';
    }

    // Données émotionnelles
    final emotionData = emotionProvider.prepareEmotionSubmissionData();

    final submission = ExerciseSubmissionModel(
      userId: widget.userId,
      exerciseId: exercise.id,
      competenceId: widget.competenceId,
      answer: answer,
      isCorrect: null,
      timeSpentSeconds: _timeSpentSeconds,
      hintsUsed: _hintsShown,
      attemptNumber: 1,
      emotionData: emotionData,
      currentZpdZone: currentZone,
      currentMasteryLevel: currentMastery,
    );

    return submission;
  }

  /// Soumet la réponse au backend
  Future<void> _submitAnswer() async {
    _calculateTimeSpent();
    setState(() => _isSubmitting = true);

    try {
      final submission = _prepareSubmissionData();

      // ══════════════════════════════════════════════════════════
      // 📤 AFFICHER LE JSON ENVOYÉ
      // ══════════════════════════════════════════════════════════
      print('\n');
      print('╔══════════════════════════════════════════════════════════╗');
      print('║  📤 JSON ENVOYÉ AU BACKEND                               ║');
      print('╠══════════════════════════════════════════════════════════╣');

      final jsonData = submission.toJson();
      jsonData.forEach((key, value) {
        if (value is Map) {
          print('║  $key:');
          value.forEach((k, v) {
            print('║    • $k: $v');
          });
        } else if (value is List) {
          print('║  $key: [${value.join(", ")}]');
        } else {
          print('║  $key: $value');
        }
      });

      print('╚══════════════════════════════════════════════════════════╝');
      print('\n');

      // ══════════════════════════════════════════════════════════
      // 🌐 ENVOYER AU BACKEND
      // ══════════════════════════════════════════════════════════
      final exerciseProvider = context.read<AdaptiveExerciseProvider>();
      final result = await exerciseProvider.submitAnswerWithEmotion(submission);

      // ══════════════════════════════════════════════════════════
      // 📥 AFFICHER LA RÉPONSE REÇUE
      // ══════════════════════════════════════════════════════════
      print('\n');
      print('╔══════════════════════════════════════════════════════════╗');
      print('║  📥 RÉPONSE REÇUE DU BACKEND                             ║');
      print('╠══════════════════════════════════════════════════════════╣');

      result.forEach((key, value) {
        if (value is Map) {
          print('║  $key:');
          value.forEach((k, v) {
            print('║    • $k: $v');
          });
        } else {
          print('║  $key: $value');
        }
      });

      print('╚══════════════════════════════════════════════════════════╝');
      print('\n');

      // ══════════════════════════════════════════════════════════
      // ✅ TRAITER LA RÉPONSE
      // ══════════════════════════════════════════════════════════

      // Extraire is_correct (au niveau racine)
      final isCorrect = result['is_correct'] as bool? ?? false;

      // Extraire decision (contient toutes les infos)
      final decision = result['decision'] as Map<String, dynamic>?;

      if (decision != null) {
        // Extraire les données de decision
        final status = decision['status'] as String? ?? '';
        final responseType = decision['response_type'] as String? ?? '';
        final message = decision['message'] as String? ?? '';
        final encouragement = decision['encouragement'] as String? ?? '';

        // Extraire next_step
        final nextStep = decision['next_step'] as Map<String, dynamic>?;
        final action = nextStep?['action'] as String? ?? '';
        final difficulty = nextStep?['difficulty'] as double? ?? 0.5;
        final difficultyDirection =
            nextStep?['difficulty_direction'] as String? ?? '';
        final sameCompetence = nextStep?['same_competence'] as bool? ?? true;

        // Extraire ui
        final ui = decision['ui'] as Map<String, dynamic>?;
        final showEncouragement = ui?['show_encouragement'] as bool? ?? false;
        final showHint = ui?['show_hint'] as bool? ?? false;
        final autoProceed = ui?['auto_proceed'] as bool? ?? false;
        final delaySeconds = ui?['delay_seconds'] as int? ?? 3;

        // Mettre à jour l'UI
        // setState(() {
        //   _showResult = true;
        //   _isCorrect = isCorrect;
        //   _feedbackMessage = message;
        //   _encouragementMessage = encouragement;
        //   _responseType = responseType;
        //   _nextAction = action;
        //   _isSubmitting = false;
        // });

        // Logs détaillés
        print('✅ Soumission réussie !');
        print('   ➜ Correct: $isCorrect');
        print('   ➜ Status: $status');
        print('   ➜ Response Type: $responseType');
        print('   ➜ Message: $message');
        print('   ➜ Encouragement: $encouragement');
        print('   ➜ Next Action: $action');
        print('   ➜ Difficulty: $difficulty ($difficultyDirection)');
        print('   ➜ Same Competence: $sameCompetence');
        print('   ➜ Auto Proceed: $autoProceed (delay: ${delaySeconds}s)');

        // Gérer les actions spéciales selon response_type
        _handleDecisionAction(
          responseType: responseType,
          message: message,
          encouragement: encouragement,
          autoProceed: autoProceed,
          delaySeconds: delaySeconds,
          showHint: showHint,
        );
      } else {
        // Pas de decision, juste afficher le résultat
        setState(() {
          _showResult = true;
          _isCorrect = isCorrect;
          _feedbackMessage = isCorrect ? 'Bonne réponse !' : 'Mauvaise réponse';
          _isSubmitting = false;
        });
      }
    } catch (e) {
      print('❌ Erreur soumission: $e');

      setState(() => _isSubmitting = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  /// Gère les actions selon le type de décision
  void _handleDecisionAction({
    required String responseType,
    required String message,
    required String encouragement,
    required bool autoProceed,
    required int delaySeconds,
    required bool showHint,
  }) {
    switch (responseType) {
      case 'take_break':
      case 'pause':
        // Recommander une pause
        _showPauseDialog(message);
        break;

      case 'next_competence':
        // Passer à la compétence suivante
        _showSuccessDialog(message, encouragement);
        break;

      case 'adapt_difficulty':
        if (autoProceed) {
          // _showAdaptDialog(message, encouragement, delaySeconds);
          Future.delayed(Duration(seconds: delaySeconds), () {
            // ✅ Vérifie que le widget est toujours monté ET que l'utilisateur n'a pas quitté
            if (!mounted || _showResult) return;
            _goToNextExercise();
          });
        } else {
          // 🔘 Si autoProceed = false, affiche un bouton "Suivant" manuel
          // setState(() {
          //   _showManualNextButton = true;
          // });
        }
        break;

      case 'next_exercise':
        if (autoProceed) {
          _showAdaptDialog(message, encouragement, delaySeconds);
          Future.delayed(Duration(seconds: delaySeconds), () {
            // ✅ Vérifie que le widget est toujours monté ET que l'utilisateur n'a pas quitté
            if (!mounted || _showResult) return;
            _goToNextExercise();
          });
        } else {
          // 🔘 Si autoProceed = false, affiche un bouton "Suivant" manuel
          // setState(() {
          //   _showManualNextButton = true;
          // });
        }
        break;

      default:
        // Aucune action spéciale
        break;
    }
  }

  /// Dialogue pour adapter la difficulté
  void _showAdaptDialog(
    String message,
    String encouragement,
    int delaySeconds,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.auto_fix_high, color: Colors.blue, size: 32),
            SizedBox(width: 12),
            Text('Adaptation'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (encouragement.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        encouragement,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _goToNextExercise();
            },
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }

  /// Dialogue de succès (compétence maîtrisée)
  void _showSuccessDialog(String message, String encouragement) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.emoji_events, color: Colors.amber, size: 32),
            SizedBox(width: 12),
            Text('Bravo ! 🎉'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            if (encouragement.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                encouragement,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Navigator.pop(context);
              // Navigator.pop(context); // Retour au menu
                  final provider = context.read<AdaptiveExerciseProvider>();
                  final subjectId = provider.state.currentSubjectId;
                  final hasCurriculum = provider.state.hasCurriculum;
              Navigator.pushReplacementNamed(
                  context,
                  '/curriculum',
                  arguments: {
                    'subjectId': subjectId,
                    'hasCurriculum': hasCurriculum,
                  },
                );
            },
            child: const Text('Terminer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Charger la prochaine compétence
            },
            child: const Text('Compétence suivante'),
          ),
        ],
      ),
    );
  }

  /// Passe à l'exercice suivant
  void _goToNextExercise() {
    if (_useMockData) {
      // Mode test
      // if (_mockCurrentIndex < _mockExercises!.length - 1) {
      //   _nextMockExercise(); // Incrémente l'index + reset state
      // } else {
      //   Navigator.pop(context); // Fin de la session
      // }
      final provider = context.read<AdaptiveExerciseProvider>();

      if (!provider.state.isLastExercise) {
        _resetExerciseState(); // 🔁 Réinitialise les réponses, timer, etc.
        provider.nextExerciseContent(); // 📡 Change l'exercice dans le provider
      } else {
        Navigator.pop(context); // ✅ Session terminée
      }
    } else {
      // Mode réel avec Provider
      final provider = context.read<AdaptiveExerciseProvider>();

      if (!provider.state.isLastExercise) {
        _resetExerciseState(); // 🔁 Réinitialise les réponses, timer, etc.
        provider.nextExerciseContent(); // 📡 Change l'exercice dans le provider
      } else {
        Navigator.pop(context); // ✅ Session terminée
      }
    }
  }

  /// Affiche le dialogue de pause
  void _showPauseDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.pause_circle, color: Colors.orange, size: 32),
            SizedBox(width: 12),
            Text('Pause recommandée'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message.isNotEmpty ? message : 'Tu as bien travaillé !'),
            const SizedBox(height: 16),
            const Text(
              'Prends quelques minutes pour te reposer 😊',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Arrêter pour aujourd\'hui'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // BUILD PRINCIPAL
  // ══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.competenceName),
        actions: [
          // 🧪 Badge MODE TEST
          if (_useMockData)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '🧪 TEST',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

          // Progression
          if (_useMockData && _mockExercises != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${_mockCurrentIndex + 1} / ${_mockExercises!.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else
            Consumer<AdaptiveExerciseProvider>(
              builder: (context, provider, _) {
                if (provider.state.hasExercises) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        provider.state.progressText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          // Contenu principal
          _useMockData ? _buildMockContent() : _buildRealContent(),

          // Caméra flottante
          const DraggableEmotionCamera(),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 🧪 CONTENU MODE MOCK
  // ══════════════════════════════════════════════════════════════

  Widget _buildMockContent() {
    if (_mockExercises == null || _mockExercises!.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final exercise = _currentMockExercise;
    if (exercise == null) {
      return const Center(child: Text('Aucun exercice'));
    }

    return Column(
      children: [
        // Barre de progression
        _buildMockProgressBar(),

        // Badge SAINT+ Mock
        _buildMockSaintContextBadge(),

        // Contenu scrollable
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildExerciseHeader(exercise),
                const SizedBox(height: 16),
                _buildQuestion(exercise),
                const SizedBox(height: 24),
                _buildAnswerOptions(exercise),
                const SizedBox(height: 16),
                if (exercise.hints.isNotEmpty) _buildHints(exercise),
                const SizedBox(height: 24),
                if (_showResult) _buildResult(),
              ],
            ),
          ),
        ),

        // Boutons d'action
        _buildMockActionButtons(),
      ],
    );
  }

  Widget _buildMockProgressBar() {
    final progress = (_mockCurrentIndex + 1) / _mockExercises!.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 4),
          Text(
            'Exercice ${_mockCurrentIndex + 1} sur ${_mockExercises!.length}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMockSaintContextBadge() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.psychology, size: 16, color: Colors.blue),
          const SizedBox(width: 6),
          Text(
            'Zone: ZPD • Maîtrise: 65% (Mock)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Bouton précédent
          if (_mockCurrentIndex > 0 && !_showResult)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previousMockExercise,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Précédent'),
              ),
            ),

          if (_mockCurrentIndex > 0 && !_showResult) const SizedBox(width: 12),

          // Bouton valider ou suivant
          Expanded(
            flex: 2,
            child: _showResult
                ? _buildMockNextButton()
                : _buildValidateButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildMockNextButton() {
    final isLast = _mockCurrentIndex >= _mockExercises!.length - 1;

    return ElevatedButton.icon(
      onPressed: () {
        if (isLast) {
          Navigator.pop(context);
        } else {
          _nextMockExercise();
        }
      },
      icon: Icon(isLast ? Icons.check : Icons.arrow_forward),
      label: Text(isLast ? 'Terminer' : 'Suivant'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // CONTENU MODE RÉEL (API)
  // ══════════════════════════════════════════════════════════════

  Widget _buildRealContent() {
    return Consumer<AdaptiveExerciseProvider>(
      builder: (context, provider, _) {
        final state = provider.state;

        if (state.isGenerating) {
          return _buildGeneratingState(state.statusMessage);
        }

        if (state.error != null) {
          return _buildErrorState(state.error!, provider);
        }

        if (state.hasExercises && state.currentExercise != null) {
          return _buildExerciseContent(state, provider);
        }

        return const Center(child: Text('Aucun exercice disponible'));
      },
    );
  }

  Widget _buildGeneratingState(String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              '🤖 L\'IA analyse votre niveau et crée des exercices personnalisés.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, AdaptiveExerciseProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
                _generateExercises();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseContent(
    AdaptiveExerciseState state,
    AdaptiveExerciseProvider provider,
  ) {
    final exercise = state.currentExercise!;

    return Column(
      children: [
        _buildProgressBar(state),
        if (state.saintContext != null)
          _buildSaintContextBadge(state.saintContext!),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildExerciseHeader(exercise),
                const SizedBox(height: 16),
                _buildQuestion(exercise),
                const SizedBox(height: 24),
                _buildAnswerOptions(exercise),
                const SizedBox(height: 16),
                if (exercise.hints.isNotEmpty) _buildHints(exercise),
                const SizedBox(height: 24),
                if (_showResult) _buildResult(),
              ],
            ),
          ),
        ),
        _buildActionButtons(state, provider),
      ],
    );
  }

  Widget _buildProgressBar(AdaptiveExerciseState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: state.progressPercentage,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 4),
          Text(
            'Exercice ${state.currentIndex} sur ${state.totalExercises}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSaintContextBadge(SAINTContextModel context) {
    final zoneColors = {
      'mastered': Colors.green,
      'zpd': Colors.blue,
      'frustration': Colors.orange,
    };
    final color = zoneColors[context.zone] ?? Colors.grey;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.psychology, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            'Zone: ${context.zone.toUpperCase()} • Maîtrise: ${context.masteryPercentage}',
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // WIDGETS COMMUNS
  // ══════════════════════════════════════════════════════════════

  Widget _buildExerciseHeader(AdaptiveExerciseModel exercise) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            exercise.typeFormatted,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.timer, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                exercise.estimatedTimeFormatted,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestion(AdaptiveExerciseModel exercise) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        exercise.question,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildAnswerOptions(AdaptiveExerciseModel exercise) {
    if (exercise.type == 'qcm_multiple') {
      return _buildMultipleChoiceOptions(exercise);
    } else if (exercise.isQCM) {
      return _buildSingleChoiceOptions(exercise);
    } else if (exercise.type == 'texte_a_trous') {
      return _buildTextInput(exercise);
    } else if (exercise.isCodeExercise) {
      return _buildCodeEditor(exercise);
    }

    return const SizedBox.shrink();
  }

  Widget _buildSingleChoiceOptions(AdaptiveExerciseModel exercise) {
    return Column(
      children: exercise.options.map((option) {
        final isSelected = _selectedAnswer == option;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: _showResult
                ? null
                : () {
                    setState(() {
                      _selectedAnswer = option;
                    });
                  },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: isSelected ? Colors.blue : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultipleChoiceOptions(AdaptiveExerciseModel exercise) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sélectionnez plusieurs réponses :',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        ...exercise.options.map((option) {
          final isSelected = _selectedMultipleAnswers.contains(option);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: _showResult
                  ? null
                  : () {
                      setState(() {
                        if (isSelected) {
                          _selectedMultipleAnswers.remove(option);
                        } else {
                          _selectedMultipleAnswers.add(option);
                        }
                      });
                    },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.shade50 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: isSelected ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTextInput(AdaptiveExerciseModel exercise) {
    return TextField(
      enabled: !_showResult,
      onChanged: (value) {
        setState(() {
          _selectedAnswer = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Entrez votre réponse...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      maxLines: 3,
    );
  }

  Widget _buildCodeEditor(AdaptiveExerciseModel exercise) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (exercise.codeTemplate != null && exercise.codeTemplate!.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              exercise.codeTemplate!,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: Colors.greenAccent,
              ),
            ),
          ),
        const SizedBox(height: 12),
        TextField(
          enabled: !_showResult,
          onChanged: (value) {
            setState(() {
              _selectedAnswer = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Écrivez votre code ici...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
          maxLines: 8,
          style: const TextStyle(fontFamily: 'monospace'),
        ),
      ],
    );
  }

  Widget _buildHints(AdaptiveExerciseModel exercise) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () {
            if (_hintsShown < exercise.hints.length) {
              setState(() {
                _hintsShown++;
              });
            }
          },
          icon: const Icon(Icons.lightbulb_outline, size: 18),
          label: Text(
            _hintsShown == 0
                ? 'Afficher un indice'
                : 'Indice suivant (${_hintsShown}/${exercise.hints.length})',
          ),
        ),
        if (_hintsShown > 0)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < _hintsShown; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb,
                          size: 16,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            exercise.hints[i],
                            style: TextStyle(color: Colors.amber.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildResult() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isCorrect ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _isCorrect ? Colors.green : Colors.red),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isCorrect ? Icons.check_circle : Icons.cancel,
                color: _isCorrect ? Colors.green : Colors.red,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _isCorrect ? 'Bonne réponse ! 🎉' : 'Mauvaise réponse 😕',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isCorrect
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
          if (_feedbackMessage.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              _feedbackMessage,
              style: TextStyle(
                fontSize: 14,
                color: _isCorrect ? Colors.green.shade600 : Colors.red.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    AdaptiveExerciseState state,
    AdaptiveExerciseProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (state.canGoPrevious && !_showResult)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  _resetExerciseState();
                  provider.previousExercise();
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Précédent'),
              ),
            ),

          if (state.canGoPrevious && !_showResult) const SizedBox(width: 12),

          Expanded(
            flex: 2,
            child: _showResult
                ? _buildNextButton(state, provider)
                : _buildValidateButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(
    AdaptiveExerciseState state,
    AdaptiveExerciseProvider provider,
  ) {
    return ElevatedButton.icon(
      onPressed: () {
        if (state.isLastExercise) {
          Navigator.pop(context);
        } else {
          _resetExerciseState();
          provider.nextExercise();
        }
      },
      icon: Icon(state.isLastExercise ? Icons.check : Icons.arrow_forward),
      label: Text(state.isLastExercise ? 'Terminer' : 'Suivant'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildValidateButton() {
    final bool hasAnswer =
        _selectedAnswer != null || _selectedMultipleAnswers.isNotEmpty;

    return ElevatedButton.icon(
      onPressed: hasAnswer && !_isSubmitting ? _submitAnswer : null,
      icon: _isSubmitting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.check),
      label: Text(_isSubmitting ? 'Envoi...' : 'Valider'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        disabledBackgroundColor: Colors.grey.shade400,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
