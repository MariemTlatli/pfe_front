import 'package:flutter/material.dart';
import 'package:front/presentation/screens/exercises/adaptive_exercise_page/widgets/timer_widget.dart';
import 'package:front/presentation/widgets/uno_card.dart';

class ExerciseHeader extends StatelessWidget {
  final String typeFormatted;
  final String estimatedTimeFormatted;

  const ExerciseHeader({
    Key? key,
    required this.typeFormatted,
    required this.estimatedTimeFormatted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildPill(
          typeFormatted,    
          context),
        Spacer(),
        const ExerciseTimerWidget(),
        
      ],
    );
  }

  Widget _buildPill(String label, BuildContext context) {
    return UnoCard(
      height: 45,
      width: MediaQuery.of(context).size.width * 0.3,
      label: label,
      onTap: () {}, // Optional action
      content: Center(
        child: Text(
          label,
          style: TextStyle(
            color: Color(0xFF424242),
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
      ),
    );
    

  }
}
