import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../provider/adaptive_exercise_provider.dart';
import '../widgets/progress_bar.dart';
import '../widgets/saint_context_badge.dart';
import 'timer_widget.dart';

class AdaptiveExerciseHeader extends StatelessWidget {
  final double progress;
  final int currentIndex;
  final int totalExercises;

  const AdaptiveExerciseHeader({
    Key? key,
    required this.progress,
    required this.currentIndex,
    required this.totalExercises,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ExerciseProgressBar(
                  progress: progress,
                  currentIndex: currentIndex,
                  totalExercises: totalExercises,
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
          const SizedBox(height: 8),

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
        ],
      ),
    );
  }
}
