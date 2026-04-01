import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'adaptive_exercise_controller.dart';
import 'widgets/exercise_view.dart';
import 'widgets/action_buttons.dart';
import 'widgets/progress_bar.dart';
import 'widgets/saint_context_badge.dart';
import 'dialogs/adaptation_dialog.dart';
import 'package:front/presentation/screens/dashboard/widgets/emotion_camera_widget.dart';
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
  late AdaptiveExerciseController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AdaptiveExerciseController(
      context: context,
      competenceId: widget.competenceId,
      userId: widget.userId,
      initialCount: widget.count,
    );

    _controller.addListener(_handleDecisionEvents);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleDecisionEvents);
    _controller.dispose();
    super.dispose();
  }

  void _handleDecisionEvents() {
    final event = _controller.currentEvent;
    if (event == null) return;

    if (event.actionType == DecisionActionType.takeBreak || 
        event.actionType == DecisionActionType.nextCompetence) {
      _showDecisionDialog(event);
      _controller.clearEvent();
    } else if (event.actionType == DecisionActionType.adaptDifficulty ||
               event.actionType == DecisionActionType.nextExercise) {
      if (!event.autoProceed) {
        _showDecisionDialog(event);
        _controller.clearEvent();
      }
      // autoProceed logic is handled by the controller's timer
    }
  }

  void _showDecisionDialog(DecisionEvent event) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        if (event.actionType == DecisionActionType.takeBreak) {
          return AlertDialog(
            title: const Text('Pause recommandée'),
            content: Text(event.message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(this.context);
                },
                child: const Text('Arrêter'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Continuer'),
              ),
            ],
          );
        } else if (event.actionType == DecisionActionType.nextCompetence) {
          return AlertDialog(
            title: const Text('Bravo ! 🎉'),
            content: Text(event.message),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(this.context);
                },
                child: const Text('Terminer'),
              ),
            ],
          );
        } else {
          return AdaptationDialog(
            title: 'Adaptation',
            message: event.message,
            encouragement: event.encouragement,
            onContinue: () => _controller.nextExercise(),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<AdaptiveExerciseController>(
        builder: (context, controller, _) {
          if (controller.isGenerating) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          if (controller.error != null) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Erreur: ${controller.error}'),
                    ElevatedButton(
                      onPressed: () => controller.generateExercises(),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          final exercise = controller.currentExercise;
          if (exercise == null) return const Scaffold(body: Center(child: Text('Aucun exercice')));

          return Scaffold(
            appBar: AppBar(
              title: Text(widget.competenceName),
              actions: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '${controller.currentIndex + 1} / ${controller.totalExercises}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            body: Stack(
              children: [
                Column(
                  children: [
                    ExerciseProgressBar(
                      progress: (controller.currentIndex + 1) / controller.totalExercises,
                      currentIndex: controller.currentIndex + 1,
                      totalExercises: controller.totalExercises,
                    ),
                    Consumer<AdaptiveExerciseProvider>(
                      builder: (context, provider, _) {
                        final saintContext = provider.state.saintContext;
                        if (saintContext == null) return const SizedBox.shrink();
                        return SaintContextBadge(
                          zone: saintContext.zone,
                          masteryPercentage: saintContext.masteryPercentage,
                        );
                      },
                    ),
                    Expanded(
                      child: ExerciseView(
                        exercise: exercise,
                        controller: controller,
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
                ),
                const DraggableEmotionCamera(),
              ],
            ),
          );
        },
      ),
    );
  }
}
