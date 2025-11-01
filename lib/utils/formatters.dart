import 'package:intl/intl.dart';

class Formatters {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _displayDateFormat = DateFormat('dd/MM/yyyy');

  static String formatDateForDisplay(DateTime date) {
    return _displayDateFormat.format(date);
  }

  static String formatDateForAPI(DateTime date) {
    return _dateFormat.format(date);
  }

  static DateTime? parseDate(String dateString) {
    try {
      return _dateFormat.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  static String formatDouble(double value, {int decimalPlaces = 1}) {
    return value.toStringAsFixed(decimalPlaces);
  }

  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}