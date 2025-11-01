class Validators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validatePatientId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Patient ID is required';
    }
    if (value.length < 3) {
      return 'Patient ID must be at least 3 characters';
    }
    return null;
  }

  static String? validateName(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
      return '$fieldName can only contain letters and spaces';
    }
    return null;
  }

  static String? validateHeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Height is required';
    }
    final height = double.tryParse(value);
    if (height == null) {
      return 'Please enter a valid number';
    }
    if (height < 50 || height > 250) {
      return 'Height must be between 50 and 250 cm';
    }
    return null;
  }

  static String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Weight is required';
    }
    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Please enter a valid number';
    }
    if (weight < 2 || weight > 300) {
      return 'Weight must be between 2 and 300 kg';
    }
    return null;
  }

  static String? validateDate(DateTime? date, String fieldName) {
    if (date == null) {
      return '$fieldName is required';
    }
    if (date.isAfter(DateTime.now())) {
      return '$fieldName cannot be in the future';
    }
    return null;
  }

  static String? validateComments(String? value) {
    if (value != null && value.length > 500) {
      return 'Comments cannot exceed 500 characters';
    }
    return null;
  }

  // Authentication validators
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}