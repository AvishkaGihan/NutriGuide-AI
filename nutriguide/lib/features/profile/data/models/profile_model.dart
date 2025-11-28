import 'package:nutriguide/features/profile/domain/entities/user_profile.dart';

class ProfileModel extends UserProfile {
  const ProfileModel({
    required super.id,
    required super.email,
    super.dietaryGoals,
    super.restrictions,
    super.allergies,
    super.activityLevel,
    super.ageRange,
    super.gender,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      dietaryGoals: (json['dietary_goals'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      restrictions: (json['restrictions'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      allergies: (json['allergies'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      activityLevel: json['activity_level'] as String?,
      ageRange: json['age_range'] as String?,
      gender: json['gender'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dietary_goals': dietaryGoals,
      'restrictions': restrictions,
      'allergies': allergies,
      'activity_level': activityLevel,
      'age_range': ageRange,
      'gender': gender,
    };
  }

  // Create a copy of the model with new values (useful for optimistic updates)
  ProfileModel copyWith({
    String? id,
    String? email,
    List<String>? dietaryGoals,
    List<String>? restrictions,
    List<String>? allergies,
    String? activityLevel,
    String? ageRange,
    String? gender,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      dietaryGoals: dietaryGoals ?? this.dietaryGoals,
      restrictions: restrictions ?? this.restrictions,
      allergies: allergies ?? this.allergies,
      activityLevel: activityLevel ?? this.activityLevel,
      ageRange: ageRange ?? this.ageRange,
      gender: gender ?? this.gender,
    );
  }
}
