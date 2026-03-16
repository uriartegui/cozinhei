class RecipeDto {
  final String name;
  final String description;
  final List<String> ingredients;
  final List<String> steps;
  final String cookingTime;
  final String servings;
  final String photoSearchTerm;

  RecipeDto({
    required this.name,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.cookingTime,
    required this.servings,
    this.photoSearchTerm = '',
  });

  factory RecipeDto.fromJson(Map<String, dynamic> json) => RecipeDto(
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    ingredients: List<String>.from(json['ingredients'] ?? []),
    steps: List<String>.from(json['steps'] ?? []),
    cookingTime: json['cookingTime'] ?? '',
    servings: json['servings'] ?? '',
    photoSearchTerm: json['photoSearchTerm'] ?? '',
  );
}
