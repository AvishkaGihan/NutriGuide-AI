import 'package:fpdart/fpdart.dart';
import 'package:nutriguide/core/services/secure_storage.dart';
import 'package:nutriguide/core/utils/error_handler.dart';
import 'package:nutriguide/features/profile/data/datasources/profile_remote_source.dart';
import 'package:nutriguide/features/profile/data/models/profile_model.dart';
import 'package:nutriguide/features/profile/domain/entities/user_profile.dart';
import 'package:nutriguide/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;

  ProfileRepositoryImpl(this._remoteDataSource, this._secureStorage);

  @override
  Future<Either<Failure, UserProfile>> getProfile() async {
    try {
      final profile = await _remoteDataSource.getProfile();
      return Right(profile);
    } catch (e) {
      // In a real app, distinguish between NetworkException, generic Exception etc.
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateProfile(
      UserProfile profile) async {
    try {
      // Cast to Model to access toJson or create a mapper
      final profileModel = ProfileModel(
        id: profile.id,
        email: profile.email,
        dietaryGoals: profile.dietaryGoals,
        restrictions: profile.restrictions,
        allergies: profile.allergies,
        activityLevel: profile.activityLevel,
        ageRange: profile.ageRange,
        gender: profile.gender,
      );

      final updatedProfile =
          await _remoteDataSource.updateProfile(profileModel);
      return Right(updatedProfile);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await _remoteDataSource.deleteAccount();
      // Clear local storage upon successful deletion
      await _secureStorage.clearAll();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportData() async {
    try {
      final data = await _remoteDataSource.exportData();
      return Right(data);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
