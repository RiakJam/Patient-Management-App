import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/patient_model.dart';
import '../models/vital_model.dart';
import '../models/general_assessment_model.dart';
import '../models/overweight_assessment_model.dart';
import '../core/constants.dart';

class DatabaseService {
  static Database? _database;
  static DatabaseService? _instance;
  
  // Private constructor - prevents direct instantiation
  DatabaseService._private();
  
  // Factory constructor - ensures single instance
  factory DatabaseService() {
    _instance ??= DatabaseService._private();
    return _instance!;
  }
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDatabase();
    return _database!;
  }
  
  Future<Database> _initializeDatabase() async {
    //  Ensure Flutter is initialized
    WidgetsFlutterBinding.ensureInitialized();
    
    final path = join(await getDatabasesPath(), AppConstants.databaseName);
    print('Database path: $path');
    
    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createTables,
    );
  }
  
  Future<void> _createTables(Database db, int version) async {
    print('Creating database tables...');
    
    // Patients table
    await db.execute('''
      CREATE TABLE patients(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id TEXT UNIQUE,
        first_name TEXT,
        last_name TEXT,
        date_of_birth TEXT,
        gender TEXT,
        registration_date TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');
    
    // Vitals table
    await db.execute('''
      CREATE TABLE vitals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id TEXT,
        visit_date TEXT,
        height REAL,
        weight REAL,
        bmi REAL,
        is_synced INTEGER DEFAULT 0
      )
    ''');
    
    // General assessments table
    await db.execute('''
      CREATE TABLE general_assessments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id TEXT,
        visit_date TEXT,
        general_health TEXT,
        has_been_on_diet INTEGER,
        comments TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');
    
    // Overweight assessments table
    await db.execute('''
      CREATE TABLE overweight_assessments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id TEXT,
        visit_date TEXT,
        general_health TEXT,
        is_taking_drugs INTEGER,
        comments TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');
    
    print('Database tables created successfully');
  }
  
  // ALL YOUR EXISTING METHODS STAY THE SAME
  Future<int> insertPatient(Patient patient) async {
    try {
      final db = await database;
      return await db.insert('patients', patient.toJson());
    } catch (e) {
      print('Error inserting patient: $e');
      rethrow;
    }
  }
  
  Future<List<Patient>> getPatients() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('patients');
      return List.generate(maps.length, (i) => Patient.fromMap(maps[i]));
    } catch (e) {
      print('Error getting patients: $e');
      rethrow;
    }
  }
  
  Future<Patient?> getPatientById(String patientId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'patients',
        where: 'patient_id = ?',
        whereArgs: [patientId],
      );
      if (maps.isNotEmpty) return Patient.fromMap(maps[0]);
      return null;
    } catch (e) {
      print(' Error getting patient by ID: $e');
      rethrow;
    }
  }
  
  Future<bool> patientExists(String patientId) async {
    try {
      final db = await database;
      final result = await db.query(
        'patients',
        where: 'patient_id = ?',
        whereArgs: [patientId],
      );
      return result.isNotEmpty;
    } catch (e) {
      print(' Error checking patient existence: $e');
      rethrow;
    }
  }
  
  // ✅ ADD THE MISSING METHODS HERE
  Future<bool> generalAssessmentExistsForDate(String patientId, DateTime visitDate) async {
    try {
      final db = await database;
      final formattedDate = '${visitDate.year}-${visitDate.month.toString().padLeft(2, '0')}-${visitDate.day.toString().padLeft(2, '0')}';
      
      final result = await db.query(
        'general_assessments',
        where: 'patient_id = ? AND visit_date = ?',
        whereArgs: [patientId, formattedDate],
      );
      return result.isNotEmpty;
    } catch (e) {
      print(' Error checking general assessment existence: $e');
      return false;
    }
  }
  
  Future<bool> overweightAssessmentExistsForDate(String patientId, DateTime visitDate) async {
    try {
      final db = await database;
      final formattedDate = '${visitDate.year}-${visitDate.month.toString().padLeft(2, '0')}-${visitDate.day.toString().padLeft(2, '0')}';
      
      final result = await db.query(
        'overweight_assessments',
        where: 'patient_id = ? AND visit_date = ?',
        whereArgs: [patientId, formattedDate],
      );
      return result.isNotEmpty;
    } catch (e) {
      print(' Error checking overweight assessment existence: $e');
      return false;
    }
  }
  
  // Vitals methods
  Future<int> insertVital(Vital vital) async {
    try {
      final db = await database;
      return await db.insert('vitals', vital.toJson());
    } catch (e) {
      print('Error inserting vital: $e');
      rethrow;
    }
  }
  
  Future<List<Vital>> getVitalsByPatient(String patientId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'vitals',
        where: 'patient_id = ?',
        whereArgs: [patientId],
        orderBy: 'visit_date DESC',
      );
      return List.generate(maps.length, (i) => Vital.fromMap(maps[i]));
    } catch (e) {
      print('Error getting vitals: $e');
      rethrow;
    }
  }
  
  Future<bool> vitalsExistForDate(String patientId, DateTime visitDate) async {
    try {
      final db = await database;
      final formattedDate = '${visitDate.year}-${visitDate.month.toString().padLeft(2, '0')}-${visitDate.day.toString().padLeft(2, '0')}';
      
      final result = await db.query(
        'vitals',
        where: 'patient_id = ? AND visit_date = ?',
        whereArgs: [patientId, formattedDate],
      );
      return result.isNotEmpty;
    } catch (e) {
      print('Error checking vitals existence: $e');
      rethrow;
    }
  }
  
  // General Assessment methods
  Future<int> insertGeneralAssessment(GeneralAssessment assessment) async {
    try {
      final db = await database;
      return await db.insert('general_assessments', {
        'patient_id': assessment.patientId,
        'visit_date': assessment.visitDate.toIso8601String(),
        'general_health': assessment.generalHealth,
        'has_been_on_diet': assessment.hasBeenOnDiet ? 1 : 0,
        'comments': assessment.comments,
        'is_synced': assessment.isSynced ? 1 : 0,
      });
    } catch (e) {
      print('Error inserting general assessment: $e');
      rethrow;
    }
  }
  
  // Overweight Assessment methods
  Future<int> insertOverweightAssessment(OverweightAssessment assessment) async {
    try {
      final db = await database;
      return await db.insert('overweight_assessments', {
        'patient_id': assessment.patientId,
        'visit_date': assessment.visitDate.toIso8601String(),
        'general_health': assessment.generalHealth,
        'is_taking_drugs': assessment.isTakingDrugs ? 1 : 0,
        'comments': assessment.comments,
        'is_synced': assessment.isSynced ? 1 : 0,
      });
    } catch (e) {
      print('Error inserting overweight assessment: $e');
      rethrow;
    }
  }
  
  // Patient listing with latest BMI
  Future<List<Map<String, dynamic>>> getPatientsWithLatestBMI() async {
    try {
      final db = await database;
      
      final result = await db.rawQuery('''
        SELECT 
          p.*,
          v.bmi as latest_bmi,
          v.visit_date as last_visit_date
        FROM patients p
        LEFT JOIN (
          SELECT patient_id, MAX(visit_date) as latest_date
          FROM vitals
          GROUP BY patient_id
        ) latest ON p.patient_id = latest.patient_id
        LEFT JOIN vitals v ON latest.patient_id = v.patient_id AND latest.latest_date = v.visit_date
        ORDER BY p.first_name, p.last_name
      ''');
      
      return result;
    } catch (e) {
      print('Error getting patients with BMI: $e');
      rethrow;
    }
  }
  
  // Date filtering
  Future<List<Map<String, dynamic>>> getPatientsByVisitDate(DateTime filterDate) async {
    try {
      final db = await database;
      final formattedDate = '${filterDate.year}-${filterDate.month.toString().padLeft(2, '0')}-${filterDate.day.toString().padLeft(2, '0')}';
      
      final result = await db.rawQuery('''
        SELECT 
          p.*,
          v.bmi as latest_bmi
        FROM patients p
        INNER JOIN vitals v ON p.patient_id = v.patient_id
        WHERE v.visit_date = ?
        ORDER BY p.first_name, p.last_name
      ''', [formattedDate]);
      
      return result;
    } catch (e) {
      print('Error getting patients by visit date: $e');
      rethrow;
    }
  }
  
  // Mark patient as synced
  Future<void> markPatientAsSynced(String patientId) async {
    try {
      final db = await database;
      await db.update(
        'patients',
        {'is_synced': 1},
        where: 'patient_id = ?',
        whereArgs: [patientId],
      );
      print('Patient $patientId marked as synced');
    } catch (e) {
      print('Error marking patient as synced: $e');
      rethrow;
    }
  }
  
  // Close database
  Future<void> close() async {
    try {
      final db = await database;
      await db.close();
      _database = null;
    } catch (e) {
      print('Error closing database: $e');
    }
  }
}