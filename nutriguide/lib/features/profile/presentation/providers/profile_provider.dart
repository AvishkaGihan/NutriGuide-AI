import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutriguide/core/services/api_service.dart';
import 'package:nutriguide/core/services/logging_service.dart';
import 'package:nutriguide/core/services/secure_storage.dart';
import 'package:nutriguide/features/profile/data/datasources/profile_remote_source.dart';
import 'package:nutriguide/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:nutriguide/features/profile/domain/entities/user_profile.dart';
import 'package:nutriguide/features/profile/domain/repositories/profile_repository.dart';

// --- Dependency Injection ---

final profileRemoteSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  // Ideally use ref.watch(apiServiceProvider) if available globally
  return ProfileRemoteDataSourceImpl(ApiService(
    secureStorage: SecureStorageService(),
    logger: LoggingService.instance,
  ));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final remoteSource = ref.watch(profileRemoteSourceProvider);
  return ProfileRepositoryImpl(remoteSource, SecureStorageService());
});

final profileProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<UserProfile>>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repository);
});

// --- Notifier Class ---

class ProfileNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  final ProfileRepository _repository;

  ProfileNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadProfile();
  }

  /// Fetch profile data on initialization
  Future<void> loadProfile() async {
    // Determine if we need to set loading state or background refresh
    // For now, let's keep previous data while loading if available
    if (state.value == null) {
      state = const AsyncValue.loading();
    }

    final result = await _repository.getProfile();

    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (profile) => state = AsyncValue.data(profile),
    );
  }

  /// Update dietary preferences
  Future<void> updatePreferences(UserProfile updatedProfile) async {
    // Optimistic update could go here, but strictly safe implementation waits for API
    state = const AsyncValue.loading();

    final result = await _repository.updateProfile(updatedProfile);

    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (profile) => state = AsyncValue.data(profile),
    );
  }

  /// Export Data (GDPR)
  /// Returns the JSON map directly to be handled by the UI (e.g. saving to file)
  Future<Map<String, dynamic>?> exportData() async {
    final result = await _repository.exportData();
    return result.fold(
      (failure) => null, // Handle error in UI
      (data) => data,
    );
  }

  /// Delete Account
  Future<bool> deleteAccount() async {
    final result = await _repository.deleteAccount();
    return result.isRight();
  }
}
