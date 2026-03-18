import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repository/user_recipe_repository.dart';
import '../model/user_recipe.dart';

class UserRecipesNotifier extends StateNotifier<AsyncValue<List<UserRecipe>>> {
  final UserRecipeRepository _repository;

  UserRecipesNotifier(this._repository) : super(const AsyncValue.loading()) {
    _repository.watchAll().listen(
          (list) => state = AsyncValue.data(list),
      onError: (e) => state = AsyncValue.error(e, StackTrace.current),
    );
  }

  Future<void> save(UserRecipe recipe) => _repository.save(recipe);

  Future<void> delete(String id) => _repository.delete(id);

  String generateId() => _repository.generateId();
}
