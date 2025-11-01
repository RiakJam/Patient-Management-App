// import '../models/patient_model.dart';
// import '../services/local_storage_service.dart';
// import '../services/api_service.dart';
// import '../services/database_service.dart'; // ✅ add this import
// import '../models/api_response.dart';

// class PatientRepository {
//   final ApiService apiService;
//   final DatabaseService? databaseService; // ✅ optional, so old code won’t break
  
//   PatientRepository({
//     required this.apiService,
//     this.databaseService,
//   });

//   Future<ApiResponse<Patient>> registerPatient(Patient patient) async {
//     print('🔍 PatientRepository.registerPatient() called');
    
//     try {
//       print('📋 Patient Data for registration:');
//       print('   - Patient ID: ${patient.patientId}');

//       // Check if patient already exists using SharedPreferences
//       print('🔎 Checking if patient already exists...');
//       final exists = await LocalStorageService.patientExists(patient.patientId);
//       print('   - Patient exists: $exists');
      
//       if (exists) {
//         print('❌ Patient with ID ${patient.patientId} already exists');
//         return ApiResponse.error('Patient with ID ${patient.patientId} already exists');
//       }

//       // Save to local storage first
//       print('💾 Saving patient to local storage...');
//       await LocalStorageService.savePatient(patient);
//       print('   - Patient saved locally successfully');

//       // Try to sync with API
//       print('🌐 Attempting to sync with API...');
//       final apiResponse = await apiService.registerPatient(patient.toJson());
//       print('   - API Response: ${apiResponse.success}');
//       print('   - API Message: ${apiResponse.message}');

//       if (apiResponse.success) {
//         print('✅ Patient synced successfully with API');
//         return ApiResponse.success(patient);
//       } else {
//         print('⚠️ API sync failed, but patient saved locally');
//         return ApiResponse.success(
//           patient, 
//           message: 'Patient saved locally (offline mode)'
//         );
//       }
//     } catch (e) {
//       print('💥 ERROR in PatientRepository.registerPatient(): $e');
//       print('🔄 Stack trace: ${e.toString()}');
//       return ApiResponse.error('Failed to register patient: $e');
//     }
//   }

//   Future<ApiResponse<List<Patient>>> getPatients() async {
//     try {
//       final patients = await LocalStorageService.getPatients();
//       return ApiResponse.success(patients);
//     } catch (e) {
//       return ApiResponse.error('Failed to get patients: $e');
//     }
//   }

//   Future<ApiResponse<List<Map<String, dynamic>>>> getPatientsWithBMI() async {
//     try {
//       final patients = await LocalStorageService.getPatients();
//       final patientsData = patients.map((patient) {
//         return {
//           'patient_id': patient.patientId,
//           'first_name': patient.firstName,
//           'last_name': patient.lastName,
//           'date_of_birth': patient.dateOfBirth.toIso8601String(),
//           'gender': patient.gender,
//           'registration_date': patient.registrationDate.toIso8601String(),
//           'latest_bmi': 0.0,
//         };
//       }).toList();
      
//       return ApiResponse.success(patientsData);
//     } catch (e) {
//       return ApiResponse.error('Failed to get patients with BMI: $e');
//     }
//   }
// }
import '../models/patient_model.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../models/api_response.dart';

class PatientRepository {
  final ApiService apiService;
  final DatabaseService databaseService;
  
  PatientRepository({
    required this.apiService,
    required this.databaseService,
  });

  Future<ApiResponse<Patient>> registerPatient(Patient patient) async {
    print('🔍 PatientRepository.registerPatient() called');
    
    try {
      print('📋 Patient Data for registration:');
      print('   - Patient ID: ${patient.patientId}');

      // Check if patient already exists using DatabaseService
      print('🔎 Checking if patient already exists...');
      final exists = await databaseService.patientExists(patient.patientId);
      print('   - Patient exists: $exists');
      
      if (exists) {
        print('❌ Patient with ID ${patient.patientId} already exists');
        return ApiResponse.error('Patient with ID ${patient.patientId} already exists');
      }

      // Save to database first
      print('💾 Saving patient to database...');
      final patientId = await databaseService.insertPatient(patient);
      print('   - Patient saved to database successfully with ID: $patientId');

      // Try to sync with API
      print('🌐 Attempting to sync with API...');
      final apiResponse = await apiService.registerPatient(patient.toJson());
      print('   - API Response: ${apiResponse.success}');
      print('   - API Message: ${apiResponse.message}');

      if (apiResponse.success) {
        print('✅ Patient synced successfully with API');
        // Update sync status in database
        await _markPatientAsSynced(patient.patientId);
        return ApiResponse.success(patient, message: 'Patient registered successfully');
      } else {
        print('⚠️ API sync failed, but patient saved to database');
        return ApiResponse.success(
          patient, 
          message: 'Patient saved locally (offline mode)'
        );
      }
    } catch (e) {
      print('💥 ERROR in PatientRepository.registerPatient(): $e');
      return ApiResponse.error('Failed to register patient: $e');
    }
  }

  // Helper method to mark patient as synced
  Future<void> _markPatientAsSynced(String patientId) async {
    try {
      final db = await databaseService.database;
      await db.update(
        'patients',
        {'is_synced': 1},
        where: 'patient_id = ?',
        whereArgs: [patientId],
      );
      print('✅ Patient marked as synced in database');
    } catch (e) {
      print('⚠️ Could not mark patient as synced: $e');
    }
  }

  Future<ApiResponse<List<Patient>>> getPatients() async {
    try {
      final patients = await databaseService.getPatients();
      return ApiResponse.success(patients);
    } catch (e) {
      return ApiResponse.error('Failed to get patients: $e');
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getPatientsWithBMI() async {
    try {
      final patientsData = await databaseService.getPatientsWithLatestBMI();
      return ApiResponse.success(patientsData);
    } catch (e) {
      return ApiResponse.error('Failed to get patients with BMI: $e');
    }
  }

  // Add method for date filtering
  Future<ApiResponse<List<Map<String, dynamic>>>> getPatientsByVisitDate(DateTime date) async {
    try {
      final patientsData = await databaseService.getPatientsByVisitDate(date);
      return ApiResponse.success(patientsData);
    } catch (e) {
      return ApiResponse.error('Failed to get patients by visit date: $e');
    }
  }
}
