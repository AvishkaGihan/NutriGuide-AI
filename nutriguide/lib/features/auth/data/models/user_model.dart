import 'package:nutriguide/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.dietaryGoals,
    super.restrictions,
    super.allergies,
  });

  /// Factory constructor to create a UserModel from JSON data
  /// Expects the inner 'user' object from the API response
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle potential nested structure or direct fields based on API response
    // API returns: { "id": "...", "email": "...", "profile": { ... } }

    final profile = json['profile'] as Map<String, dynamic>? ?? {};

    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      dietaryGoals: (profile['dietary_goals'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      restrictions: (profile['restrictions'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      allergies: (profile['allergies'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  /// Convert UserModel to JSON (useful for local caching)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'profile': {
        'dietary_goals': dietaryGoals,
        'restrictions': restrictions,
        'allergies': allergies,
      },
    };
  }
}
