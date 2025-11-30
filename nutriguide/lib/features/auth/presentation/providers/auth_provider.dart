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

// Provider to check if user is already logged in (from secure storage)
final checkInitialAuthProvider = FutureProvider<User?>((ref) async {
  final secureStorage = SecureStorageService();
  final token = await secureStorage.getAccessToken();
  if (token != null) {
    LoggingService.instance.info('Found stored token, user may be logged in');
    // Return a dummy user object to indicate logged in state
    // The actual user data will be fetched when needed
    return const User(id: 'pending', email: 'pending');
  }
  return null;
});

// 3. Auth State Provider (The main provider used by UI)
final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final notifier = AuthNotifier(repository, ref);
  // Initialize auth state from secure storage
  notifier._initializeFromStorage();
  return notifier;
});

// --- Notifier Class ---

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _repository;
  final Ref _ref;

  AuthNotifier(this._repository, this._ref)
      : super(const AsyncValue.data(null)) {
    LoggingService.instance.info('AuthNotifier initialized');
  }

  /// Initialize auth state from secure storage
  Future<void> _initializeFromStorage() async {
    final secureStorage = SecureStorageService();
    final token = await secureStorage.getAccessToken();
    if (token != null) {
      LoggingService.instance
          .info('Found stored token on init, user is already logged in');
      state = const AsyncValue.data(User(id: 'cached', email: 'cached'));
    }
  }

  /// Login
  Future<void> login(String email, String password) async {
    LoggingService.instance.info('Login called for: $email');
    state = const AsyncValue.loading();
    final result = await _repository.login(email, password);

    result.fold(
      (failure) {
        LoggingService.instance
            .error('Login failed: ${failure.message}', failure);
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (user) {
        LoggingService.instance.info('Login successful: ${user.email}');
        state = AsyncValue.data(user);
      },
    );
  }

  /// Register (called at the end of Onboarding)
  Future<void> register({
    required String email,
    required String password,
    List<String>? goals,
    List<String>? restrictions,
  }) async {
    LoggingService.instance.info('Register called for: $email');
    state = const AsyncValue.loading();
    final result = await _repository.register(
      email: email,
      password: password,
      goals: goals,
      restrictions: restrictions,
    );

    result.fold(
      (failure) {
        LoggingService.instance
            .error('Register failed: ${failure.message}', failure);
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (user) {
        LoggingService.instance.info('Register successful: ${user.email}');
        state = AsyncValue.data(user);
      },
    );
  }

  /// Logout
  Future<void> logout() async {
    LoggingService.instance.info('Logout called');
    state = const AsyncValue.loading();
    await _repository.logout();
    state = const AsyncValue.data(null);
    // Invalidate the initial auth check so it will re-check on next login
    _ref.invalidate(checkInitialAuthProvider);
    LoggingService.instance.info('Logout successful');
  }
}
