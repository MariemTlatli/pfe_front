import 'dart:async';
import 'package:flutter/material.dart';
import 'package:front/data/models/exercise_model.dart';
import 'package:front/data/models/exercise_submission.dart';
import 'package:front/presentation/provider/adaptive_exercise_provider.dart';
import 'package:front/presentation/provider/emotion_provider.dart';
import 'package:provider/provider.dart';
import 'mock_data.dart';

enum DecisionActionType {
  none,
  takeBreak,
  nextCompetence,
  adaptDifficulty,
  nextExercise,
}

class DecisionEvent {
  final DecisionActionType actionType;
  final String message;
  final String encouragement;
  final bool autoProceed;
  final int delaySeconds;
  final bool showHint;

  DecisionEvent({
    required this.actionType,
    required this.message,
    this.encouragement = '',
    this.autoProceed = false,
    this.delaySeconds = 0,
    this.showHint = false,
  });
}

class AdaptiveExerciseController extends ChangeNotifier {
  final BuildContext context;
  final String competenceId;
  final String userId;
  final int initialCount;

  AdaptiveExerciseController({
    required this.context,
    required this.competenceId,
    required this.userId,
    this.initialCount = 3,
  }) {
    _init();
  }

  // ── CONFIGURATION ──
  final bool _useMockData = false; // Mettre à false pour utiliser l'API réelle

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

  // ── ACTIONS ──
  
  void _init() {
    _startTime = DateTime.now();
    _hintsShown = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      generateExercises();
    });
  }

  Future<void> generateExercises() async {
    _isGenerating = true;
    _error = null;
    notifyListeners();

    if (_useMockData) {
      // // 🧪 MODE MOCK
      // await Future.delayed(const Duration(seconds: 1)); // Simuler latence
      // _exercises = AdaptiveExerciseMockData.getMockExercises();
      // _currentIndex = 0;
    // 🌐 MODE RÉEL (API)
      final provider = context.read<AdaptiveExerciseProvider>();
      final success = await provider.generateExercises(
        competenceId: competenceId,
        userId: userId,
        count: initialCount,
      );
      
      if (!success) {
        _error = provider.state.error ?? "Erreur lors de la génération";
      } else {
        _exercises = provider.state.exercises;
        _currentIndex = provider.state.currentIndex - 1;
      }
    } else {
      // 🌐 MODE RÉEL (API)
      final provider = context.read<AdaptiveExerciseProvider>();
      final success = await provider.generateExercises(
        competenceId: competenceId,
        userId: userId,
        count: initialCount,
      );
      
      if (!success) {
        _error = provider.state.error ?? "Erreur lors de la génération";
      } else {
        _exercises = provider.state.exercises;
        _currentIndex = provider.state.currentIndex - 1;
      }
    }
    
    _isGenerating = false;
    _startTime = DateTime.now();
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
    _isSubmitting = true;
    notifyListeners();

    try {
      Map<String, dynamic> result;

      if (_useMockData) {
        // 🧪 MODE MOCK
        await Future.delayed(const Duration(milliseconds: 800));
        result = AdaptiveExerciseMockData.getMockSuccessDecision();
      } else {
        // 🌐 MODE RÉEL (API)
        final submission = _prepareSubmissionData();
        final provider = context.read<AdaptiveExerciseProvider>();
        result = await provider.submitAnswerWithEmotion(submission);
      }

      final isCorrect = result['is_correct'] as bool? ?? false;
      // Nouveau backend: la décision est renvoyée directement au niveau racine.
      final decision =
          (result['decision'] as Map<String, dynamic>?) ??
          result;

      _isCorrect = isCorrect;
      _showResult = true;

      if (decision != null) {
        _feedbackMessage = decision['message'] as String? ?? (isCorrect ? 'Correct !' : 'Incorrect');
        final responseType = decision['response_type'] as String? ?? '';
        final encouragement = decision['encouragement'] as String? ?? '';
        final ui = decision['ui'] as Map<String, dynamic>?;
        // ⚡ AUTO-PROCEED par défaut
        bool autoProceed = ui?['auto_proceed'] as bool? ?? true;
        if (responseType == 'next_exercise' ||
            responseType == 'difficulty_adjusted') {
          autoProceed = true;
        }

        final delaySeconds = ui?['delay_seconds'] as int? ?? 2;
        final showHint = ui?['show_hint'] as bool? ?? false;

        _currentEvent = DecisionEvent(
          actionType: _mapResponseType(responseType),
          message: _feedbackMessage,
          encouragement: encouragement,
          autoProceed: autoProceed,
          delaySeconds: delaySeconds,
          showHint: showHint,
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
        return DecisionActionType.nextExercise;
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
    if (_useMockData) {
      if (_currentIndex < _exercises.length - 1) {
        _currentIndex++;
        _resetForNext();
        _startTime = DateTime.now();
        notifyListeners();
      } else {
        Navigator.of(context).pop();
      }
    } else {
      final provider = context.read<AdaptiveExerciseProvider>();
      
      // 🔄 Si le backend demande la suite (même si le batch actuel est fini)
      if (provider.state.isLastExercise && 
          (_currentEvent?.actionType == DecisionActionType.nextExercise || 
           _currentEvent?.actionType == DecisionActionType.adaptDifficulty)) {
        generateExercises();
        return;
      }

      if (provider.state.isLastExercise) {
        Navigator.of(context).pop();
      } else {
        _resetForNext();
        provider.nextExercise();
        _exercises = provider.state.exercises;
        _currentIndex = provider.state.currentIndex - 1;
        _startTime = DateTime.now();
        notifyListeners();
      }
    }
  }

  void previousExercise() {
    if (_useMockData) {
      if (_currentIndex > 0) {
        _currentIndex--;
        _resetForNext();
        _startTime = DateTime.now();
        notifyListeners();
      }
    } else {
      final provider = context.read<AdaptiveExerciseProvider>();
      if (provider.state.canGoPrevious) {
        _resetForNext();
        provider.previousExercise();
        _currentIndex = provider.state.currentIndex - 1;
        _startTime = DateTime.now();
        notifyListeners();
      }
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
    context.read<EmotionProvider>().clearCaptures();
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

    dynamic answer;
    if (_selectedMultipleAnswers.isNotEmpty) {
      answer = List<String>.from(_selectedMultipleAnswers);
    } else {
      answer = _selectedAnswer ?? '';
    }

    return ExerciseSubmissionModel(
      userId: userId,
      exerciseId: exercise.id,
      competenceId: competenceId,
      answer: answer,
      isCorrect: null,
      timeSpentSeconds: _timeSpentSeconds,
      hintsUsed: _hintsShown,
      attemptNumber: 1,
      emotionData: emotionProvider.prepareEmotionSubmissionData(),
      currentZpdZone: currentZone,
      currentMasteryLevel: currentMastery,
    );
  }


  void clearEvent() {
    _currentEvent = null;
    notifyListeners();
  }
}
