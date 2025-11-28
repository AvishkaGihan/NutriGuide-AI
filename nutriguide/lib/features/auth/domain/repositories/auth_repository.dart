import 'package:fpdart/fpdart.dart';
import 'package:nutriguide/core/utils/error_handler.dart';
import 'package:nutriguide/features/auth/domain/entities/user.dart';

/// Abstract class defining the contract for Authentication operations.
///
/// This allows us to swap out the implementation (e.g., Firebase vs. Node.js backend)
/// without changing any business logic in the app.
abstract class AuthRepository {
  /// Logs in a user with email and password.
  /// Returns [Left(Failure)] on error, or [Right(User)] on success.
  Future<Either<Failure, User>> login(String email, String password);

  /// Registers a new user.
  /// Returns [Left(Failure)] on error, or [Right(User)] on success.
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    List<String>? goals,
    List<String>? restrictions,
  });

  /// Logs out the current user and clears session data.
  Future<Either<Failure, void>> logout();
}
