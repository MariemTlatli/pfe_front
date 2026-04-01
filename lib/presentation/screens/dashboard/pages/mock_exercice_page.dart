import 'package:flutter/material.dart';
import 'package:front/data/models/exercise_model.dart';
import 'package:front/presentation/screens/dashboard/widgets/emotion_camera_widget.dart';

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
  String? _selectedAnswer;
  List<String> _selectedMultipleAnswers = [];
  bool _showResult = false;
  bool _isCorrect = false;
  int _hintsShown = 0;

  // ✅ Mock data — pas d'appel API
  late List<AdaptiveExerciseModel> _mockExercises;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _mockExercises = _buildMockExercises();
  }

  /// ✅ Exercices factices pour tester le front
  List<AdaptiveExerciseModel> _buildMockExercises() {
    return [
      AdaptiveExerciseModel(
        id: 'mock_1',
        type: 'qcm',
        question: 'Quelle est la complexité temporelle d\'une recherche binaire ?',
        options: ['O(n)', 'O(log n)', 'O(n²)', 'O(1)'],
        hints: ['Pensez à combien de fois on divise le tableau par 2.'],
        difficulty: 2,
        estimatedTime: 60,
        
      ),
      AdaptiveExerciseModel(
        id: 'mock_2',
        type: 'vrai_faux',
        question: 'Un algorithme O(n log n) est toujours plus rapide qu\'un O(n²).',
        options: ['Vrai', 'Faux'],
        hints: ['Comparez les courbes pour de grandes valeurs de n.'],
        difficulty: 1,
        estimatedTime: 30,
      ),
      AdaptiveExerciseModel(
        id: 'mock_3',
        type: 'texte_a_trous',
        question: 'Complétez : Le tri rapide (QuickSort) a une complexité moyenne de ___.',
        options: [],
        hints: ['C\'est la même que le tri fusion.'],
        difficulty: 3,
        estimatedTime: 90,
      ),
    ];
  }

  AdaptiveExerciseModel get _currentExercise => _mockExercises[_currentIndex];
  bool get _isLastExercise => _currentIndex == _mockExercises.length - 1;
  bool get _canGoPrevious => _currentIndex > 0;

  void _resetExerciseState() {
    setState(() {
      _selectedAnswer = null;
      _selectedMultipleAnswers = [];
      _showResult = false;
      _isCorrect = false;
      _hintsShown = 0;
    });
  }

  void _nextExercise() {
    if (!_isLastExercise) {
      _resetExerciseState();
      setState(() => _currentIndex++);
    }
  }

  void _previousExercise() {
    if (_canGoPrevious) {
      _resetExerciseState();
      setState(() => _currentIndex--);
    }
  }

  void _validateAnswer() {
    final answer = _selectedAnswer ?? _selectedMultipleAnswers.join(', ');
    setState(() {
      _showResult = true;
      _isCorrect = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.competenceName),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${_currentIndex + 1} / ${_mockExercises.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),

      // ✅ Stack au niveau body entier → DraggableEmotionCamera flotte sur tout
      body: Stack(
        children: [
          // ── Contenu exercice ──
          _buildExerciseContent(),

         
        ],
      ),
    );
  }

  /// Contenu principal de l'exercice
  Widget _buildExerciseContent() {
    final exercise = _currentExercise;

    return Column(
      children: [
        // Barre de progression
        _buildProgressBar(),

        // Contenu scrollable
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildExerciseHeader(exercise),
                const SizedBox(height: 16),
                _buildQuestion(exercise),
                const SizedBox(height: 24),
                _buildAnswerOptions(exercise),
                const SizedBox(height: 16),
                if (exercise.hints.isNotEmpty) _buildHints(exercise),
                const SizedBox(height: 24),
                if (_showResult) _buildResult(),
                // Espace en bas pour ne pas être caché par la caméra
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),

        // Boutons d'action
        _buildActionButtons(),
      ],
    );
  }

  /// Barre de progression
  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _mockExercises.length,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 4),
          Text(
            'Exercice ${_currentIndex + 1} sur ${_mockExercises.length}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Header de l'exercice
  Widget _buildExerciseHeader(AdaptiveExerciseModel exercise) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            exercise.typeFormatted,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.timer, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                exercise.estimatedTimeFormatted,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Question
  Widget _buildQuestion(AdaptiveExerciseModel exercise) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        exercise.question,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
      ),
    );
  }

  /// Options de réponse
  Widget _buildAnswerOptions(AdaptiveExerciseModel exercise) {
    if (exercise.type == 'qcm_multiple') {
      return _buildMultipleChoiceOptions(exercise);
    } else if (exercise.isQCM) {
      return _buildSingleChoiceOptions(exercise);
    } else if (exercise.type == 'texte_a_trous') {
      return _buildTextInput(exercise);
    } else if (exercise.isCodeExercise) {
      return _buildCodeEditor(exercise);
    }
    return const SizedBox.shrink();
  }

  Widget _buildSingleChoiceOptions(AdaptiveExerciseModel exercise) {
    return Column(
      children: exercise.options.map((option) {
        final isSelected = _selectedAnswer == option;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: _showResult ? null : () => setState(() => _selectedAnswer = option),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: isSelected ? Colors.blue : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultipleChoiceOptions(AdaptiveExerciseModel exercise) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sélectionnez plusieurs réponses :',
            style: TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        ...exercise.options.map((option) {
          final isSelected = _selectedMultipleAnswers.contains(option);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: _showResult
                  ? null
                  : () => setState(() {
                        if (isSelected) {
                          _selectedMultipleAnswers.remove(option);
                        } else {
                          _selectedMultipleAnswers.add(option);
                        }
                      }),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.shade50 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                      color: isSelected ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(option,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.normal,
                          )),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTextInput(AdaptiveExerciseModel exercise) {
    return TextField(
      enabled: !_showResult,
      onChanged: (value) => setState(() => _selectedAnswer = value),
      decoration: InputDecoration(
        hintText: 'Entrez votre réponse...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      maxLines: 3,
    );
  }

  Widget _buildCodeEditor(AdaptiveExerciseModel exercise) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (exercise.codeTemplate != null && exercise.codeTemplate!.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              exercise.codeTemplate!,
              style: const TextStyle(
                  fontFamily: 'monospace', fontSize: 14, color: Colors.greenAccent),
            ),
          ),
        const SizedBox(height: 12),
        TextField(
          enabled: !_showResult,
          onChanged: (value) => setState(() => _selectedAnswer = value),
          decoration: InputDecoration(
            hintText: 'Écrivez votre code ici...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
          maxLines: 8,
          style: const TextStyle(fontFamily: 'monospace'),
        ),
      ],
    );
  }

  Widget _buildHints(AdaptiveExerciseModel exercise) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () {
            if (_hintsShown < exercise.hints.length) {
              setState(() => _hintsShown++);
            }
          },
          icon: const Icon(Icons.lightbulb_outline, size: 18),
          label: Text(_hintsShown == 0
              ? 'Afficher un indice'
              : 'Afficher indice suivant ($_hintsShown/${exercise.hints.length})'),
        ),
        if (_hintsShown > 0)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < _hintsShown; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb, size: 16, color: Colors.amber.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(exercise.hints[i],
                              style: TextStyle(color: Colors.amber.shade900)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildResult() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isCorrect ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _isCorrect ? Colors.green : Colors.red),
      ),
      child: Row(
        children: [
          Icon(
            _isCorrect ? Icons.check_circle : Icons.cancel,
            color: _isCorrect ? Colors.green : Colors.red,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isCorrect ? 'Bonne réponse ! 🎉' : 'Mauvaise réponse 😕',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isCorrect ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
                // if (!_isCorrect) ...[
                //   const SizedBox(height: 4),
                //   Text(
                //     'Réponse correcte : ${_currentExercise.correctAnswer}',
                //     style: TextStyle(fontSize: 14, color: Colors.red.shade600),
                //   ),
                // ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Bouton précédent
          if (_canGoPrevious && !_showResult) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previousExercise,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Précédent'),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Bouton valider ou suivant
          Expanded(
            flex: 2,
            child: _showResult
                ? ElevatedButton.icon(
                    onPressed: () {
                      if (_isLastExercise) {
                        Navigator.pop(context);
                      } else {
                        _nextExercise();
                      }
                    },
                    icon: Icon(_isLastExercise ? Icons.check : Icons.arrow_forward),
                    label: Text(_isLastExercise ? 'Terminer' : 'Suivant'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed:
                        _selectedAnswer != null || _selectedMultipleAnswers.isNotEmpty
                            ? _validateAnswer
                            : null,
                    icon: const Icon(Icons.check),
                    label: const Text('Valider'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}