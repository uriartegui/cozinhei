class RecipeDto {
  final String name;
  final String description;
  final List<String> ingredients;
  final List<String> steps;
  final String cookingTime;
  final String servings;
  final String photoSearchTerm;
  final String? imageUrl;
  final String? sourceUrl;

  RecipeDto({
    required this.name,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.cookingTime,
    required this.servings,
    this.photoSearchTerm = '',
    this.imageUrl,
    this.sourceUrl,
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

  factory RecipeDto.fromSupabase(Map<String, dynamic> json) => RecipeDto(
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    ingredients: List<String>.from(json['ingredients'] ?? []),
    steps: List<String>.from(json['steps'] ?? []),
    cookingTime: json['cooking_time'] ?? '',
    servings: json['servings'] ?? '',
    imageUrl: json['image_url'],
    sourceUrl: json['source_url'],
  );
}
