import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

// Generate mocks using: flutter pub run build_runner build
// For this setup, we assume standard Mockito usage or manual stubbing if needed.
class MockHttpClient extends Mock implements http.Client {}

class MockResponseGenerator {
  static http.Response success(Map<String, dynamic> data,
      {int statusCode = 200}) {
    return http.Response(
      jsonEncode({'success': true, 'data': data}),
      statusCode,
      headers: {'content-type': 'application/json'},
    );
  }

  static http.Response error(String message, {int statusCode = 400}) {
    return http.Response(
      jsonEncode({
        'success': false,
        'error': {'message': message}
      }),
      statusCode,
      headers: {'content-type': 'application/json'},
    );
  }

  static http.Response authResponse() {
    return success({
      'user': {
        'id': 'user-123',
        'email': 'test@example.com',
        'profile': {'dietary_goals': []}
      },
      'tokens': {
        'accessToken': 'fake-access-token',
        'refreshToken': 'fake-refresh-token'
      }
    });
  }
}
