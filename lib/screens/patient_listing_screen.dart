import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';
import '../repositories/patient_repository.dart';
import '../repositories/vital_repository.dart';
import '../widgets/patient_card.dart';
import '../widgets/date_picker_field.dart';
import '../widgets/loading_indicator.dart';
import '../utils/calculations.dart';
import '../utils/helpers.dart';
import '../utils/formatters.dart';

class PatientListingScreen extends StatefulWidget {
  const PatientListingScreen({super.key});

  @override
  State<PatientListingScreen> createState() => _PatientListingScreenState();
}

class _PatientListingScreenState extends State<PatientListingScreen> {
  final DatabaseService _databaseService = DatabaseService();
  late PatientRepository _patientRepository;
  late VitalRepository _vitalRepository;
  
  List<Map<String, dynamic>> _allPatients = [];
  List<Map<String, dynamic>> _filteredPatients = [];
  DateTime? _filterDate;
  bool _isLoading = false;
  bool _isFiltered = false;

  @override
  void initState() {
    super.initState();
    print('🚀 PatientListingScreen.initState() called');
    final apiService = ApiService();
    _patientRepository = PatientRepository(
      databaseService: _databaseService,
      apiService: apiService,
    );
    _vitalRepository = VitalRepository(
      databaseService: _databaseService,
      apiService: apiService,
    );
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    print(' _loadPatients() called');
    setState(() => _isLoading = true);
    
    try {
      print('Calling patientRepository.getPatientsWithBMI()...');
      final response = await _patientRepository.getPatientsWithBMI();
      print('Response received - success: ${response.success}');
      
      if (response.success) {
        print('Patients data: ${response.data}');
        setState(() {
          _allPatients = response.data!;
          _filteredPatients = _allPatients;
          _isLoading = false;
        });
        print('Loaded ${_allPatients.length} patients');
      } else {
        print('Failed to load patients: ${response.message}');
        Helpers.showSnackBar(context, response.message, isError: true);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('ERROR in _loadPatients(): $e');
      Helpers.showSnackBar(context, 'Error loading patients: $e', isError: true);
      setState(() => _isLoading = false);
    }
  }

  void _filterByDate() {
    print('_filterByDate() called with date: $_filterDate');
    if (_filterDate == null) {
      print('No date selected for filtering');
      Helpers.showSnackBar(context, 'Please select a date to filter', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      print('Filtering patients by registration date...');
      
      // Filter patients by registration date
      final filtered = _allPatients.where((patient) {
        try {
          final registrationDate = DateTime.parse(patient['registration_date']);
          return registrationDate.year == _filterDate!.year &&
                 registrationDate.month == _filterDate!.month &&
                 registrationDate.day == _filterDate!.day;
        } catch (e) {
          print('Error parsing date for patient: $e');
          return false;
        }
      }).toList();

      setState(() {
        _filteredPatients = filtered;
        _isFiltered = true;
        _isLoading = false;
      });
      
      print('Filtered to ${_filteredPatients.length} patients');
      Helpers.showSnackBar(
        context, 
        'Found ${_filteredPatients.length} patients registered on ${Formatters.formatDateForDisplay(_filterDate!)}',
      );
    } catch (e) {
      print('ERROR in _filterByDate(): $e');
      Helpers.showSnackBar(context, 'Error filtering patients: $e', isError: true);
      setState(() => _isLoading = false);
    }
  }

  void _clearFilter() {
    print('_clearFilter() called');
    setState(() {
      _filterDate = null;
      _isFiltered = false;
      _filteredPatients = _allPatients;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('PatientListingScreen.build() called - patients: ${_filteredPatients.length}, loading: $_isLoading');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Patient Listing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              print('Home button pressed');
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              print('Refresh button pressed');
              _loadPatients();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filter Section
            Card(
              color: Colors.white,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Filter by Registration Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DatePickerField(
                      label: 'Registration Date',
                      selectedDate: _filterDate,
                      onDateSelected: (date) {
                        print('Date selected: $date');
                        setState(() => _filterDate = date);
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              print('🔍 Apply Filter button pressed');
                              _filterByDate();
                            },
                            child: const Text('Apply Filter'),
                          ),
                        ),
                        if (_isFiltered) ...[
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black,
                                side: const BorderSide(color: Colors.blue),
                              ),
                              onPressed: () {
                                print('Clear Filter button pressed');
                                _clearFilter();
                              },
                              child: const Text('Clear Filter'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Patient Count
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Patients: ${_filteredPatients.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (_isFiltered)
                    Text(
                      'Filtered by: ${Formatters.formatDateForDisplay(_filterDate!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Patient Table
            Expanded(
              child: _isLoading
                  ? LoadingIndicator(message: 'Loading patients...')
                  : _filteredPatients.isEmpty
                      ? _buildEmptyState()
                      : _buildPatientTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.blue[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'No patients found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isFiltered 
                ? 'No patients registered on ${Formatters.formatDateForDisplay(_filterDate!)}'
                : 'Register a patient to get started',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          if (_isFiltered) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: _clearFilter,
              child: const Text('Show All Patients'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPatientTable() {
    print('Building patient table with ${_filteredPatients.length} patients');
    return Card(
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Table Header
            Container(
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'Patient Name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'Age',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'BMI Status',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Table Rows
            Expanded(
              child: ListView.builder(
                itemCount: _filteredPatients.length,
                itemBuilder: (context, index) {
                  final patient = _filteredPatients[index];
                  final patientName = '${patient['first_name']} ${patient['last_name']}';
                  final age = Calculations.calculateAge(
                    DateTime.parse(patient['date_of_birth']),
                  );
                  final bmi = patient['latest_bmi'] ?? 0.0;
                  final bmiCategory = Calculations.getBMICategory(bmi);
                  final bmiColor = _getBmiColor(bmi);

                  print('Rendering patient: $patientName, Age: $age, BMI: $bmiCategory');

                  return InkWell(
                    onTap: () {
                      print('👆 Patient tapped: $patientName');
                      _showPatientDetails(patient);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                patientName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                '$age years',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: bmiColor.withOpacity(0.1),
                                  border: Border.all(color: bmiColor),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  bmiCategory,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBmiColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.blue;
    return Colors.blue;
  }

  void _showPatientDetails(Map<String, dynamic> patient) {
    final patientName = '${patient['first_name']} ${patient['last_name']}';
    final age = Calculations.calculateAge(
      DateTime.parse(patient['date_of_birth']),
    );
    final bmi = patient['latest_bmi'] ?? 0.0;
    final bmiCategory = Calculations.getBMICategory(bmi);
    final gender = Helpers.getGenderDisplay(patient['gender']);
    final registrationDate = Formatters.formatDateForDisplay(
      DateTime.parse(patient['registration_date']),
    );

    print('Showing patient details for: $patientName');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Patient Details',
          style: TextStyle(color: Colors.black),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Name: $patientName', 
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              Text('Age: $age years', style: const TextStyle(color: Colors.black)),
              Text('Gender: $gender', style: const TextStyle(color: Colors.black)),
              Text('Patient ID: ${patient['patient_id']}', style: const TextStyle(color: Colors.black)),
              Text('Registration Date: $registrationDate', style: const TextStyle(color: Colors.black)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getBmiColor(bmi).withOpacity(0.1),
                  border: Border.all(color: _getBmiColor(bmi)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'BMI: ${bmi.toStringAsFixed(1)}', 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Text(
                      'Status: $bmiCategory',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
            onPressed: () {
              print('Closing patient details');
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}