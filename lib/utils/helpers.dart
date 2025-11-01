import 'package:flutter/material.dart';

class Helpers {
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static Future<void> showLoadingDialog(BuildContext context, String message) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Text(message),
          ],
        ),
      ),
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  static String getGenderDisplay(String gender) {
    switch (gender.toLowerCase()) {
      case 'm': return 'Male';
      case 'f': return 'Female';
      case 'o': return 'Other';
      default: return _capitalizeFirst(gender);
    }
  }

  static String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static Color getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.orange;
    if (bmi < 25) return Colors.green;
    return Colors.red;
  }
}