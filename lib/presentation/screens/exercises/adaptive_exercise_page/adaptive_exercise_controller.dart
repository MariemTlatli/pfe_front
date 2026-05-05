import 'dart:async';
import 'package:flutter/material.dart';
import 'package:front/data/models/exercise_model.dart';
import 'package:front/data/models/exercise_submission.dart';
import 'package:front/presentation/provider/adaptive_exercise_provider.dart';
import 'package:front/presentation/provider/emotion_provider.dart';
import 'package:front/presentation/screens/exercice_uno/widgets/plus_two_dialog.dart';
import 'package:front/presentation/screens/exercice_uno/widgets/skip_card_dialog.dart';
import 'package:provider/provider.dart';
import 'package:front/data/services/plus_two_reward_service.dart';
import 'package:front/data/services/skip_reward_service.dart';

enum DecisionActionType {
  none,
  takeBreak,
  nextCompetence,
  adaptDifficulty,
  nextExercise,
  plusTwoGain,
  skipGain,
  timeOut,
}

class DecisionEvent {
  final DecisionActionType actionType;
  final String message;
  final String encouragement;
  final bool autoProceed;
  final int delaySeconds;
  final bool showHint;
  final bool isPlusTwoGained;
  final bool isSkipGained;
  final Map<String, dynamic>? lootedCard;
  final String? nextCompetenceId;
  final double? recommendedDifficulty;
  final List<String>? recommendedExerciseTypes;
  final double? newMastery;
  final String? newZone;

  DecisionEvent({
    required this.actionType,
    required this.message,
    this.encouragement = '',
    this.autoProceed = false,
    this.delaySeconds = 0,
    this.showHint = false,
    this.isPlusTwoGained = false,
    this.isSkipGained = false,
    this.lootedCard,
    this.nextCompetenceId,
    this.recommendedDifficulty,
    this.recommendedExerciseTypes,
    this.newMastery,
    this.newZone,
  });
}

class AdaptiveExerciseController extends ChangeNotifier {
  final BuildContext context;
  String competenceId; // Modifié: enlevé 'final' pour permettre la transition
  final String userId;
  final int initialCount;

  AdaptiveExerciseController({
    required this.context,
    required this.competenceId,
    required this.userId,
    this.initialCount = 1,
  }) {
    _init();
  }

  // ── ÉTAT ──
  bool _isGenerating = true;
  bool get isGenerating => _isGenerating;

  List<AdaptiveExerciseModel> _exercises = [];
  int _currentIndex = 0;
  
  AdaptiveExerciseModel? get currentExercise {
    if (_exercises.isEmpty || _currentIndex >= _exercises.length) return null;
    return _exercises[_currentIndex];
  }

  int get currentIndex => _currentIndex;
  int get totalExercises => _exercises.length;

  String? _error;
  String? get error => _error;

  String? _selectedAnswer;
  String? get selectedAnswer => _selectedAnswer;

  List<String> _selectedMultipleAnswers = [];
  List<String> get selectedMultipleAnswers => _selectedMultipleAnswers;

  bool _showResult = false;
  bool get showResult => _showResult;

  bool _isCorrect = false;
  bool get isCorrect => _isCorrect;

  String _feedbackMessage = '';
  String get feedbackMessage => _feedbackMessage;

  int _hintsShown = 0;
  int get hintsShown => _hintsShown;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  // ── PERFORMANCE ──
  DateTime? _startTime;
  int _timeSpentSeconds = 0;

  // ── DÉCISION ──
  DecisionEvent? _currentEvent;
  DecisionEvent? get currentEvent => _currentEvent;

  // ── TIMER ──
  int _remainingSeconds = 0;
  int get remainingSeconds => _remainingSeconds;
  Timer? _timer;

  void startTimer() {
    _timer?.cancel();
    final exercise = currentExercise;
    if (exercise == null) return;

    // ✨ Lancement de la capture des émotions en même temps que le timer
    context.read<EmotionProvider>().setAnalysisEnabled(true);

    _remainingSeconds = exercise.estimatedTime;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _timer?.cancel();
        _handleTimeOut();
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    context.read<EmotionProvider>().setAnalysisEnabled(false);
  }

  void _handleTimeOut() {
    context.read<EmotionProvider>().setAnalysisEnabled(false);
    _showResult = true;
    _isCorrect = false;
    _feedbackMessage = "Temps écoulé ! Exercice raté.";
    _currentEvent = DecisionEvent(
      actionType: DecisionActionType.timeOut,
      message: _feedbackMessage,
      encouragement: "Sois plus rapide la prochaine fois ! 💪",
      autoProceed: false,
    );
    notifyListeners();
  }


  // ── ACTIONS ──
  
  void _init() {
    _startTime = DateTime.now();
    _hintsShown = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      generateExercises();
    });
  }

  Future<void> generateExercises({
    double? difficulty,
    List<String>? exerciseTypes,
  }) async {
    int attempts = 0;
    const int maxAttempts = 3;
    bool success = false;

    while (attempts < maxAttempts && !success) {
      attempts++;
      _isGenerating = true;
      _error = null;
      notifyListeners();

      try {
        // 🌐 OPTION 1 : GÉNÉRATION VIA API RÉELLE
        final provider = context.read<AdaptiveExerciseProvider>();
        success = await provider.generateExercises(
          competenceId: competenceId,
          userId: userId,
          count: initialCount,
          difficulty: difficulty,
          exerciseTypes: exerciseTypes,
        );

        if (success) {
          _exercises = provider.state.exercises;
          _currentIndex = provider.state.currentIndex - 1;
          _startTime = DateTime.now();
          startTimer();
        }

        /* 
        // 🧪 OPTION 2 : GÉNÉRATION LOCALE POUR TEST (COMMENTER OPTION 1)
        await Future.delayed(const Duration(seconds: 1));
        _exercises = [
          AdaptiveExerciseModel(
            id: "mock_qcm",
            type: "qcm",
            question: "Quelle est la capitale de la France ?",
            options: ["Lyon", "Marseille", "Paris", "Lille"],
            correctAnswer: "Paris",
            hints: ["C'est la ville lumière."],
            difficulty: 0.3,
            estimatedTime: 30,
          ),
          AdaptiveExerciseModel(
            id: "mock_vrai_faux",
            type: "vrai_faux",
            question: "Le soleil tourne autour de la Terre.",
            options: ["Vrai", "Faux"],
            correctAnswer: "Faux",
            hints: ["Pensez au système héliocentrique."],
            difficulty: 0.2,
            estimatedTime: 20,
          ),
          AdaptiveExerciseModel(
            id: "mock_trous",
            type: "texte_a_trous",
            question: "Le chat ____ la souris.",
            correctAnswer: "mange",
            hints: ["C'est une action de prédateur."],
            difficulty: 0.4,
            estimatedTime: 40,
          ),
          AdaptiveExerciseModel(
            id: "mock_listening",
            type: "listening",
            question: "Écoutez et écrivez le mot : 'Bonjour'",
            correctAnswer: "Bonjour",
            hints: ["C'est une salutation."],
            difficulty: 0.5,
            estimatedTime: 45,
          ),
          AdaptiveExerciseModel(
            id: "mock_error",
            type: "error_correction",
            question: "Corrigez l'erreur : 'Ils mangent du pommes.'",
            correctAnswer: "Ils mangent des pommes.",
            hints: ["Accord de l'article."],
            difficulty: 0.6,
            estimatedTime: 50,
          ),
        ];
        _currentIndex = 0;
        success = true;
        _startTime = DateTime.now();
        startTimer();
        */

        if (!success) {
          _error =
              provider.state.error ??
              "Échec de la tentative $attempts/$maxAttempts";
          if (attempts < maxAttempts) {
            await Future.delayed(const Duration(seconds: 1));
          }
        }
      } catch (e) {
        _error = "Erreur (Tentative $attempts): $e";
        if (attempts < maxAttempts) {
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    }
    _isGenerating = false;
    notifyListeners();
  }


  void selectSingleAnswer(String val) {
    if (_showResult || _isSubmitting) return;
    _selectedAnswer = val;
    notifyListeners();
  }

  void updateMultipleAnswers(List<String> val) {
    if (_showResult || _isSubmitting) return;
    _selectedMultipleAnswers = val;
    notifyListeners();
  }

  void updateTextAnswer(String val) {
    if (_showResult || _isSubmitting) return;
    _selectedAnswer = val;
    notifyListeners();
  }

  void incrementHint(int val) {
    _hintsShown = val;
    notifyListeners();
  }

  Future<void> submit() async {
    if (_isSubmitting || (_selectedAnswer == null && _selectedMultipleAnswers.isEmpty)) return;
    
    _calculateTimeSpent();
    stopTimer();
    _isSubmitting = true;
    notifyListeners();


    try {
      // 🌐 MODE RÉEL (API)
      final submission = _prepareSubmissionData();
      final provider = context.read<AdaptiveExerciseProvider>();
      var result = await provider.submitAnswerWithEmotion(submission);

      final isCorrect = result['is_correct'] as bool? ?? false;
      print("********* apres submission ***************");
      print(result);
      print("********* apres submission ***************");

      // Nouveau backend: la décision est renvoyée directement au niveau racine.
      final decision =
          (result['decision'] as Map<String, dynamic>?) ??
          result;

      final lootedCard = decision.containsKey('looted_card')
          ? decision['looted_card']
          : null;

      _isCorrect = isCorrect;
      _showResult = true;

      // 🎁 GESTION DES RÉCOMPENSES (Gamification)
      bool isPlusTwoGained = false;
      bool isSkipGained = false;

      if (currentExercise != null) {
        final api = context
            .read<AdaptiveExerciseProvider>()
            .dataSource
            .apiConsumer;

        // 1. On laisse le +2 tel quel
        isPlusTwoGained = await PlusTwoService(api).checkAndReward(
          userId: userId,
          difficulty: currentExercise!.difficulty,
          isCorrect: isCorrect,
        );

        // 2. On ajoute le Skip séparément

        isSkipGained = await SkipRewardService(
          api,
        ).checkAndReward(userId: userId, isCorrect: isCorrect);
      }

      if (decision != null) {
        _feedbackMessage = decision['message'] as String? ?? (isCorrect ? 'Correct !' : 'Incorrect');
        final responseType = decision['response_type'] as String? ?? '';
        
        DecisionActionType actionType = _mapResponseType(responseType);
        // Ne PAS écraser actionType ici, sinon on perd la décision pédagogique (ex: nextCompetence)
        // Les flags isPlusTwoGained et isSkipGained suffisent pour le dialogue.

        final encouragement = decision['encouragement'] as String? ?? '';
        final ui = decision['ui'] as Map<String, dynamic>?;

        bool autoProceed = false;
        if (responseType == 'next_exercise' ||
            responseType == 'difficulty_adjusted') {
          autoProceed = true;
        }

        final delaySeconds = ui?['delay_seconds'] as int? ?? 2;
        final showHint = ui?['show_hint'] as bool? ?? false;

        final nextStep = decision['next_step'] as Map<String, dynamic>?;
        final nextCompId = nextStep?['next_competence_id'] as String?;
        final recDiff = nextStep?['difficulty'] != null
            ? (nextStep!['difficulty'] as num).toDouble()
            : null;
        final recTypes = nextStep?['exercise_types'] != null
            ? List<String>.from(nextStep!['exercise_types'] as List)
            : null;

        // Extraction de la nouvelle maîtrise et zone ZPD
        final newMastery = (nextStep?['mastery'] as num?)?.toDouble() ?? 
                          (result['metadata']?['mastery'] as num?)?.toDouble();
        final newZone = nextStep?['zone'] as String? ?? 
                        result['metadata']?['zone'] as String?;

        _currentEvent = DecisionEvent(
          actionType: actionType,
          message: _feedbackMessage,
          encouragement: encouragement,
          autoProceed: autoProceed,
          delaySeconds: delaySeconds,
          showHint: showHint,
          isPlusTwoGained: isPlusTwoGained,
          isSkipGained: isSkipGained,
          lootedCard: lootedCard,
          nextCompetenceId: nextCompId,
          recommendedDifficulty: recDiff,
          recommendedExerciseTypes: recTypes,
          newMastery: newMastery,
          newZone: newZone,
        );

        _handleAutoProceed();
      } else {
        _feedbackMessage = isCorrect ? 'Bravo !' : 'Essaie encore !';
        _currentEvent = null;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  DecisionActionType _mapResponseType(String type) {
    switch (type) {
      case 'take_break':
      case 'pause':
      case 'break_recommended':
        return DecisionActionType.takeBreak;
      case 'next_competence':
      case 'competence_mastered':
        return DecisionActionType.nextCompetence;
      case 'adapt_difficulty':
      case 'difficulty_adjusted':
        return DecisionActionType.adaptDifficulty;
      case 'next_exercise':
      case 'unknown_action':
        return DecisionActionType.nextExercise;
      case 'plus_two_gain':
        return DecisionActionType.plusTwoGain;
      case 'skip_gain':
        return DecisionActionType.skipGain;
      default:
        return DecisionActionType.none;
    }
  }

  void _handleAutoProceed() {
    if (_currentEvent != null && _currentEvent!.autoProceed) {
      Timer(Duration(seconds: _currentEvent!.delaySeconds), () {
        if (_showResult) {
          nextExercise();
        }
      });
    }
  }

  void nextExercise() {
    final provider = context.read<AdaptiveExerciseProvider>();

    // 🔄 CAS 1 : Changement de compétence ou Pause (Décision LLM)
    // L'utilisateur doit retourner à la carte des compétences
    if (_currentEvent?.actionType == DecisionActionType.nextCompetence ||
        _currentEvent?.actionType == DecisionActionType.takeBreak) {
      print("🎯 Fin de session : Retour à la carte des compétences");
      Navigator.of(context).pop();
      return;
    }

    // 🔄 CAS 2 : Fin du batch d'exercices actuel
    if (provider.state.isLastExercise) {
      // Si on était en mode "next_exercise" standard mais que c'était le dernier
      if (_currentEvent?.actionType == DecisionActionType.nextExercise ||
          _currentEvent?.actionType == DecisionActionType.adaptDifficulty) {
        generateExercises(
          difficulty: _currentEvent?.recommendedDifficulty,
          exerciseTypes: _currentEvent?.recommendedExerciseTypes,
        );
      } else {
        // Sinon on quitte (fin de session ou autre)
        Navigator.of(context).pop();
      }
      return;
    }

    // 🔄 CAS 3 : Passage à l'exercice suivant dans le même batch
    _resetForNext();
    provider.nextExerciseContent();
    _exercises = provider.state.exercises;
    _currentIndex = provider.state.currentIndex - 1;
    _startTime = DateTime.now();
    startTimer();
    notifyListeners();
  }

  void previousExercise() {
    final provider = context.read<AdaptiveExerciseProvider>();
    if (provider.state.canGoPrevious) {
      _resetForNext();
      provider.previousExercise();
      _currentIndex = provider.state.currentIndex - 1;
      _startTime = DateTime.now();
      startTimer();
      notifyListeners();
    }
  }

  void _resetForNext() {
    _selectedAnswer = null;
    _selectedMultipleAnswers = [];
    _showResult = false;
    _isCorrect = false;
    _feedbackMessage = '';
    _hintsShown = 0;
    _currentEvent = null;
    
    // Reset des émotions pour le nouvel exercice
    final emotionProvider = context.read<EmotionProvider>();
    emotionProvider.clearCaptures();
    emotionProvider.resetCounters();
  }

  void _calculateTimeSpent() {
    if (_startTime != null) {
      _timeSpentSeconds = DateTime.now().difference(_startTime!).inSeconds;
    }
  }

  ExerciseSubmissionModel _prepareSubmissionData() {
    if (_exercises.isEmpty) throw Exception('No exercise loaded');
    
    final emotionProvider = context.read<EmotionProvider>();
    final exercise = currentExercise!;
    
    // On peut encore utiliser le provider pour le contexte SAINT+ même en mock si besoin
    final provider = context.read<AdaptiveExerciseProvider>();
    final saintContext = provider.state.saintContext;
    final currentZone = saintContext?.zone ?? 'zpd';
    double currentMastery = 0.5;
    
    if (saintContext?.masteryPercentage != null) {
      final masteryStr = saintContext!.masteryPercentage.replaceAll('%', '');
      currentMastery = (double.tryParse(masteryStr) ?? 50.0) / 100.0;
    }

    return ExerciseSubmissionModel(
      userId: userId,
      exerciseId: exercise.id,
      competenceId: competenceId,
      answer: _selectedMultipleAnswers.isNotEmpty
          ? _selectedMultipleAnswers
          : (_selectedAnswer ?? ''),
      isCorrect: _isCorrect,
      timeSpentSeconds: _timeSpentSeconds,
      hintsUsed: _hintsShown,
      attemptNumber: 1,
      emotionData: emotionProvider.prepareEmotionSubmissionData(),
      currentZpdZone: currentZone,
      currentMasteryLevel: currentMastery,
    );
  }


  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  void clearEvent() {

    _currentEvent = null;
    notifyListeners();
  }
}
