import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import 'package:nutriguide/core/utils/error_handler.dart';
import 'package:nutriguide/features/photos/data/datasources/photo_remote_source.dart';
import 'package:nutriguide/features/photos/domain/entities/photo.dart';
import 'package:nutriguide/features/photos/domain/repositories/photo_repository.dart';

class PhotoRepositoryImpl implements PhotoRepository {
  final PhotoRemoteDataSource _remoteDataSource;

  PhotoRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, Photo>> analyzePhoto(
      {required Uint8List imageBytes, required String filename}) async {
    try {
      final photoModel =
          await _remoteDataSource.analyzePhoto(imageBytes, filename);
      return Right(photoModel);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Photo>>> getPhotoHistory() async {
    try {
      final history = await _remoteDataSource.getPhotoHistory();
      return Right(history);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePhoto(String id) async {
    try {
      await _remoteDataSource.deletePhoto(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
