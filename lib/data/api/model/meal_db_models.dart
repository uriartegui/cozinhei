class MealDbFilterResponse {
  final List<MealSummary>? meals;
  MealDbFilterResponse({this.meals});
  factory MealDbFilterResponse.fromJson(Map<String, dynamic> json) =>
      MealDbFilterResponse(
        meals: (json['meals'] as List?)?.map((m) => MealSummary.fromJson(m)).toList(),
      );
}

class MealSummary {
  final String strMeal;
  final String strMealThumb;
  final String idMeal;
  MealSummary({required this.strMeal, required this.strMealThumb, required this.idMeal});
  factory MealSummary.fromJson(Map<String, dynamic> json) => MealSummary(
    strMeal: json['strMeal'],
    strMealThumb: json['strMealThumb'],
    idMeal: json['idMeal'],
  );
}

class MealDbDetailResponse {
  final List<MealDetail>? meals;
  MealDbDetailResponse({this.meals});
  factory MealDbDetailResponse.fromJson(Map<String, dynamic> json) =>
      MealDbDetailResponse(
        meals: (json['meals'] as List?)?.map((m) => MealDetail.fromJson(m)).toList(),
      );
}

class MealDetail {
  final String idMeal;
  final String strMeal;
  final String? strInstructions;
  final String? strMealThumb;
  final List<String?> ingredients;
  final List<String?> measures;

  MealDetail({
    required this.idMeal,
    required this.strMeal,
    this.strInstructions,
    this.strMealThumb,
    required this.ingredients,
    required this.measures,
  });

  factory MealDetail.fromJson(Map<String, dynamic> json) {
    final ingredients = List.generate(10, (i) => json['strIngredient${i + 1}'] as String?);
    final measures = List.generate(10, (i) => json['strMeasure${i + 1}'] as String?);
    return MealDetail(
      idMeal: json['idMeal'],
      strMeal: json['strMeal'],
      strInstructions: json['strInstructions'],
      strMealThumb: json['strMealThumb'],
      ingredients: ingredients,
      measures: measures,
    );
  }

  List<String> ingredientsList() {
    final result = <String>[];
    for (int i = 0; i < ingredients.length; i++) {
      final ingredient = ingredients[i];
      final measure = measures[i];
      if (ingredient != null && ingredient.trim().isNotEmpty) {
        result.add('${measure?.trim() ?? ''} ${ingredient.trim()}'.trim());
      }
    }
    return result;
  }
}
