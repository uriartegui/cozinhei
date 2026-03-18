import 'dart:convert';

class UserRecipeStep {
  final String description;
  final int? durationMinutes;

  const UserRecipeStep({required this.description, this.durationMinutes});

  UserRecipeStep copyWith({String? description, int? durationMinutes, bool clearDuration = false}) {
    return UserRecipeStep(
      description: description ?? this.description,
      durationMinutes: clearDuration ? null : (durationMinutes ?? this.durationMinutes),
    );
  }

  Map<String, dynamic> toJson() => {
    'description': description,
    'durationMinutes': durationMinutes,
  };

  factory UserRecipeStep.fromJson(Map<String, dynamic> json) => UserRecipeStep(
    description: json['description'] as String,
    durationMinutes: json['durationMinutes'] as int?,
  );
}

class UserRecipe {
  final String id;
  final String name;
  final String? description;
  final List<String> ingredients;
  final List<UserRecipeStep> steps;
  final String? imageUrl;
  final String coverEmoji;
  final bool isPublic;
  final int createdAt;

  UserRecipe({
    required this.id,
    required this.name,
    this.description,
    required this.ingredients,
    required this.steps,
    this.imageUrl,
    this.coverEmoji = '🍽',
    this.isPublic = false,
    int? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  UserRecipe copyWith({
    String? id, String? name, String? description,
    List<String>? ingredients, List<UserRecipeStep>? steps,
    String? imageUrl, String? coverEmoji, bool? isPublic, int? createdAt,
  }) => UserRecipe(
    id: id ?? this.id, name: name ?? this.name,
    description: description ?? this.description,
    ingredients: ingredients ?? this.ingredients,
    steps: steps ?? this.steps, imageUrl: imageUrl ?? this.imageUrl,
    coverEmoji: coverEmoji ?? this.coverEmoji,
    isPublic: isPublic ?? this.isPublic, createdAt: createdAt ?? this.createdAt,
  );

  String stepsJson() => jsonEncode(steps.map((s) => s.toJson()).toList());
  String ingredientsJson() => jsonEncode(ingredients);
}
