class Patient {
  final int? id;
  final String patientId;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String gender;
  final DateTime registrationDate;
  final bool isSynced;

  Patient({
    this.id,
    required this.patientId,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.registrationDate,
    this.isSynced = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': _formatDate(dateOfBirth),
      'gender': gender,
      'registration_date': _formatDate(registrationDate),
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      patientId: map['patient_id'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      dateOfBirth: DateTime.parse(map['date_of_birth']),
      gender: map['gender'],
      registrationDate: DateTime.parse(map['registration_date']),
      isSynced: map['is_synced'] == 1,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  String get fullName => '$firstName $lastName';
}