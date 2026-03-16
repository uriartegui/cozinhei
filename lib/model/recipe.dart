class Recipe {
  final String id;
  final String name;
  final String description;
  final List<String> ingredients;
  final List<String> steps;
  final String cookingTime;
  final String servings;
  final bool isFavorite;
  final int createdAt;
  final String? imageUrl;
  final String? source;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.cookingTime,
    required this.servings,
    this.isFavorite = false,
    int? createdAt,
    this.imageUrl,
    this.source,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  Recipe copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? ingredients,
    List<String>? steps,
    String? cookingTime,
    String? servings,
    bool? isFavorite,
    int? createdAt,
    String? imageUrl,
    String? source,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      cookingTime: cookingTime ?? this.cookingTime,
      servings: servings ?? this.servings,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      source: source ?? this.source,
    );
  }
}
