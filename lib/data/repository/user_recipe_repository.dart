import 'dart:convert';
import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../../model/user_recipe.dart';

class UserRecipeRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  UserRecipeRepository(this._db);

  Stream<List<UserRecipe>> watchAll() {
    return _db.watchUserRecipes().map(
          (list) => list.map(_fromEntity).toList(),
    );
  }

  Future<void> save(UserRecipe recipe) async {
    await _db.upsertUserRecipe(UserRecipesCompanion.insert(
      id: recipe.id,
      name: recipe.name,
      description: Value(recipe.description),
      ingredients: jsonEncode(recipe.ingredients),
      steps: recipe.stepsJson(),
      coverEmoji: Value(recipe.coverEmoji),
      imageUrl: Value(recipe.imageUrl),
      isPublic: Value(recipe.isPublic),
      createdAt: recipe.createdAt,
      authorName: Value(recipe.authorName),
      category: Value(recipe.category),
      subcategory: Value(recipe.subcategory),
      tags: Value(jsonEncode(recipe.tags)),
    ));
  }

  Future<void> delete(String id) => _db.deleteUserRecipe(id);

  String generateId() => _uuid.v4();

  UserRecipe _fromEntity(UserRecipeEntity e) {
    final ingredients = List<String>.from(jsonDecode(e.ingredients) as List);
    final steps = (jsonDecode(e.steps) as List)
        .map((s) => UserRecipeStep.fromJson(s as Map<String, dynamic>))
        .toList();
    final tags = e.tags != null
        ? List<String>.from(jsonDecode(e.tags!) as List)
        : <String>[];
    return UserRecipe(
      id: e.id,
      name: e.name,
      description: e.description,
      ingredients: ingredients,
      steps: steps,
      coverEmoji: e.coverEmoji,
      imageUrl: e.imageUrl,
      isPublic: e.isPublic,
      createdAt: e.createdAt,
      authorName: e.authorName,
      category: e.category,
      subcategory: e.subcategory,
      tags: tags,
    );
  }
}
