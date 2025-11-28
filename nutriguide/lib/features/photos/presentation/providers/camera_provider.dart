import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutriguide/core/services/api_service.dart';
import 'package:nutriguide/core/services/logging_service.dart';
import 'package:nutriguide/core/services/secure_storage.dart';
import 'package:nutriguide/features/photos/data/datasources/photo_remote_source.dart';
import 'package:nutriguide/features/photos/data/repositories/photo_repository_impl.dart';
import 'package:nutriguide/features/photos/domain/entities/photo.dart';
import 'package:nutriguide/features/photos/domain/repositories/photo_repository.dart';

// --- Dependency Injection ---

final photoRemoteSourceProvider = Provider<PhotoRemoteDataSource>((ref) {
  return PhotoRemoteDataSourceImpl(ApiService(
    secureStorage: SecureStorageService(),
    logger: LoggingService.instance,
  ));
});

final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  final remoteSource = ref.watch(photoRemoteSourceProvider);
  return PhotoRepositoryImpl(remoteSource);
});

final cameraProvider =
    StateNotifierProvider<CameraNotifier, AsyncValue<Photo?>>((ref) {
  final repository = ref.watch(photoRepositoryProvider);
  return CameraNotifier(repository);
});

// --- Notifier Class ---

class CameraNotifier extends StateNotifier<AsyncValue<Photo?>> {
  final PhotoRepository _repository;

  CameraNotifier(this._repository) : super(const AsyncValue.data(null));

  /// Reset state to initial (ready to scan)
  void reset() {
    state = const AsyncValue.data(null);
  }

  /// Analyze a captured photo
  Future<void> analyzePhoto(Uint8List imageBytes) async {
    state = const AsyncValue.loading();

    // Create a filename (timestamp based)
    final filename = 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await _repository.analyzePhoto(
      imageBytes: imageBytes,
      filename: filename,
    );

    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (photo) => state = AsyncValue.data(photo),
    );
  }
}
