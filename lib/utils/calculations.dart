class Calculations {
  static double calculateBMI(double heightCm, double weightKg) {
    if (heightCm <= 0 || weightKg <= 0) return 0.0;
    double heightM = heightCm / 100;
    return double.parse((weightKg / (heightM * heightM)).toStringAsFixed(1));
  }

  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    return 'Overweight';
  }

  static String getBMICategoryColor(double bmi) {
    if (bmi < 18.5) return 'Orange';
    if (bmi < 25) return 'Green';
    return 'Red';
  }
}