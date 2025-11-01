import 'package:shared_preferences/shared_preferences.dart';
import '../models/patient_model.dart';
import 'dart:convert';

class LocalStorageService {
  static const String _patientsKey = 'patients';

  static Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }

  // Patient methods
  static Future<void> savePatient(Patient patient) async {
    final prefs = await _prefs;
    final patients = await getPatients();
    
    // Check if patient already exists
    if (patients.any((p) => p.patientId == patient.patientId)) {
      throw Exception('Patient with ID ${patient.patientId} already exists');
    }
    
    patients.add(patient);
    final patientsJson = patients.map((p) => _patientToJson(p)).toList();
    await prefs.setString(_patientsKey, json.encode(patientsJson));
  }

  static Future<List<Patient>> getPatients() async {
    final prefs = await _prefs;
    final patientsJson = prefs.getString(_patientsKey);
    
    if (patientsJson == null) {
      return [];
    }
    
    try {
      final List<dynamic> patientsList = json.decode(patientsJson);
      return patientsList.map((p) => _patientFromJson(p)).toList();
    } catch (e) {
      print('Error parsing patients: $e');
      return [];
    }
  }

  static Future<Patient?> getPatientById(String patientId) async {
    final patients = await getPatients();
    try {
      return patients.firstWhere((p) => p.patientId == patientId);
    } catch (e) {
      return null;
    }
  }

  static Future<bool> patientExists(String patientId) async {
    final patients = await getPatients();
    return patients.any((p) => p.patientId == patientId);
  }

  // Helper methods
  static Map<String, dynamic> _patientToJson(Patient patient) {
    return {
      'id': patient.id,
      'patientId': patient.patientId,
      'firstName': patient.firstName,
      'lastName': patient.lastName,
      'dateOfBirth': patient.dateOfBirth.toIso8601String(),
      'gender': patient.gender,
      'registrationDate': patient.registrationDate.toIso8601String(),
      'isSynced': patient.isSynced,
    };
  }

  static Patient _patientFromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      patientId: json['patientId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      gender: json['gender'],
      registrationDate: DateTime.parse(json['registrationDate']),
      isSynced: json['isSynced'] ?? false,
    );
  }
}