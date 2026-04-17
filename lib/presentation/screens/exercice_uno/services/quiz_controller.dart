// lib/presentation/screens/exercice_uno/services/quiz_controller.dart
import 'package:flutter/material.dart';
import 'package:front/data/models/exercise_submission.dart';
import 'package:front/data/models/special_cards_model.dart';
import 'package:front/presentation/screens/home/success_secreen.dart';
import '../models/quiz_models.dart';
import 'quiz_api_service.dart';
import 'gamification_service.dart';

class QuizController extends ChangeNotifier {
  final String userId;
  final List<QuizQuestion> questions;
  int _currentIndex = 0;
  int? _selectedIndex;
  int _score = 0;
  bool _isFinished = false;
  bool _isLoading = false;
  SpecialCardsStatus? _specialCards;

  QuizController({required this.userId, required this.questions});

  int get currentIndex => _currentIndex;
  int? get selectedIndex => _selectedIndex;
  int get score => _score;
  bool get isFinished => _isFinished;
  bool get isLoading => _isLoading;
  QuizQuestion get currentQuestion => questions[_currentIndex];
  SpecialCardsStatus? get specialCards => _specialCards;

  Future<void> init() async => await fetchSpecialCards();

  void selectOption(int idx) {
    _selectedIndex = idx;
    notifyListeners();
  }

  Future<void> fetchSpecialCards() async {
    try {
      final resp = await GamificationService.fetchSpecialCards(userId);
      if (resp.statusCode == 200) {
        _specialCards = SpecialCardsStatus.fromJson(resp.data);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<List<dynamic>> getPotentialTargets() async {
    try {
      final resp = await GamificationService.fetchPlus2Targets(userId);
      if (resp.statusCode == 200) {
        return resp.data['cibles'] as List<dynamic>;
      }
    } catch (_) {}
    return [];
  }

  List<String> _plus4Hints = [];
  List<String> get plus4Hints => _plus4Hints;

  Future<String?> useSpecialCard(String type, {String? targetId, String? exerciseId}) async {
    _isLoading = true;
    notifyListeners();
    String? errorMessage;
    bool success = false;
    try {
      if (type == 'skip') {
        final resp = await GamificationService.useSkip(userId);
        if (resp.statusCode == 200 && resp.data['success'] == true) {
          _nextOrFinish();
          success = true;
        } else {

          errorMessage = resp.data['message'];
        }
      } else if (type == 'joker') {
        final resp = await GamificationService.useJoker(userId, 0.2);
        if (resp.statusCode == 200 && resp.data['success'] == true) {
          success = true;
        } else {
          errorMessage = resp.data['message'];
        }
      } else if (type == 'plus2' && targetId != null) {
        final resp = await GamificationService.usePlus2(userId, targetId);
        if (resp.statusCode == 200 && resp.data['success'] == true) {
          success = true;
        } else {
          errorMessage = resp.data['message'];
        }
      } else if (type == 'plus4') {
        final idToUse = exerciseId ?? (questions.isNotEmpty ? currentQuestion.id : null);
        if (idToUse == null) {
          errorMessage = "Impossible d'identifier l'exercice pour générer les indices.";
        } else {
          final resp = await GamificationService.usePlus4(userId, idToUse);
          if (resp.statusCode == 200 && resp.data['success'] == true) {
            _plus4Hints = List<String>.from(resp.data['hints'] ?? []);
            success = true;
          } else {
            errorMessage = resp.data['message'] ?? "Désolé, tu as perdu cette carte sans pouvoir l'utiliser !";
          }
        }
      } else if (type == 'reverse') {
        final resp = await GamificationService.useReverse(userId);
        if (resp.statusCode == 200 && resp.data['success'] == true) {
          success = true;
        } else {
          errorMessage = resp.data['message'] ?? "Carte perdue ! L'inversion a échoué.";
        }
      }


    } catch (e) {
      errorMessage = "Une erreur technique est survenue.";
    }
    _isLoading = false;
    if (success) await fetchSpecialCards();
    notifyListeners();
    return errorMessage;
  }





  Future<void> submitAnswer(BuildContext context) async {
    if (_selectedIndex == null) return;
    _isLoading = true;
    notifyListeners();
    final isCorrect = _selectedIndex == currentQuestion.correctIndex;
    if (isCorrect) _score++;
    await QuizApiService.submitQuizResult(_createSubmission(isCorrect));
    _isLoading = false;
    _nextOrFinish();
    notifyListeners();
  }

  void _nextOrFinish() {
    _plus4Hints = [];
    if (_currentIndex < questions.length - 1) {

      _currentIndex++;
      _selectedIndex = null;
    } else {
      _isFinished = true;
      GamificationService.fetchCards(userId);
    }
  }

  Future<String?> checkForMasteryReward() async {
    try {
      // On vérifie la maîtrise pour la compétence de la dernière question
      final compId = questions.first.competenceId; 
      final resp = await GamificationService.claimMasteryReward(userId, compId);
      if (resp.statusCode == 200 && resp.data['success'] == true) {
        await fetchSpecialCards();
        return resp.data['message'];
      }
    } catch (_) {}
    return null;
  }


  ExerciseSubmissionModel _createSubmission(bool isCorrect) {
    return ExerciseSubmissionModel(
      exerciseId: currentQuestion.id,
      competenceId: currentQuestion.competenceId,
      userId: userId,
      answer: currentQuestion.options[_selectedIndex!],
      isCorrect: isCorrect,
      timeSpentSeconds: 15,
      hintsUsed: 0,
      currentZpdZone: 'zpd',
      currentMasteryLevel: 0.5,
      emotionData: EmotionSubmissionData(dominantEmotion: 'happy', confidence: 0.9, emotionHistory: [], frustrationDetected: false, averageConfidence: 0.9),
    );
  }
}
