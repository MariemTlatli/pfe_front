import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'adaptive_exercise_controller.dart';
import 'widgets/exercise_view.dart';
import 'widgets/action_buttons.dart';
import 'widgets/adaptive_header.dart';
import 'widgets/decision_utils.dart';
import 'package:front/presentation/provider/card_provider.dart';
import 'package:front/presentation/screens/exercice_uno/widgets/card_stack_view_page.dart';
import 'package:front/presentation/screens/dashboard/widgets/emotion_camera_widget.dart';
import 'package:front/presentation/screens/exercice_uno/services/quiz_controller.dart';
import 'package:front/presentation/screens/exercice_uno/models/card_collection.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = AdaptiveExerciseController(
      context: context, competenceId: widget.competenceId, 
      userId: widget.userId, initialCount: widget.count
    );
    _quizController = QuizController(userId: widget.userId, questions: []);
    _quizController.init();
    
    // 🃏 Chargement initial des cartes pour l'éventail
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CardProvider>().loadAndMapCards(
            userId: widget.userId,
            difficulty: 0.5, // Difficulté moyenne par défaut
            nbCartes: 7,
          );
    });

    _controller.addListener(() {

      final event = _controller.currentEvent;
      if (event != null) {
        AdaptiveDecisionUtils.showDecisionDialog(
          context: context, event: event, controller: _controller
        );
        _controller.clearEvent();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _quizController.dispose();
    super.dispose();
  }

  void _showHandDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: const BorderSide(color: Colors.amber, width: 2),
        ),
        title: const Row(
          children: [
            Icon(Icons.style, color: Colors.amber),
            SizedBox(width: 10),
            Text("Votre Main UNO", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Consumer<CardProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator(color: Colors.amber));
              }
              final paths = provider.cards
                  .expand((c) => c.card.assetPaths)
                  .toList();
              if (paths.isEmpty) {
                return const Center(
                  child: Text("Aucune carte en main", style: TextStyle(color: Colors.white54)),
                );
              }
              return Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: buildArcHand(context, paths),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Fermer", style: TextStyle(color: Colors.amber)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _controller),
        ChangeNotifierProvider.value(value: _quizController),
      ],
      child: Scaffold(
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            onPressed: () => _showHandDialog(context),
            backgroundColor: Colors.amber,
            child: const Icon(Icons.style, color: Colors.black),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
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
                    AdaptiveExerciseHeader(
                      progress: (controller.currentIndex + 1) / controller.totalExercises,
                      currentIndex: controller.currentIndex + 1,
                      totalExercises: controller.totalExercises,
                    ),
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

