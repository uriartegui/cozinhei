import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/repository/recipe_repository.dart';
import 'data/repository/fridge_repository.dart';
import 'model/recipe.dart';
import 'viewmodel/home_notifier.dart';
import 'viewmodel/home_state.dart';
import 'viewmodel/fridge_notifier.dart';
import 'viewmodel/saved_recipes_notifier.dart';
import 'di/injection.dart';

// Repositories
final recipeRepositoryProvider = Provider<RecipeRepository>(
      (ref) => getIt<RecipeRepository>(),
);

final fridgeRepositoryProvider = Provider<FridgeRepository>(
      (ref) => getIt<FridgeRepository>(),
);

// ViewModels
final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(
    ref.read(recipeRepositoryProvider),
    ref.read(fridgeRepositoryProvider),
  );
});

final fridgeProvider = StateNotifierProvider<FridgeNotifier, List<String>>((ref) {
  return FridgeNotifier(ref.read(fridgeRepositoryProvider));
});

final savedRecipesActionsProvider =
StateNotifierProvider<SavedRecipesNotifier, void>((ref) {
  return SavedRecipesNotifier(ref.read(recipeRepositoryProvider));
});

// Database streams
final savedRecipesProvider = StreamProvider<List<Recipe>>((ref) {
  return ref.read(recipeRepositoryProvider).getSavedRecipes();
});

final favoriteRecipesProvider = StreamProvider<List<Recipe>>((ref) {
  return ref.read(recipeRepositoryProvider).getFavoriteRecipes();
});
