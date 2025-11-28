class UIConstants {
  UIConstants._();

  // --- Spacing (8px Grid System) ---
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacing2XL = 48.0;

  // --- Border Radius ---
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusCircular = 100.0;

  // --- Animations ---
  static const Duration animDurationFast = Duration(milliseconds: 200);
  static const Duration animDurationStandard = Duration(milliseconds: 300);
  static const Duration animDurationSlow = Duration(milliseconds: 500);

  // --- Touch Targets (Accessibility) ---
  // Minimum size for tappable areas (48x48dp is standard Android a11y)
  static const double minTouchTargetSize = 48.0;

  // --- Layout ---
  static const double maxContentWidth = 600.0; // For tablets/web
}
