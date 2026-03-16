import 'package:dio/dio.dart';
import 'model/meal_db_models.dart';

class MealDbService {
  final Dio _dio;

  MealDbService(this._dio);

  Future<MealDbFilterResponse> filterByIngredient(String ingredient) async {
    final response = await _dio.get(
      'https://www.themealdb.com/api/json/v1/1/filter.php',
      queryParameters: {'i': ingredient},
    );
    return MealDbFilterResponse.fromJson(response.data);
  }

  Future<MealDbDetailResponse> lookupById(String id) async {
    final response = await _dio.get(
      'https://www.themealdb.com/api/json/v1/1/lookup.php',
      queryParameters: {'i': id},
    );
    return MealDbDetailResponse.fromJson(response.data);
  }
}
