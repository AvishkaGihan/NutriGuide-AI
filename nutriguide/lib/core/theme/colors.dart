import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // --- Primary Brand Colors (Vitality Green) ---
  // Used for primary actions, scan buttons, and active states
  static const Color primary = Color(0xFF22C55E);
  static const Color primaryVariant =
      Color(0xFF16A34A); // Darker shade for hovers/press

  // --- Secondary Brand Colors ---
  // Used for supporting actions and accents
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryVariant = Color(0xFF059669);

  // --- Semantic Colors ---
  static const Color accent = Color(0xFF3B82F6); // Blue for info/links
  static const Color warning = Color(0xFFF59E0B); // Amber for cautions
  static const Color success = Color(0xFF10B981); // Green for confirmation
  static const Color error = Color(0xFFEF4444); // Red for errors
  static const Color info = Color(0xFF3B82F6);

  // --- Background Surfaces ---
  static const Color background =
      Color(0xFFF3F4F6); // Light gray app background
  static const Color surface = Colors.white; // Card backgrounds
  static const Color surfaceVariant = Color(0xFFF9FAFB); // Slightly off-white

  // --- Text Colors ---
  static const Color textDark = Color(0xFF1F2937); // Primary text
  static const Color textSecondary = Color(0xFF6B7280); // Metadata, subtitles
  static const Color textTertiary =
      Color(0xFF9CA3AF); // Placeholders, disabled text
  static const Color textInverse = Colors.white; // Text on primary buttons

  // --- Borders & Dividers ---
  static const Color border = Color(0xFFE5E7EB);
}
