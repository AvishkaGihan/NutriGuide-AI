import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nutriguide/core/constants/endpoints.dart';
import 'package:nutriguide/core/services/logging_service.dart';
import 'package:nutriguide/core/services/secure_storage.dart';

class ApiService {
  final SecureStorageService _secureStorage;
  final LoggingService _logger;
  final http.Client _client;

  ApiService({
    required SecureStorageService secureStorage,
    required LoggingService logger,
    http.Client? client,
  })  : _secureStorage = secureStorage,
        _logger = logger,
        _client = client ?? http.Client();

  // Helper to build full URL
  Uri _buildUri(String path) {
    return Uri.parse('${Endpoints.baseUrl}$path');
  }

  // Helper to get headers
  Future<Map<String, String>> _getHeaders({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (auth) {
      final token = await _secureStorage.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // --- GET Request ---
  Future<dynamic> get(String path, {bool auth = true}) async {
    final uri = _buildUri(path);
    final headers = await _getHeaders(auth: auth);

    _logger.debug('GET $uri');

    try {
      final response = await _client.get(uri, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      _logger.error('GET failed for $path', e);
      rethrow;
    }
  }

  // --- POST Request ---
  Future<dynamic> post(String path, {dynamic body, bool auth = true}) async {
    final uri = _buildUri(path);
    final headers = await _getHeaders(auth: auth);

    _logger.debug('POST $uri');

    try {
      final response = await _client.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      _logger.error('POST failed for $path', e);
      rethrow;
    }
  }

  // --- PUT Request ---
  Future<dynamic> put(String path, {dynamic body, bool auth = true}) async {
    final uri = _buildUri(path);
    final headers = await _getHeaders(auth: auth);

    _logger.debug('PUT $uri');

    try {
      final response = await _client.put(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      _logger.error('PUT failed for $path', e);
      rethrow;
    }
  }

  // --- DELETE Request ---
  Future<dynamic> delete(String path, {bool auth = true}) async {
    final uri = _buildUri(path);
    final headers = await _getHeaders(auth: auth);

    _logger.debug('DELETE $uri');

    try {
      final response = await _client.delete(uri, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      _logger.error('DELETE failed for $path', e);
      rethrow;
    }
  }

  // --- Multipart Request (for Photos) ---
  Future<dynamic> uploadPhoto(
      String path, List<int> imageBytes, String filename) async {
    final uri = _buildUri(path);
    final token = await _secureStorage.getAccessToken();

    final request = http.MultipartRequest('POST', uri);
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: filename,
        contentType: http.MediaType('image', 'jpeg'),
      ),
    );

    _logger.debug('UPLOAD $uri');

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      _logger.error('UPLOAD failed for $path', e);
      rethrow;
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      // Parse error message from backend if available
      String errorMessage = 'Unknown error';
      try {
        final body = jsonDecode(response.body);
        errorMessage = body['error']?['message'] ??
            body['message'] ??
            response.reasonPhrase;
      } catch (_) {
        errorMessage = response.reasonPhrase ?? 'Server Error';
      }

      throw ApiException(
          statusCode: response.statusCode, message: errorMessage);
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
