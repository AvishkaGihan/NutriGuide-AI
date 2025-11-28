import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final List<String>? dietaryGoals;
  final List<String>? restrictions;
  final List<String>? allergies;

  const User({
    required this.id,
    required this.email,
    this.dietaryGoals,
    this.restrictions,
    this.allergies,
  });

  @override
  List<Object?> get props => [id, email, dietaryGoals, restrictions, allergies];
}
