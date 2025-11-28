import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nutriguide/core/services/secure_storage.dart';
import 'package:nutriguide/features/auth/data/datasources/auth_remote_source.dart';
import 'package:nutriguide/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:nutriguide/features/auth/data/models/user_model.dart';
import '../../../helpers/test_fixtures.dart';

// Generate mocks
@GenerateMocks([AuthRemoteDataSource, SecureStorageService])
import 'auth_repository_test.mocks.dart'; // Uncomment after running: flutter pub run build_runner build

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockSecureStorageService mockSecureStorage;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockSecureStorage = MockSecureStorageService();
    repository = AuthRepositoryImpl(mockRemoteDataSource, mockSecureStorage);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password';
  const tToken = 'access_token';

  group('login', () {
    // Model used in data layer
    final tUserModel = UserModel(
      id: TestFixtures.tUser.id,
      email: TestFixtures.tUser.email,
    );

    final tAuthResponse = AuthResponseModel(
      user: tUserModel,
      accessToken: tToken,
      refreshToken: 'refresh_token',
    );

    test('should return User and save tokens when call is successful',
        () async {
      // Arrange
      when(mockRemoteDataSource.login(any, any))
          .thenAnswer((_) async => tAuthResponse);
      when(mockSecureStorage.saveAccessToken(any)).thenAnswer((_) async {
        return;
      });
      when(mockSecureStorage.saveRefreshToken(any)).thenAnswer((_) async {
        return;
      });

      // Act
      final result = await repository.login(tEmail, tPassword);

      // Assert
      expect(result, isA<Right>());
      verify(mockSecureStorage.saveAccessToken(tToken));
      verify(mockRemoteDataSource.login(tEmail, tPassword));
    });

    test('should return Failure when remote call throws exception', () async {
      // Arrange
      when(mockRemoteDataSource.login(any, any))
          .thenThrow(Exception('Network Error'));

      // Act
      final result = await repository.login(tEmail, tPassword);

      // Assert
      expect(result, isA<Left>());
    });
  });
}
