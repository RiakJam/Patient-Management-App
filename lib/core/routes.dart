import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/patient_registration_screen.dart';
import '../screens/vitals_screen.dart';
import '../screens/general_assessment_screen.dart';
import '../screens/overweight_assessment_screen.dart';
import '../screens/patient_listing_screen.dart';
import '../screens/assessments_screen.dart'; // Add this import

class AppRoutes {
  static Map<String, WidgetBuilder> get routes => {
    '/login': (context) => const LoginScreen(),
    '/home': (context) => const HomeScreen(),
    '/registration': (context) => const PatientRegistrationScreen(),
    '/vitals': (context) => VitalsScreen(patientId: null),
    '/general-assessment': (context) => const GeneralAssessmentScreen(patientId: null),
    '/overweight-assessment': (context) => const OverweightAssessmentScreen(patientId: null),
    '/patient-listing': (context) => const PatientListingScreen(),
    '/assessments': (context) => const AssessmentsScreen(), // Add this line
  };
}