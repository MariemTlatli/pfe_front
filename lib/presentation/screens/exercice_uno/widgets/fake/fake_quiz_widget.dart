// lib/presentation/screens/exercice_uno/widgets/fake/fake_quiz_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/quiz_models.dart';
import '../../services/quiz_controller.dart';
import '../quiz/quiz_view.dart';
import '../quiz/quiz_result_view.dart';
import '../quiz/mastery_celebration_dialog.dart';

class FakeQuizWidget extends StatefulWidget {
  const FakeQuizWidget({Key? key}) : super(key: key);
  @override
  State<FakeQuizWidget> createState() => _FakeQuizWidgetState();
}

class _FakeQuizWidgetState extends State<FakeQuizWidget> {
  static const List<QuizQuestion> _mockQuestions = [
    QuizQuestion(id: '69dece7328897c89ed8c0900', question: 'Quelle est la capitale de la France ?', options: ['Paris', 'Lyon', 'Marseille', 'Nice'], correctIndex: 0, competenceId: 'geo_fr'),
    QuizQuestion(id: '69ded2dd28897c89ed8c0901', question: 'Quel est le résultat de 2 + 2 ?', options: ['3', '4', '5', '6'], correctIndex: 1, competenceId: 'math_basic'),
  ];

  late QuizController _controller;

  @override
  void initState() {
    super.initState();
    _controller = QuizController(userId: '69d78b6e9c8ffb339eb0ced2', questions: _mockQuestions);
    _controller.init();
  }

  void _onFinished() async {
    final message = await _controller.checkForMasteryReward();
    if (message != null && mounted) {
      showDialog(context: context, builder: (ctx) => MasteryCelebrationDialog(message: message));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Consumer<QuizController>(
          builder: (context, controller, _) {
            if (controller.isFinished) {
               WidgetsBinding.instance.addPostFrameCallback((_) => _onFinished());
            }
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: controller.isFinished 
                ? QuizResultView(score: controller.score, total: _mockQuestions.length, onRestart: () => setState(() => _controller = QuizController(userId: '69d78b6e9c8ffb339eb0ced2', questions: _mockQuestions)..init()))
                : Stack(
                    children: [
                      SafeArea(child: QuizView(
                        question: controller.currentQuestion, 
                        currentIndex: controller.currentIndex,
                        totalQuestions: _mockQuestions.length,
                        selectedIndex: controller.selectedIndex,
                        onSelected: controller.selectOption,
                        onSubmit: () => controller.submitAnswer(context),
                      )),
                      if (controller.isLoading) Container(color: Colors.black45, child: const Center(child: CircularProgressIndicator(color: Colors.amber))),
                    ],
                  ),
            );
          },
        ),
      ),
    );
  }
}

