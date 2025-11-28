import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutriguide/core/services/api_service.dart';
import 'package:nutriguide/core/services/secure_storage.dart';
import 'package:nutriguide/features/auth/data/datasources/auth_remote_source.dart';
import 'package:nutriguide/features/auth/data/repositories/auth_repository_impl.dart'; // Ensure correct import path based on previous step
import 'package:nutriguide/features/auth/domain/entities/user.dart';
import 'package:nutriguide/features/auth/domain/repositories/auth_repository.dart';
import 'package:nutriguide/core/services/logging_service.dart';

// --- Dependency Injection ---

// 1. Remote Source Provider
final authRemoteSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  // Assuming ApiService is provided globally or we instantiate it here for MVP
  // Ideally, use: ref.watch(apiServiceProvider)
  return AuthRemoteDataSourceImpl(ApiService(
    secureStorage: SecureStorageService(),
    logger: LoggingService.instance,
  ));
});

// 2. Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteSource = ref.watch(authRemoteSourceProvider);
  return AuthRepositoryImpl(remoteSource, SecureStorageService());
});

// 3. Auth State Provider (The main provider used by UI)
final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

// --- Notifier Class ---

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.data(null));

  /// Login
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await _repository.login(email, password);

    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  /// Register (called at the end of Onboarding)
  Future<void> register({
    required String email,
    required String password,
    List<String>? goals,
    List<String>? restrictions,
  }) async {
    state = const AsyncValue.loading();
    final result = await _repository.register(
      email: email,
      password: password,
      goals: goals,
      restrictions: restrictions,
    );

    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  /// Logout
  Future<void> logout() async {
    state = const AsyncValue.loading();
    await _repository.logout();
    state = const AsyncValue.data(null);
  }
}
