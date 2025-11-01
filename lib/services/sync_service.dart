import '../models/patient_model.dart';
import '../models/vital_model.dart';
import 'api_service.dart';
import 'database_service.dart';

class SyncService {
  final ApiService apiService;
  final DatabaseService databaseService;
  
  SyncService({required this.apiService, required this.databaseService});
  
  Future<void> syncAllData() async {
    await syncPatients();
    await syncVitals();
    // Add assessment sync methods here
  }
  
  Future<void> syncPatients() async {
    try {
      final patients = await databaseService.getPatients();
      final unsyncedPatients = patients.where((p) => !p.isSynced).toList();
      
      for (final patient in unsyncedPatients) {
        final response = await apiService.registerPatient(patient.toJson());
        if (response.success) {
          // Update sync status in local database
          // This would require adding update methods to DatabaseService
        }
      }
    } catch (e) {
      print('Error syncing patients: $e');
    }
  }
  
  Future<void> syncVitals() async {
    // Similar implementation for vitals
  }
}