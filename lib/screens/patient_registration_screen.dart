import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../repositories/patient_repository.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/date_picker_field.dart';
import '../widgets/gender_selector.dart';
import '../widgets/loading_indicator.dart';
import '../utils/helpers.dart';
import '../utils/validators.dart';

class PatientRegistrationScreen extends StatefulWidget {
  const PatientRegistrationScreen({super.key});

  @override
  State<PatientRegistrationScreen> createState() =>
      _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState extends State<PatientRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientIdController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  DateTime? _registrationDate;
  DateTime? _dateOfBirth;
  String? _selectedGender;

  bool _isLoading = false;
  late PatientRepository _patientRepository;

  @override
  void initState() {
    super.initState();
    print('🚀 PatientRegistrationScreen.initState() called');
    try {
      final apiService = ApiService();
      final databaseService = DatabaseService(); 
      _patientRepository = PatientRepository(
        apiService: apiService,
        databaseService: databaseService, 
      );
      _registrationDate = DateTime.now();
      print('PatientRegistrationScreen initialized successfully');
    } catch (e) {
      print('Error in PatientRegistrationScreen.initState(): $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🔄 PatientRegistrationScreen.build() called');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Patient Registration'),
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: const Text(
                  'Patient Registration Form',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Patient ID',
                hintText: 'Enter unique patient ID',
                controller: _patientIdController,
                validator: Validators.validatePatientId,
              ),
              DatePickerField(
                label: 'Registration Date',
                selectedDate: _registrationDate,
                onDateSelected: (date) =>
                    setState(() => _registrationDate = date),
                validator: (date) =>
                    Validators.validateDate(date, 'Registration date'),
              ),
              CustomTextField(
                label: 'First Name',
                hintText: 'Enter first name',
                controller: _firstNameController,
                validator: (value) =>
                    Validators.validateName(value, 'First name'),
              ),
              CustomTextField(
                label: 'Last Name',
                hintText: 'Enter last name',
                controller: _lastNameController,
                validator: (value) =>
                    Validators.validateName(value, 'Last name'),
              ),
              DatePickerField(
                label: 'Date of Birth',
                selectedDate: _dateOfBirth,
                onDateSelected: (date) => setState(() => _dateOfBirth = date),
                validator: (date) =>
                    Validators.validateDate(date, 'Date of birth'),
                lastDate: DateTime.now(),
              ),
              GenderSelector(
                selectedGender: _selectedGender,
                onGenderSelected: (gender) =>
                    setState(() => _selectedGender = gender),
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? LoadingIndicator(message: 'Registering patient...')
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              side: const BorderSide(color: Colors.blue),
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
                            onPressed: _savePatient,
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
    print('Close button pressed');
    Navigator.pushReplacementNamed(context, '/home');
  }

  Future<void> _savePatient() async {
    print('Save Patient button pressed');

    // Validate form
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }

    // Check required fields
    if (_registrationDate == null ||
        _dateOfBirth == null ||
        _selectedGender == null) {
      print('Missing required fields:');
      print('   - Registration Date: $_registrationDate');
      print('   - Date of Birth: $_dateOfBirth');
      print('   - Gender: $_selectedGender');
      Helpers.showSnackBar(context, 'Please fill all required fields',
          isError: true);
      return;
    }

    print('All validations passed');
    print('Patient Data:');
    print('   - Patient ID: ${_patientIdController.text.trim()}');
    print('   - First Name: ${_firstNameController.text.trim()}');
    print('   - Last Name: ${_lastNameController.text.trim()}');
    print('   - Date of Birth: $_dateOfBirth');
    print('   - Gender: $_selectedGender');
    print('   - Registration Date: $_registrationDate');

    setState(() => _isLoading = true);

    try {
      print('👤 Creating Patient object...');
      final patient = Patient(
        patientId: _patientIdController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        dateOfBirth: _dateOfBirth!,
        gender: _selectedGender!,
        registrationDate: _registrationDate!,
      );

      print('Calling patientRepository.registerPatient()...');
      final response = await _patientRepository.registerPatient(patient);

      if (response.success) {
        print('Patient registration successful: ${response.message}');
        Helpers.showSnackBar(context, response.message);

        print(
            'Navigating to Vitals screen with patient ID: ${patient.patientId}');
        Navigator.pushReplacementNamed(
          context,
          '/vitals',
          arguments: patient.patientId,
        );
      } else {
        print('Patient registration failed: ${response.message}');
        Helpers.showSnackBar(context, response.message, isError: true);
      }
    } catch (e) {
      print('ERROR in _savePatient(): $e');
      print('Stack trace: ${e.toString()}');
      Helpers.showSnackBar(context, 'Error saving patient: $e', isError: true);
    } finally {
      print('_savePatient() completed');
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    print('PatientRegistrationScreen.dispose() called');
    _patientIdController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}
