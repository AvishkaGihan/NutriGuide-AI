import 'package:fpdart/fpdart.dart';
import 'package:nutriguide/core/services/secure_storage.dart';
import 'package:nutriguide/core/utils/error_handler.dart';
import 'package:nutriguide/features/auth/data/datasources/auth_remote_source.dart';
import 'package:nutriguide/features/auth/domain/entities/user.dart';
import 'package:nutriguide/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;

  AuthRepositoryImpl(this._remoteDataSource, this._secureStorage);

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final response = await _remoteDataSource.login(email, password);

      // Side Effect: Save Tokens securely
      await _secureStorage.saveAccessToken(response.accessToken);
      await _secureStorage.saveRefreshToken(response.refreshToken);

      return Right(response.user);
    } catch (e) {
      // Convert exceptions to Domain Failures
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, User>> register(
      {required String email,
      required String password,
      List<String>? goals,
      List<String>? restrictions}) async {
    try {
      final response = await _remoteDataSource.register(email, password,
          goals: goals, restrictions: restrictions);

      // Side Effect: Save Tokens securely
      await _secureStorage.saveAccessToken(response.accessToken);
      await _secureStorage.saveRefreshToken(response.refreshToken);

      return Right(response.user);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
      await _secureStorage.clearAll();
      return const Right(null);
    } catch (e) {
      // Even if API fails, we should clear local storage
      await _secureStorage.clearAll();
      return Left(Failure.fromException(e));
    }
  }
}
