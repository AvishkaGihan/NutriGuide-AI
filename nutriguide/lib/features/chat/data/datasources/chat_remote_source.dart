import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nutriguide/core/constants/endpoints.dart';
import 'package:nutriguide/core/services/api_service.dart';
import 'package:nutriguide/core/services/secure_storage.dart';
import 'package:nutriguide/features/chat/data/models/chat_message_model.dart';
import 'package:nutriguide/features/recipes/data/models/recipe_model.dart';

abstract class ChatRemoteDataSource {
  /// Stream the AI response. Returns a Stream of partial strings (tokens)
  /// and finally the complete ChatMessageModel or RecipeModel.
  Stream<dynamic> streamMessage(String message, {String? conversationId});

  /// Get past chat history
  Future<List<ChatMessageModel>> getChatHistory();
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiService _apiService;
  final SecureStorageService _secureStorage;

  ChatRemoteDataSourceImpl(this._apiService, this._secureStorage);

  @override
  Stream<dynamic> streamMessage(String message,
      {String? conversationId}) async* {
    final uri = Uri.parse('${Endpoints.baseUrl}${Endpoints.chatStream}');
    final token = await _secureStorage.getAccessToken();

    final client = http.Client();
    final request = http.Request('POST', uri);

    request.headers['Content-Type'] = 'application/json';
    request.headers['Accept'] = 'text/event-stream';
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.body = jsonEncode({
      'message': message,
      'conversationId': conversationId,
    });

    try {
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw ApiException(
            statusCode: response.statusCode,
            message: 'Failed to connect to chat stream');
      }

      // Process the SSE Stream
      // We parse line by line: "event: ...", "data: ..."
      await for (final line in response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        if (line.startsWith('event: token')) {
          // It's a token line, wait for the next data line
          continue;
        } else if (line.startsWith('data: ')) {
          final dataString = line.substring(6); // Remove "data: "
          if (dataString.isEmpty) continue;

          try {
            final data = jsonDecode(dataString);

            // Check content type based on previous event or inferred structure
            if (data['text'] != null) {
              yield data['text'] as String; // Yield the token string
            } else if (data['recipe'] != null) {
              // Yield the full recipe at the end if present
              yield RecipeModel.fromJson(data['recipe']);
            } else if (data['conversationId'] != null) {
              // Yield metadata if needed, or just ignore
            }
            // Ignore parse errors for keep-alive or malformed lines
          } catch (e) {
            // Ignore parse errors for keep-alive or malformed lines
          }
        }
      }
    } catch (e) {
      rethrow;
    } finally {
      client.close();
    }
  }

  @override
  Future<List<ChatMessageModel>> getChatHistory() async {
    final response = await _apiService.get(Endpoints.chatHistory);
    final list = response['data'] as List<dynamic>;

    return list.map((e) => ChatMessageModel.fromJson(e)).toList();
  }
}
