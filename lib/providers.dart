import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/repository/recipe_repository.dart';
import 'data/repository/fridge_repository.dart';
import 'data/repository/community_recipe_repository.dart';
import 'model/recipe.dart';
import 'viewmodel/home_notifier.dart';
import 'viewmodel/home_state.dart';
import 'viewmodel/fridge_notifier.dart';
import 'viewmodel/fridge_state.dart';
import 'viewmodel/saved_recipes_notifier.dart';
import 'di/injection.dart';
import 'data/repository/user_recipe_repository.dart';
import 'model/user_recipe.dart';
import 'viewmodel/user_recipes_notifier.dart';

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
    ref.read(communityRecipeRepositoryProvider),
  );
});

final fridgeProvider = StateNotifierProvider<FridgeNotifier, FridgeState>((ref) {
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

// ── Community Recipes ────────────────────────────────────────────────────────
final communityRecipeRepositoryProvider = Provider<CommunityRecipeRepository>(
      (ref) => getIt<CommunityRecipeRepository>(),
);

// ── User Recipes (Caderno) ──────────────────────────────────────────────────
final userRecipeRepositoryProvider = Provider<UserRecipeRepository>(
      (ref) => getIt<UserRecipeRepository>(),
);

final userRecipesProvider =
StateNotifierProvider<UserRecipesNotifier, AsyncValue<List<UserRecipe>>>(
      (ref) => UserRecipesNotifier(ref.read(userRecipeRepositoryProvider)),
);
