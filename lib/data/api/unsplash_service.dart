import 'package:dio/dio.dart';
import 'model/unsplash_response.dart';

class UnsplashService {
  final Dio _dio;
  final String _apiKey;

  UnsplashService(this._dio, this._apiKey);

  Future<UnsplashResponse> searchPhoto(String query, {int perPage = 5}) async {
    final response = await _dio.get(
      'https://api.unsplash.com/search/photos',
      queryParameters: {
        'query': query,
        'per_page': perPage,
        'orientation': 'landscape',
      },
      options: Options(headers: {'Authorization': 'Client-ID $_apiKey'}),
    );
    return UnsplashResponse.fromJson(response.data);
  }
}
