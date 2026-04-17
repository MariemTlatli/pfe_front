// lib/presentation/screens/exercice_uno/widgets/fake_exercice_widget.dart
import 'package:flutter/material.dart';
import 'fake/fake_quiz_widget.dart';

/// Widget that simulates an exercise using fake quiz data.
class FakeExerciceWidget extends StatelessWidget {
  const FakeExerciceWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: FakeQuizWidget(),
    );
  }
}
