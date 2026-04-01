import 'package:front/data/data_sources/emotion_remote_data_source.dart';
import 'package:front/data/models/exercise_submission.dart';
import 'package:front/presentation/provider/emotion_provider.dart';



void main() {
  // Mock du DataSource (juste pour compiler)
  final mockDataSource = EmotionRemoteDataSource(apiConsumer: null as dynamic);
  final provider = EmotionProvider(dataSource: mockDataSource);

  // Ajouter des captures simulées
  provider.addCapture(EmotionCaptureData(emotion: 'neutral', confidence: 0.8, timestamp: DateTime.now()));
  provider.addCapture(EmotionCaptureData(emotion: 'happy', confidence: 0.7, timestamp: DateTime.now()));
  provider.addCapture(EmotionCaptureData(emotion: 'neutral', confidence: 0.75, timestamp: DateTime.now()));

  // Tester les getters
  print('📊 Captures: ${provider.captures.length}');
  print('🎯 Dominante: ${provider.dominantCapture?.emotion}');
  print('📈 Confiance moyenne: ${provider.averageConfidence.toStringAsFixed(2)}');
  print('😤 Frustration: ${provider.isFrustrationDetected}');

  // Tester la préparation pour soumission
  final submissionData = provider.prepareEmotionSubmissionData();
  print('✅ Submission data prête: ${submissionData.dominantEmotion}');

  // Nettoyer
  provider.clearCaptures();
  print('🧹 Buffer vidé: ${provider.captures.isEmpty}');
}