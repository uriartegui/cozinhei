import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repository/recipe_repository.dart';

class SavedRecipesNotifier extends StateNotifier<void> {
  final RecipeRepository _repository;

  SavedRecipesNotifier(this._repository) : super(null);

  Future<void> toggleFavorite(String id, bool isFavorite) async {
    await _repository.toggleFavorite(id, !isFavorite);
  }

  Future<void> deleteRecipe(String id) async {
    await _repository.deleteRecipe(id);
  }
}
