import 'package:dio/dio.dart';
import 'model/chat_request.dart';
import 'model/chat_response.dart';

class GroqService {
  final Dio _dio;
  final String _apiKey;

  GroqService(this._dio, this._apiKey);

  Future<ChatResponse> sendMessage(ChatRequest request) async {
    final response = await _dio.post(
      'https://api.groq.com/openai/v1/chat/completions',
      data: request.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $_apiKey'}),
    );
    return ChatResponse.fromJson(response.data);
  }

  Future<String> generateRaw(String prompt) async {
    final response = await _dio.post(
      'https://api.groq.com/openai/v1/chat/completions',
      data: {
        'model': 'llama-3.3-70b-versatile',
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.1,
      },
      options: Options(headers: {'Authorization': 'Bearer $_apiKey'}),
    );
    return response.data['choices'][0]['message']['content'] as String;
  }
}
