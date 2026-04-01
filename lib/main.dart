import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:front/data/data_sources/emotion_remote_data_source.dart';
import 'package:front/data/data_sources/generate_subject.dart';
import 'package:front/presentation/provider/emotion_provider.dart';
import 'package:front/presentation/screens/dashboard/pages/details_page.dart';
// import 'package:front/presentation/screens/dashboard/pages/exercise_page.dart';
import 'package:front/presentation/screens/dashboard/pages/lesson_page.dart';
import 'package:front/presentation/screens/exercises/adaptive_exercise_page/adaptive_exercise_page.dart';
// import 'package:front/presentation/screens/dashboard/pages/mock_exercice_page.dart';
import 'package:provider/provider.dart';
import 'core/api/dio_factory.dart';
import 'core/api/http_consumer.dart';
import 'core/local_storage/secure_storage_service.dart';
import 'data/data_sources/auth_remote_data_source.dart';
import 'data/data_sources/discovery_remote_data_source.dart';
import 'data/data_sources/lesson_remote_data_source.dart';
import 'data/data_sources/zpd_remote_data_source.dart';
import 'data/data_sources/adaptive_exercise_remote_data_source.dart'; // ← NOUVEAU
import 'data/repositories/auth_repository.dart';
// import 'config/theme/app_theme.dart';
import 'presentation/provider/auth_provider.dart';
import 'presentation/provider/localization_provider.dart';
import 'presentation/provider/discovery_provider.dart';
import 'presentation/provider/curriculum_provider.dart';
import 'presentation/provider/lesson_provider.dart';
import 'presentation/provider/zpd_provider.dart';
import 'presentation/provider/adaptive_exercise_provider.dart'; // ← NOUVEAU
import 'presentation/screens/auth/login/login_screen.dart';
import 'presentation/screens/auth/register/register_screen.dart';
import 'presentation/screens/auth/splash/splash_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/dashboard/pages/discovery_page.dart';
import 'presentation/screens/dashboard/pages/subject_detail_page.dart';
import 'presentation/screens/dashboard/pages/competence_ready_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  final dio = DioFactory.createDio();
  final secureStorage = SecureStorageService();
  final localizationProvider = LocalizationProvider();
  final httpConsumer = HttpConsumer(
    dio: dio,
    locale: localizationProvider.locale,
  );

  // Auth
  final authRemoteDataSource = AuthRemoteDataSourceImpl(
    apiConsumer: httpConsumer,
  );
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    secureStorage: secureStorage,
  );

  // Discovery
  final discoveryRepository = DiscoveryRemoteDataSourceImpl(
    apiConsumer: httpConsumer,
  );

  // Curriculum
  final curriculumDataSource = CurriculumRemoteDataSource(
    apiConsumer: httpConsumer,
  );

  // Lessons
  final lessonDataSource = LessonRemoteDataSource(apiConsumer: httpConsumer);

  // ZPD
  final zpdDataSource = ZPDRemoteDataSource(apiConsumer: httpConsumer);

  // Adaptive Exercises ← NOUVEAU
  final adaptiveExerciseDataSource = AdaptiveExerciseRemoteDataSource(
    apiConsumer: httpConsumer,
  );
  // Emotion
  final emotionDataSource = EmotionRemoteDataSource(apiConsumer: httpConsumer);

  runApp(
    MyApp(
      authRepository: authRepository,
      discoveryRepository: discoveryRepository,
      curriculumDataSource: curriculumDataSource,
      lessonDataSource: lessonDataSource,
      zpdDataSource: zpdDataSource,
      adaptiveExerciseDataSource: adaptiveExerciseDataSource, // ← NOUVEAU
      localizationProvider: localizationProvider,
      emotionDataSource: emotionDataSource,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final DiscoveryRemoteDataSourceImpl discoveryRepository;
  final CurriculumRemoteDataSource curriculumDataSource;
  final LessonRemoteDataSource lessonDataSource;
  final ZPDRemoteDataSource zpdDataSource;
  final AdaptiveExerciseRemoteDataSource
  adaptiveExerciseDataSource; // ← NOUVEAU
  final LocalizationProvider localizationProvider;
  final EmotionRemoteDataSource emotionDataSource;

  const MyApp({
    Key? key,
    required this.authRepository,
    required this.discoveryRepository,
    required this.curriculumDataSource,
    required this.lessonDataSource,
    required this.zpdDataSource,
    required this.adaptiveExerciseDataSource, // ← NOUVEAU
    required this.localizationProvider,
    required this.emotionDataSource,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localizationProvider),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authRepository: authRepository,
            localizationProvider: localizationProvider,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              DiscoveryProvider(repository: discoveryRepository, userId: ''),
        ),
        ChangeNotifierProvider(
          create: (_) => CurriculumProvider(dataSource: curriculumDataSource),
        ),
        ChangeNotifierProvider(
          create: (_) => EmotionProvider(dataSource: emotionDataSource),
        ),
        // ZPD provider global, partagé dans l’app
        ChangeNotifierProvider(
          create: (_) => ZPDProvider(dataSource: zpdDataSource),
        ),
      ],
      child: Consumer<LocalizationProvider>(
        builder: (context, localizationProvider, _) {
          return MaterialApp(
            title: localizationProvider.locale.appName,
            locale: localizationProvider.currentLocale,
            supportedLocales: localizationProvider.supportedLanguages
                .map((lang) => Locale(lang))
                .toList(),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const SplashScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => const HomeScreen(),

              '/discovery': (context) {
                final userId =
                    ModalRoute.of(context)?.settings.arguments as String? ?? '';
                return ChangeNotifierProvider(
                  create: (_) => DiscoveryProvider(
                    repository: discoveryRepository,
                    userId: userId,
                  ),
                  child: DiscoveryPage(userId: userId),
                );
              },

              '/curriculum': (context) {
                final args =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>?;
                final subjectId = args?['subjectId'] as String? ?? '';
                final hasCurriculum = args?['hasCurriculum'] as bool? ?? false;

                return CurriculumPage(
                  subjectId: subjectId,
                  hasCurriculum: hasCurriculum,
                );
              },

              '/lessons': (context) {
                final args =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>?;
                final competenceId = args?['competenceId'] as String? ?? '';
                final competenceName = args?['competenceName'] as String? ?? '';
                final hasLessons = args?['hasLessons'] as bool? ?? false;

                return Builder(
                  builder: (context) {
                    final curriculumProvider = context
                        .read<CurriculumProvider>();

                    return ChangeNotifierProvider(
                      create: (_) => LessonProvider(
                        dataSource: lessonDataSource,
                        onLessonsGenerated: (compId, count) {
                          curriculumProvider.updateCompetenceLessonsStatus(
                            competenceId: compId,
                            hasLessons: true,
                            lessonsCount: count,
                          );
                        },
                      ),
                      child: LessonsPage(
                        competenceId: competenceId,
                        competenceName: competenceName,
                        hasLessons: hasLessons,
                      ),
                    );
                  },
                );
              },

              '/competence-ready': (context) {
                final args =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>?;
                final competenceId = args?['competenceId'] as String? ?? '';
                final competenceName = args?['competenceName'] as String? ?? '';
                final userId = args?['userId'] as String? ?? '';

                return CompetenceReadyPage(
                  competenceId: competenceId,
                  competenceName: competenceName,
                  userId: userId,
                );
              },

              // ← NOUVEAU : Route pour les exercices adaptatifs
              '/adaptive-exercises': (context) {
                final args =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>?;
                final competenceId = args?['competenceId'] as String? ?? '';
                final competenceName = args?['competenceName'] as String? ?? '';
                final userId = args?['userId'] as String? ?? ''; // ← AJOUT
                final count = args?['count'] as int? ?? 3;

                return ChangeNotifierProvider(
                  create: (_) => AdaptiveExerciseProvider(
                    dataSource: adaptiveExerciseDataSource,
                  ),
                  child: AdaptiveExercisePage(
                    competenceId: competenceId,
                    competenceName: competenceName,
                    userId: userId, // ← AJOUT
                    count: count,
                  ),
                  // child: AdaptiveExercisePage(
                  //   competenceId: competenceId,
                  //   competenceName: competenceName,
                  //   userId: userId, // ← AJOUT
                  //   count: count,
                  // ),
                );
              },

              '/subject-detail': (context) {
                final args =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>? ??
                    {};
                final userId = args['userId'] as String? ?? '';
                return ChangeNotifierProvider(
                  create: (_) => DiscoveryProvider(
                    repository: discoveryRepository,
                    userId: userId,
                  ),
                  child: SubjectDetailPage(
                    subjectId: args['subjectId'] as String? ?? '',
                    userId: userId,
                  ),
                );
              },
            },
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
