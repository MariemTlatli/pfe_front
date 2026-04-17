import 'package:front/core/api/api_consumer.dart';
import 'package:front/core/api/endpoints.dart';
import 'package:front/data/models/competence_model.dart';
import 'package:front/data/models/domain_model.dart';

import 'package:front/data/models/subject_model.dart';
import 'package:front/data/models/enrollment_model.dart';

abstract class DiscoveryRemoteDataSource {
  Future<List<DomainModel>> getDomains();
  Future<List<SubjectModel>> getSubjectsForDomain(String domainId);
  Future<BulkEnrollResponseModel> enrollSubject({
    required String userId,
    required String subjectId,
  });
  Future<UserSubjectDetailModel> getSubjectDetails({
    required String userId,
    required String subjectId,
  });
  Future<List<SubjectModel>> getUserEnrolledSubjects(String userId);
  Future<List<SubjectModel>> getAvailableSubjects(String userId);
  Future<List<CompetenceModel>> getCompetences(String subjectId);
}

class DiscoveryRemoteDataSourceImpl implements DiscoveryRemoteDataSource {
  final ApiConsumer apiConsumer;

  DiscoveryRemoteDataSourceImpl({required this.apiConsumer});

  @override
  Future<List<DomainModel>> getDomains() async {
    final response = await apiConsumer.get(Endpoints.domains);

    List data;
    if (response is List) {
      data = response;
    } else if (response is Map && response['domains'] is List) {
      data = response['domains'];
    } else if (response is Map && response['data'] is List) {
      data = response['data'];
    } else {
      data = [];
    }

    return data.map((domain) {
      return DomainModel.fromJson(domain as Map<String, dynamic>);
    }).toList();
  }

  @override
  Future<List<SubjectModel>> getSubjectsForDomain(String domainId) async {
    final response = await apiConsumer.get(
      '${Endpoints.domains}/$domainId/subjects',
    );
    List data;
    if (response is List) {
      data = response;
    } else if (response is Map && response['subjects'] is List) {
      data = response['subjects'];
    } else if (response is Map && response['data'] is List) {
      data = response['data'];
    } else {
      data = [];
    }

    return data.map((subject) {
      return SubjectModel.fromJson(subject as Map<String, dynamic>);
    }).toList();
  }

  @override
  Future<List<SubjectModel>> getUserEnrolledSubjects(String userId) async {
    final response = await apiConsumer.get(
      '${Endpoints.userSubjects}/$userId/subjects',
    );
    List data;
    if (response is List) {
      data = response;
    } else if (response is Map && response['subjects'] is List) {
      data = response['subjects'];
    } else if (response is Map && response['data'] is List) {
      data = response['data'];
    } else {
      data = [];
    }

    return data.map((subject) {
      // Create SubjectModel and force isEnrolled = true as these are from the enrolled endpoint
      return SubjectModel.fromJson(
        subject as Map<String, dynamic>,
      ).copyWith(isEnrolled: true);
    }).toList();
  }

  @override
  Future<List<SubjectModel>> getAvailableSubjects(String userId) async {
    final response = await apiConsumer.get(
      '${Endpoints.userSubjects}/$userId/available-subjects',
    );
    List data;
    if (response is List) {
      data = response;
    } else if (response is Map && response['subjects'] is List) {
      data = response['subjects'];
    } else if (response is Map && response['data'] is List) {
      data = response['data'];
    } else {
      data = [];
    }

    return data.map((subject) {
      return SubjectModel.fromJson(subject as Map<String, dynamic>);
    }).toList();
  }

  @override
  Future<BulkEnrollResponseModel> enrollSubject({
    required String userId,
    required String subjectId,
  }) async {
    final response = await apiConsumer.post(
      '${Endpoints.userSubjects}/$userId/enroll-multiple',
      data: {
        'subject_ids': [subjectId],
      },
    );

    return BulkEnrollResponseModel.fromJson(response);
  }

  @override
  Future<UserSubjectDetailModel> getSubjectDetails({
    required String userId,
    required String subjectId,
  }) async {
    final response = await apiConsumer.get(
      '${Endpoints.userSubjects}/$userId/subjects/$subjectId',
    );

    return UserSubjectDetailModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<List<CompetenceModel>> getCompetences(String subjectId) async {
    final response = await apiConsumer.get(
      '/api/subjects/$subjectId/competences',
    );
    List data;
    if (response is List) {
      data = response;
    } else if (response is Map && response['competences'] is List) {
      data = response['competences'];
    } else if (response is Map && response['data'] is List) {
      data = response['data'];
    } else {
      data = [];
    }

    return data.map((competence) {
      return CompetenceModel.fromJson(competence as Map<String, dynamic>);
    }).toList();
  }
}
