class ErrorMessages {
  ErrorMessages._();

  // --- Network & Server ---
  static const String networkConnection =
      'No internet connection. Please check your settings.';
  static const String serverError =
      'Something went wrong on our end. Please try again later.';
  static const String timeout = 'The request took too long. Please try again.';

  // --- Authentication ---
  static const String invalidCredentials =
      'The email or password you entered is incorrect.';
  static const String emailAlreadyInUse =
      'An account already exists with this email.';
  static const String sessionExpired =
      'Your session has expired. Please log in again.';
  static const String weakPassword =
      'Password must be at least 8 characters with 1 uppercase, 1 number, and 1 special character.';

  // --- Feature Specific ---
  static const String photoUploadFailed =
      'Could not upload photo. Please try a different image.';
  static const String noIngredientsDetected =
      'We couldn\'t verify ingredients. Try a clearer photo or add them manually.';
  static const String recipeGenerationFailed =
      'Chef AI is busy. Please try generating a recipe again.';

  // --- Generic ---
  static const String unknown = 'An unexpected error occurred.';
  static const String validationFailed =
      'Please check your input and try again.';
}
