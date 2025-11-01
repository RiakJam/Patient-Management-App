class ApiConstants {
  static const String baseUrl = 'https://patientvisitapis.intellisoftkenya.com/api/';
  
  // Authentication endpoints
  static const String signup = 'user/signup';
  static const String login = 'user/signin';
  
  // Patient endpoints
  static const String registerPatient = 'patients/register';
  static const String listPatients = 'patients/list';
  static const String showPatient = 'patients/show/';
  
  // Vitals endpoints
  static const String addVitals = 'vitals/add';
  
  // Visit endpoints
  static const String viewVisits = 'visits/view';
  static const String addVisit = 'visits/add';
}

class AppConstants {
  static const String appName = 'Patient Management';
  static const String databaseName = 'patient_database.db';
  static const int databaseVersion = 1;
  
  // BMI Categories
  static const double underweightThreshold = 18.5;
  static const double normalThreshold = 25.0;
  
  static String getBmiCategory(double bmi) {
    if (bmi < underweightThreshold) return 'Underweight';
    if (bmi < normalThreshold) return 'Normal';
    return 'Overweight';
  }
  
  static bool shouldShowGeneralAssessment(double bmi) => bmi < normalThreshold;
  static bool shouldShowOverweightAssessment(double bmi) => bmi >= normalThreshold;
}

class HiveBoxes {
  static const String patients = 'patients';
  static const String vitals = 'vitals';
  static const String assessments = 'assessments';
}