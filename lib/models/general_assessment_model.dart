class GeneralAssessment {
  final int? id;
  final String patientId;
  final DateTime visitDate;
  final String generalHealth; // 'Good' or 'Poor'
  final bool hasBeenOnDiet;
  final String comments;
  final bool isSynced;

  GeneralAssessment({
    this.id,
    required this.patientId,
    required this.visitDate,
    required this.generalHealth,
    required this.hasBeenOnDiet,
    required this.comments,
    this.isSynced = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'visit_date': _formatDate(visitDate),
      'general_health': generalHealth,
      'on_diet': hasBeenOnDiet,
      'comments': comments,
    };
  }

  factory GeneralAssessment.fromMap(Map<String, dynamic> map) {
    return GeneralAssessment(
      id: map['id'],
      patientId: map['patient_id'],
      visitDate: DateTime.parse(map['visit_date']),
      generalHealth: map['general_health'],
      hasBeenOnDiet: map['has_been_on_diet'] == 1,
      comments: map['comments'],
      isSynced: map['is_synced'] == 1,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}