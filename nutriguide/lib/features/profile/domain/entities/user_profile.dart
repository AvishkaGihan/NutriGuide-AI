import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String email;
  final List<String>? dietaryGoals;
  final List<String>? restrictions;
  final List<String>? allergies;
  final String? activityLevel;
  final String? ageRange;
  final String? gender;

  const UserProfile({
    required this.id,
    required this.email,
    this.dietaryGoals,
    this.restrictions,
    this.allergies,
    this.activityLevel,
    this.ageRange,
    this.gender,
  });

  /// Checks if the user has completed the basic onboarding setup
  bool get isProfileComplete =>
      (dietaryGoals != null && dietaryGoals!.isNotEmpty);

  @override
  List<Object?> get props => [
        id,
        email,
        dietaryGoals,
        restrictions,
        allergies,
        activityLevel,
        ageRange,
        gender,
      ];
}
