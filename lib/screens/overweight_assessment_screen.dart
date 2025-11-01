import 'package:flutter/material.dart';
import '../models/overweight_assessment_model.dart';
import '../models/patient_model.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';
import '../repositories/assessment_repository.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/date_picker_field.dart';
import '../widgets/health_radio_group.dart';
import '../widgets/loading_indicator.dart';
import '../utils/helpers.dart';
import '../utils/validators.dart';

class OverweightAssessmentScreen extends StatefulWidget {
  final String? patientId;

  const OverweightAssessmentScreen({super.key, this.patientId});

  @override
  State<OverweightAssessmentScreen> createState() =>
      _OverweightAssessmentScreenState();
}

class _OverweightAssessmentScreenState
    extends State<OverweightAssessmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentsController = TextEditingController();

  DateTime? _visitDate;
  String? _generalHealth;
  String? _drugUsage;

  bool _isLoading = false;
  bool _loadingPatient = true;
  bool _loadingPatients = true;
  late AssessmentRepository _assessmentRepository;
  late DatabaseService _databaseService;
  String? _patientName;
  String? _currentPatientId;
  List<Patient> _patients = [];

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService();
    final apiService = ApiService();
    _assessmentRepository = AssessmentRepository(
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
          orElse: () => null as Patient,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Overweight Assessment',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.black),
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
                                      borderSide:
                                          BorderSide(color: Colors.blue),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.blue),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.blue),
                                    ),
                                    labelText: 'Choose a patient',
                                    labelStyle: TextStyle(color: Colors.black),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                  ),
                                  dropdownColor: Colors.white,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 14),
                                  icon: const Icon(Icons.arrow_drop_down,
                                      color: Colors.black),
                                  items: _patients.map((patient) {
                                    return DropdownMenuItem<String>(
                                      value: patient.patientId,
                                      child: Text(
                                        '${patient.fullName} (ID: ${patient.patientId})',
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 14),
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
              const Text(
                'Patient Visit Form B',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
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
              const SizedBox(height: 16),

              // GENERAL HEALTH - REQUIRED FIELD
              const Text(
                'General health? *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text(
                        'Good',
                        style: TextStyle(color: Colors.black),
                      ),
                      leading: Radio<String>(
                        value: 'Good',
                        groupValue: _generalHealth,
                        onChanged: (value) =>
                            setState(() => _generalHealth = value),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text(
                        'Poor',
                        style: TextStyle(color: Colors.black),
                      ),
                      leading: Radio<String>(
                        value: 'Poor',
                        groupValue: _generalHealth,
                        onChanged: (value) =>
                            setState(() => _generalHealth = value),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // DRUG USAGE - REQUIRED FIELD
              const Text(
                'Are you currently taking any drugs? *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text(
                        'Yes',
                        style: TextStyle(color: Colors.black),
                      ),
                      leading: Radio<String>(
                        value: 'Yes',
                        groupValue: _drugUsage,
                        onChanged: (value) =>
                            setState(() => _drugUsage = value),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text(
                        'No',
                        style: TextStyle(color: Colors.black),
                      ),
                      leading: Radio<String>(
                        value: 'No',
                        groupValue: _drugUsage,
                        onChanged: (value) =>
                            setState(() => _drugUsage = value),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // COMMENTS - REQUIRED FIELD
              CustomTextField(
                label: 'Comments *',
                hintText: 'Enter any additional comments',
                controller: _commentsController,
                maxLines: 3,
                validator: Validators.validateComments,
              ),
              const SizedBox(height: 32),

              _isLoading
                  ? LoadingIndicator(message: 'Saving assessment...')
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _close,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              side: const BorderSide(color: Colors.black),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
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
                            onPressed: _saveAssessment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
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

  Future<void> _saveAssessment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_visitDate == null ||
        _currentPatientId == null ||
        _generalHealth == null ||
        _drugUsage == null) {
      Helpers.showSnackBar(context, 'Please fill all required fields',
          isError: true);
      return;
    }

    // CHECK FOR EXISTING ASSESSMENT ON SAME DATE
    try {
      final assessmentExists = await _databaseService
          .overweightAssessmentExistsForDate(_currentPatientId!, _visitDate!);

      if (assessmentExists) {
        Helpers.showSnackBar(context,
            'Assessment already exists for this date. Please choose a different date.',
            isError: true);
        return;
      }
    } catch (e) {
      print('Error checking existing assessment: $e');
    }

    setState(() => _isLoading = true);

    try {
      final assessment = OverweightAssessment(
        patientId: _currentPatientId!,
        visitDate: _visitDate!,
        generalHealth: _generalHealth!,
        isTakingDrugs: _drugUsage == 'Yes',
        comments: _commentsController.text.trim(),
      );

      final response =
          await _assessmentRepository.addOverweightAssessment(assessment);

      if (response.success) {
        Helpers.showSnackBar(context, response.message);
        Navigator.pushReplacementNamed(context, '/patient-listing');
      } else {
        Helpers.showSnackBar(context, response.message, isError: true);
      }
    } catch (e) {
      Helpers.showSnackBar(context, 'Error saving assessment: $e',
          isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }
}
