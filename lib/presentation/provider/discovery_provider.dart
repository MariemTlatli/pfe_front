import 'package:flutter/material.dart';
import 'package:front/data/data_sources/discovery_remote_data_source.dart';
import 'package:front/data/models/domain_model.dart';
import 'package:front/data/models/subject_model.dart';
import 'package:front/data/models/lesson_model.dart';
import 'package:front/data/models/enrollment_model.dart';

// State Class
class DiscoveryState {
  final List<DomainModel> domains;
  final List<SubjectModel> currentDomainSubjects;
  final DomainModel? selectedDomain;
  final SubjectModel? selectedSubject;
  UserSubjectDetailModel? selectedSubjectDetail;
  final LessonModel? selectedLesson;

  final bool isLoading;
  final bool isEnrolling;
  final String? error;

  DiscoveryState({
    this.domains = const [],
    this.currentDomainSubjects = const [],
    this.selectedDomain,
    this.selectedSubject,
    this.selectedLesson,
    this.selectedSubjectDetail, // ✅ AJOUT ICI
    this.isLoading = false,
    this.isEnrolling = false,
    this.error,
  });

  DiscoveryState copyWith({
    List<DomainModel>? domains,
    List<SubjectModel>? currentDomainSubjects,
    DomainModel? selectedDomain,
    SubjectModel? selectedSubject,
    UserSubjectDetailModel? selectedSubjectDetail,
    LessonModel? selectedLesson,
    bool? isLoading,
    bool? isEnrolling,
    String? error,
  }) {
    return DiscoveryState(
      domains: domains ?? this.domains,
      currentDomainSubjects: currentDomainSubjects ?? this.currentDomainSubjects,
      selectedDomain: selectedDomain ?? this.selectedDomain,
      selectedSubject: selectedSubject ?? this.selectedSubject,
      selectedSubjectDetail:
          selectedSubjectDetail ?? this.selectedSubjectDetail,
      selectedLesson: selectedLesson ?? this.selectedLesson,
      isLoading: isLoading ?? this.isLoading,
      isEnrolling: isEnrolling ?? this.isEnrolling,
      error: error,
    );
  }
}

// Provider (ChangeNotifier)
class DiscoveryProvider extends ChangeNotifier {
  DiscoveryRemoteDataSourceImpl _repository;
  final String userId;

  DiscoveryState _state = DiscoveryState();
  DiscoveryState get state => _state;

  DiscoveryProvider({required DiscoveryRemoteDataSourceImpl repository, required this.userId}) 
    : _repository = repository {
    // Evite notifyListeners pendant le montage des providers.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  void _updateState(DiscoveryState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> _init() async {
    await getDomains();
  }

  Future<void> getDomains() async {
    _updateState(state.copyWith(isLoading: true, error: null));
    try {
      final domains = await _repository.getDomains();
      _updateState(state.copyWith(domains: domains, isLoading: false));
    } catch (e) {
      _updateState(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> getSubjectsForDomain(String domainId) async {
    _updateState(state.copyWith(isLoading: true, error: null));
    try {
      final domain = state.domains.firstWhere((d) => d.id == domainId);
      final subjects = await _repository.getSubjectsForDomain(domainId);
      _updateState(state.copyWith(
        selectedDomain: domain,
        currentDomainSubjects: subjects,
        isLoading: false,
      ));
    } catch (e) {
      _updateState(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<bool> enrollSubject(String subjectId) async {
    _updateState(state.copyWith(isEnrolling: true, error: null));
    try {
      await _repository.enrollSubject(
        userId: userId,
        subjectId: subjectId,
      );
      
      final updated = state.currentDomainSubjects
          .map((s) => s.id == subjectId ? s.copyWith(isEnrolled: true) : s)
          .toList();
      
      _updateState(state.copyWith(
        currentDomainSubjects: updated,
        isEnrolling: false,
      ));
      return true;
    } catch (e) {
      _updateState(state.copyWith(isEnrolling: false, error: e.toString()));
      return false;
    }
  }
 
  Future<void> selectSubject(String subjectId) async {
    _updateState(state.copyWith(isLoading: true, error: null));
    try {
      SubjectModel? subject;
      
      // 1. First look in current state
      try {
        subject = state.currentDomainSubjects.firstWhere((s) => s.id == subjectId);
      } catch (_) {
        // Not in current list (e.g. direct link or fresh enroll)
        // 2. Fetch specific details or enrollment
        final detail = await _repository.getSubjectDetails(userId: userId, subjectId: subjectId);
        
        // Use the subject already present in the detail
        subject = detail.subject;
      }

      if (subject != null) {
        _updateState(state.copyWith(
          selectedSubject: subject,
          isLoading: false,
        ));
        // await getCompetences(subjectId);
      } else {
        _updateState(state.copyWith(isLoading: false, error: "Matiere non trouvee"));
      }
    } catch (e) {
      _updateState(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // Future<void> getCompetences(String subjectId) async {
  //   _updateState(state.copyWith(isLoading: true, error: null));
  //   try {
  //     // ignore: unused_local_variable
  //     final competences = await _repository.getCompetences(subjectId);
  //     // TODO: Store competences in state when CompetenceModel list is added to DiscoveryState
  //     _updateState(state.copyWith(isLoading: false));
  //   } catch (e) {
  //     _updateState(state.copyWith(isLoading: false, error: e.toString()));
  //   }
  // }
  void clearError() {
    _updateState(state.copyWith(error: null));
  }
}
