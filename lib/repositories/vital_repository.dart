import '../models/vital_model.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';
import '../models/api_response.dart';
import '../utils/calculations.dart';

class VitalRepository {
  final DatabaseService databaseService;
  final ApiService apiService;
  
  VitalRepository({required this.databaseService, required this.apiService});
  
  Future<ApiResponse<Vital>> addVital(Vital vital) async {
    try {
      // Check if vitals already exist for this date
      final exists = await databaseService.vitalsExistForDate(
        vital.patientId, vital.visitDate);
      
      if (exists) {
        return ApiResponse.error('Vitals already recorded for this date');
      }
      
      // Save to local database first
      final localId = await databaseService.insertVital(vital);
      
      // Try to sync with API
      final apiResponse = await apiService.addVitals(vital.toJson());
      
      if (apiResponse.success) {
        return ApiResponse.success(vital.copyWith(id: localId));
      } else {
        return ApiResponse.success(vital.copyWith(id: localId),
            message: 'Vitals saved locally (offline mode)');
      }
    } catch (e) {
      return ApiResponse.error('Failed to add vitals: $e');
    }
  }
  
  Future<ApiResponse<List<Vital>>> getVitalsByPatient(String patientId) async {
    try {
      final vitals = await databaseService.getVitalsByPatient(patientId);
      return ApiResponse.success(vitals);
    } catch (e) {
      return ApiResponse.error('Failed to get vitals: $e');
    }
  }
  
  Future<ApiResponse<List<Map<String, dynamic>>>> getPatientsByVisitDate(DateTime date) async {
    try {
      final patients = await databaseService.getPatientsByVisitDate(date);
      return ApiResponse.success(patients);
    } catch (e) {
      return ApiResponse.error('Failed to get patients by date: $e');
    }
  }
}

// Extension for copying vital with new ID
extension VitalCopyWith on Vital {
  Vital copyWith({int? id, bool? isSynced}) {
    return Vital(
      id: id ?? this.id,
      patientId: patientId,
      visitDate: visitDate,
      height: height,
      weight: weight,
      bmi: bmi,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}