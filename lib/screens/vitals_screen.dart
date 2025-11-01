import 'package:flutter/material.dart';
import '../models/vital_model.dart';
import '../models/patient_model.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';
import '../repositories/vital_repository.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/date_picker_field.dart';
import '../widgets/loading_indicator.dart';
import '../utils/calculations.dart';
import '../utils/helpers.dart';
import '../utils/validators.dart';

class VitalsScreen extends StatefulWidget {
  final String? patientId;

  const VitalsScreen({super.key, this.patientId});

  @override
  State<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends State<VitalsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  DateTime? _visitDate;
  double _bmi = 0.0;
  String? _patientName;
  String? _currentPatientId;

  // Add these variables for patient selection
  List<Patient> _patients = [];
  bool _loadingPatients = true;

  bool _isLoading = false;
  bool _loadingPatient = true;
  late VitalRepository _vitalRepository;
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService();
    final apiService = ApiService();
    _vitalRepository = VitalRepository(
      databaseService: _databaseService,
      apiService: apiService,
    );
    _visitDate = DateTime.now();

    // Initialize with provided patientId or load patients for selection
    _currentPatientId = widget.patientId;

    if (_currentPatientId != null) {
      _loadPatientData();
    } else {
      _loadPatients(); // Load patients for dropdown
    }
  }

  // Add this method to load all patients
  Future<void> _loadPatients() async {
    try {
      final patients = await _databaseService.getPatients();
      setState(() {
        _patients = patients;
        _loadingPatients = false;
        _loadingPatient = false;
      });
    } catch (e) {
      setState(() {
        _loadingPatients = false;
        _loadingPatient = false;
      });
      print('Error loading patients: $e');
    }
  }

  Future<void> _loadPatientData() async {
    if (_currentPatientId != null) {
      try {
        // Use the existing getPatients method and filter by patientId
        final patients = await _databaseService.getPatients();
        final patient = patients.firstWhere(
          (p) => p.patientId == _currentPatientId,
          orElse: () => null as Patient, // This will return null if not found
        );

        if (patient != null) {
          setState(() {
            _patientName = patient.fullName;
            _loadingPatient = false;
          });
        } else {
          setState(() {
            _loadingPatient = false;
          });
          print('Patient not found with ID: $_currentPatientId');
        }
      } catch (e) {
        setState(() {
          _loadingPatient = false;
        });
        print('Error loading patient: $e');
      }
    } else {
      setState(() {
        _loadingPatient = false;
      });
    }
  }

  void _calculateBMI() {
    final height = double.tryParse(_heightController.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0;

    if (height > 0 && weight > 0) {
      setState(() {
        _bmi = Calculations.calculateBMI(height, weight);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Patient Vitals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // PATIENT SELECTION DROPDOWN - ADDED THIS
              if (_currentPatientId == null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: _loadingPatients
                      ? const Row(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 12),
                            Text('Loading patients...'),
                          ],
                        )
                      : _patients.isNotEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Select Patient *',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _currentPatientId,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.blue), // Blue border
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors
                                              .blue), // Blue border when enabled
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors
                                              .blue), // Blue border when focused
                                    ),
                                    labelText:
                                        'Choose a patient', // Use labelText instead of hintText
                                    labelStyle: TextStyle(
                                        color:
                                            Colors.black), // Black label text
                                    floatingLabelBehavior: FloatingLabelBehavior
                                        .always, // Always show label
                                  ),
                                  dropdownColor:
                                      Colors.white, // White dropdown background
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14), // Black text in dropdown
                                  icon: const Icon(Icons.arrow_drop_down,
                                      color:
                                          Colors.black), // Black dropdown arrow
                                  items: _patients.map((patient) {
                                    return DropdownMenuItem<String>(
                                      value: patient.patientId,
                                      child: Text(
                                        '${patient.fullName} (ID: ${patient.patientId})',
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                                14), // Black text for items
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (patientId) {
                                    setState(() {
                                      _currentPatientId = patientId;
                                    });
                                    _loadPatientData();
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select a patient';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            )
                          : const Column(
                              children: [
                                Icon(Icons.people_outline,
                                    size: 40, color: Colors.grey),
                                SizedBox(height: 8),
                                Text(
                                  'No patients found',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Please register patients first',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                ),
                const SizedBox(height: 16),
              ],

              // PATIENT INFORMATION DISPLAY
              if (_currentPatientId != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[100]!),
                  ),
                  child: _loadingPatient
                      ? const Row(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 12),
                            Text('Loading patient information...'),
                          ],
                        )
                      : _patientName != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Selected Patient:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Name: $_patientName',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  'ID: $_currentPatientId',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _currentPatientId = null;
                                      _patientName = null;
                                      _loadingPatient = true;
                                    });
                                    _loadPatients();
                                  },
                                  child: const Text('Change Patient'),
                                ),
                              ],
                            )
                          : const Text(
                              'Error: Patient information not found',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                ),
                const SizedBox(height: 16),
              ],

              // FORM HEADER
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: const Text(
                  'Patient Vitals Form',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // VISIT DATE - REQUIRED FIELD
              DatePickerField(
                label: 'Visit Date *',
                selectedDate: _visitDate,
                onDateSelected: (date) => setState(() => _visitDate = date),
                validator: (date) =>
                    Validators.validateDate(date, 'Visit date'),
              ),

              // HEIGHT - REQUIRED FIELD
              CustomTextField(
                label: 'Height (cm) *',
                hintText: 'Enter height in centimeters',
                controller: _heightController,
                keyboardType: TextInputType.number,
                validator: Validators.validateHeight,
                onChanged: (value) => _calculateBMI(),
              ),

              // WEIGHT - REQUIRED FIELD
              CustomTextField(
                label: 'Weight (kg) *',
                hintText: 'Enter weight in kilograms',
                controller: _weightController,
                keyboardType: TextInputType.number,
                validator: Validators.validateWeight,
                onChanged: (value) => _calculateBMI(),
              ),

              // BMI DISPLAY
              if (_bmi > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Calculated BMI *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _bmi.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          Calculations.getBMICategory(_bmi),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 32),

              _isLoading
                  ? LoadingIndicator(message: 'Saving vitals...')
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              side: const BorderSide(color: Colors.black),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _close,
                            child: const Text(
                              'Close',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _saveVitals,
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _close() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  Future<void> _saveVitals() async {
    if (!_formKey.currentState!.validate()) return;
    if (_visitDate == null || _currentPatientId == null) {
      Helpers.showSnackBar(context, 'Please fill all required fields',
          isError: true);
      return;
    }

    if (_bmi == 0) {
      Helpers.showSnackBar(
          context, 'Please enter height and weight to calculate BMI',
          isError: true);
      return;
    }

    // CHECK FOR EXISTING VITALS ON SAME DATE
    try {
      final vitalsExist = await _databaseService.vitalsExistForDate(
          _currentPatientId!, // Pass string directly
          _visitDate!);

      if (vitalsExist) {
        Helpers.showSnackBar(context,
            'Vitals already recorded for this date. Please choose a different date.',
            isError: true);
        return;
      }
    } catch (e) {
      print('Error checking existing vitals: $e');
    }

    setState(() => _isLoading = true);

    try {
      final vital = Vital(
        patientId: _currentPatientId!, // Pass string directly
        visitDate: _visitDate!,
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        bmi: _bmi,
      );

      final response = await _vitalRepository.addVital(vital);

      if (response.success) {
        Helpers.showSnackBar(context, response.message);

        // Navigate to appropriate assessment based on BMI
        if (_bmi <= 25) {
          Navigator.pushReplacementNamed(
            context,
            '/general-assessment',
            arguments: _currentPatientId,
          );
        } else {
          Navigator.pushReplacementNamed(
            context,
            '/overweight-assessment',
            arguments: _currentPatientId,
          );
        }
      } else {
        Helpers.showSnackBar(context, response.message, isError: true);
      }
    } catch (e) {
      Helpers.showSnackBar(context, 'Error saving vitals: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}
