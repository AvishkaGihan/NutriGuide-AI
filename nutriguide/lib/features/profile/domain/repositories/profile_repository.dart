import 'package:fpdart/fpdart.dart';
import 'package:nutriguide/core/utils/error_handler.dart';
import 'package:nutriguide/features/profile/domain/entities/user_profile.dart';

abstract class ProfileRepository {
  /// Fetches the current user's full profile
  Future<Either<Failure, UserProfile>> getProfile();

  /// Updates specific fields in the user's profile
  Future<Either<Failure, UserProfile>> updateProfile(UserProfile profile);

  /// Permanently deletes the user's account and data
  Future<Either<Failure, void>> deleteAccount();

  /// Exports all user data (GDPR)
  Future<Either<Failure, Map<String, dynamic>>> exportData();
}
