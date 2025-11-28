import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import 'package:nutriguide/core/utils/error_handler.dart';
import 'package:nutriguide/features/photos/domain/entities/photo.dart';

abstract class PhotoRepository {
  /// Uploads a photo byte array for analysis.
  /// Returns a [Photo] entity containing detected ingredients and suggestions.
  Future<Either<Failure, Photo>> analyzePhoto(
      {required Uint8List imageBytes, required String filename});

  /// Retrieves past photo scan history.
  Future<Either<Failure, List<Photo>>> getPhotoHistory();

  /// Deletes a specific photo scan record.
  Future<Either<Failure, void>> deletePhoto(String id);
}
