class Validators {
  // Private constructor to prevent instantiation
  Validators._();

  // Regex matches backend rules: 8+ chars, 1 uppercase, 1 lowercase, 1 number, 1 special char
  static final RegExp _passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

  // Standard Email Regex
  static final RegExp _emailRegex =
      RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');

  /// Validates an email address
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates password complexity
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!_passwordRegex.hasMatch(value)) {
      return 'Must contain uppercase, lowercase, number, and special char';
    }
    return null;
  }

  /// Validates "Confirm Password" matches "Password"
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validates required text fields (e.g., Name, Goal input)
  static String? required(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates a list selection (e.g., Dietary Preferences)
  static String? requiredList(List<dynamic>? list,
      {String message = 'Please select at least one option'}) {
    if (list == null || list.isEmpty) {
      return message;
    }
    return null;
  }
}
