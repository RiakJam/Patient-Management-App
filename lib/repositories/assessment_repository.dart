import '../models/general_assessment_model.dart';
import '../models/overweight_assessment_model.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';
import '../models/api_response.dart';

class AssessmentRepository {
  final DatabaseService databaseService;
  final ApiService apiService;
  
  AssessmentRepository({required this.databaseService, required this.apiService});
  
  Future<ApiResponse<GeneralAssessment>> addGeneralAssessment(GeneralAssessment assessment) async {
    try {
      final localId = await databaseService.insertGeneralAssessment(assessment);
      
      // Try to sync with API
      final apiResponse = await apiService.addVisit(assessment.toJson());
      
      if (apiResponse.success) {
        return ApiResponse.success(assessment.copyWith(id: localId));
      } else {
        return ApiResponse.success(assessment.copyWith(id: localId),
            message: 'Assessment saved locally (offline mode)');
      }
    } catch (e) {
      return ApiResponse.error('Failed to add assessment: $e');
    }
  }
  
  Future<ApiResponse<OverweightAssessment>> addOverweightAssessment(OverweightAssessment assessment) async {
    try {
      final localId = await databaseService.insertOverweightAssessment(assessment);
      
      // Try to sync with API
      final apiResponse = await apiService.addVisit(assessment.toJson());
      
      if (apiResponse.success) {
        return ApiResponse.success(assessment.copyWith(id: localId));
      } else {
        return ApiResponse.success(assessment.copyWith(id: localId),
            message: 'Assessment saved locally (offline mode)');
      }
    } catch (e) {
      return ApiResponse.error('Failed to add assessment: $e');
    }
  }
}

// Extensions for copying assessments
extension GeneralAssessmentCopyWith on GeneralAssessment {
  GeneralAssessment copyWith({int? id, bool? isSynced}) {
    return GeneralAssessment(
      id: id ?? this.id,
      patientId: patientId,
      visitDate: visitDate,
      generalHealth: generalHealth,
      hasBeenOnDiet: hasBeenOnDiet,
      comments: comments,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}

extension OverweightAssessmentCopyWith on OverweightAssessment {
  OverweightAssessment copyWith({int? id, bool? isSynced}) {
    return OverweightAssessment(
      id: id ?? this.id,
      patientId: patientId,
      visitDate: visitDate,
      generalHealth: generalHealth,
      isTakingDrugs: isTakingDrugs,
      comments: comments,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}