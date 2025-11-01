import '../core/constants.dart';

class Vital {
  final int? id;
  final String patientId;
  final DateTime visitDate;
  final double height; // in CM
  final double weight; // in KG
  final double bmi;
  final bool isSynced;

  Vital({
    this.id,
    required this.patientId,
    required this.visitDate,
    required this.height,
    required this.weight,
    required this.bmi,
    this.isSynced = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'visit_date': _formatDate(visitDate),
      'height': height,
      'weight': weight,
      'bmi': bmi,
    };
  }

  factory Vital.fromMap(Map<String, dynamic> map) {
    return Vital(
      id: map['id'],
      patientId: map['patient_id'],
      visitDate: DateTime.parse(map['visit_date']),
      height: map['height'],
      weight: map['weight'],
      bmi: map['bmi'],
      isSynced: map['is_synced'] == 1,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String get bmiCategory => AppConstants.getBmiCategory(bmi);
}