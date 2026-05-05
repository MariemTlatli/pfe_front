import 'package:flutter/material.dart';
import 'package:front/presentation/provider/emotion_provider.dart';
import 'package:provider/provider.dart';
import 'adaptive_exercise_controller.dart';
import 'widgets/exercise_view.dart';
import 'widgets/action_buttons.dart';
import 'widgets/adaptive_header.dart';
import 'widgets/decision_utils.dart';
import 'package:front/presentation/provider/card_provider.dart';
import 'package:front/presentation/screens/dashboard/widgets/emotion_camera_widget.dart';
import 'package:front/presentation/screens/exercice_uno/services/quiz_controller.dart';
import 'package:front/presentation/screens/exercice_uno/widgets/reverse_card_dialog.dart';
import 'package:front/presentation/screens/exercice_uno/widgets/joker_card_dialog.dart';


class AdaptiveExercisePage extends StatefulWidget {
  final String competenceId, competenceName, userId;
  final int count;

  const AdaptiveExercisePage({
    Key? key, required this.competenceId, required this.competenceName, 
    required this.userId, required this.count
  }) : super(key: key);

  @override
  State<AdaptiveExercisePage> createState() => _AdaptiveExercisePageState();
}

class _AdaptiveExercisePageState extends State<AdaptiveExercisePage> {
  late AdaptiveExerciseController _controller;
  late QuizController _quizController;
  bool _hasShownHappyDialog =
      false; // Flag pour ne pas afficher le dialogue plusieurs fois

  @override
  void initState() {
    super.initState();
    _controller = AdaptiveExerciseController(
      context: context, competenceId: widget.competenceId, 
      userId: widget.userId, initialCount: widget.count
    );
    _quizController = QuizController(userId: widget.userId, questions: []);
    _quizController.init();
    
    // 🃏 Chargement initial des cartes pour l'éventail + Reset des émotions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CardProvider>().loadAndMapCards(
            userId: widget.userId,
            difficulty: 0.5, // Difficulté moyenne par défaut
            nbCartes: 7,
          );
      context.read<EmotionProvider>().resetCounters();
    });

    _controller.addListener(() {
      final event = _controller.currentEvent;
      if (event != null) {
        AdaptiveDecisionUtils.showDecisionDialog(
          context: context, event: event, controller: _controller
        );
        _controller.clearEvent();
        // Reset du flag pour le prochain exercice
        _hasShownHappyDialog = false;
      }
    });

    // 🔬 Listener pour les émotions en temps réel
    context.read<EmotionProvider>().addListener(_onEmotionChanged);
  }

  void _onEmotionChanged() {
    final emotionProvider = context.read<EmotionProvider>();

    // 🎉 Cas HAPPY (5 ou plus) -> Carte Inversion
    if (emotionProvider.happyCount >= 5 &&
        !emotionProvider.hasTriggeredHappyRequest) {
      emotionProvider
          .markHappyTriggered(); // 🔒 Sécurité : ne s'exécute qu'une seule fois !
      emotionProvider.attribuerInversion(widget.userId).then((res) {
        if (res['success'] == true) {
          ReverseCardDialog.show(context);
        }
      });
    }

    // 😢 Cas SAD (5 ou plus) -> Carte Joker
    if (emotionProvider.sadCount >= 5 &&
        !emotionProvider.hasTriggeredSadRequest) {
      emotionProvider
          .markSadTriggered(); // 🔒 Sécurité : ne s'exécute qu'une seule fois !
      emotionProvider.attribuerJoker(widget.userId).then((res) {
        if (res['success'] == true) {
          JokerCardDialog.show(context);
        }
      });
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    _quizController.dispose();
    context.read<EmotionProvider>().removeListener(_onEmotionChanged);
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _controller),
        ChangeNotifierProvider.value(value: _quizController),
      ],
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/auth_bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Consumer<AdaptiveExerciseController>(
              builder: (context, controller, _) {
                if (controller.isGenerating) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.amber),
                        SizedBox(height: 20),
                        Text(
                          "PRÉPARATION DU JEU...",
                          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }
                final ex = controller.currentExercise;
                if (ex == null) return const Center(child: Text('Aucun exercice disponible', style: TextStyle(color: Colors.white70)));

                return Column(
                  children: [
                    // AdaptiveExerciseHeader(
                    //   progress: (controller.currentIndex + 1) / controller.totalExercises,
                    //   currentIndex: controller.currentIndex + 1,
                    //   totalExercises: controller.totalExercises,
                    // ),
                    Expanded(
                      child: Stack(
                        children: [
                          ExerciseView(exercise: ex, controller: controller),
                          const DraggableEmotionCamera(),
                        ],
                      ),
                    ),
                    ExerciseActionButtons(
                      canGoPrevious: controller.currentIndex > 0,
                      showResult: controller.showResult,
                      isSubmitting: controller.isSubmitting,
                      hasAnswer: controller.selectedAnswer != null || controller.selectedMultipleAnswers.isNotEmpty,
                      onPrevious: controller.previousExercise,
                      onNext: controller.nextExercise,
                      onValidate: controller.submit,
                      isLastExercise: controller.currentIndex == controller.totalExercises - 1,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        
      ),
    );
  }
}

