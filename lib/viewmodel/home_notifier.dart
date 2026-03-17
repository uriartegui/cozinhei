import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repository/recipe_repository.dart';
import '../data/repository/fridge_repository.dart';
import '../model/recipe.dart';
import 'home_state.dart';

class HomeNotifier extends StateNotifier<HomeState> {
  final RecipeRepository _repository;
  final FridgeRepository _fridgeRepository;
  final List<String> _shownRecipeNames = [];

  HomeNotifier(this._repository, this._fridgeRepository)
      : super(HomeState());

  void onQueryChange(String value) {
    state = state.copyWith(query: value);
  }

  void addChip(String item) {
    if (item.isNotEmpty && !state.chips.contains(item)) {
      state = state.copyWith(chips: [...state.chips, item]);
    }
  }

  void removeChip(String item) {
    state = state.copyWith(
      chips: state.chips.where((c) => c != item).toList(),
    );
  }

  void setCategory(String? category) {
    state = state.copyWith(
      selectedCategory: category,
      clearCategory: category == null,
      clearSubcategory: true,
      selectedTags: {},
    );
  }

  void setSubcategory(String? subcategory) {
    state = state.copyWith(
      selectedSubcategory: subcategory,
      clearSubcategory: subcategory == null,
      selectedTags: {},
    );
  }

  void toggleTag(String tag) {
    final tags = Set<String>.from(state.selectedTags);
    if (tags.contains(tag)) {
      tags.remove(tag);
    } else {
      tags.add(tag);
    }
    state = state.copyWith(selectedTags: tags);
  }

  Future<void> generateRecipes({int servings = 4}) async {
    final q = state.query.trim();
    if (q.isEmpty) return;

    state = state.copyWith(uiState: HomeLoading());
    try {
      final recipes = await _repository.generateRecipes(
        ingredients: q,
        servings: servings,
        excludeNames: List.from(_shownRecipeNames),
      );
      _shownRecipeNames.addAll(recipes.map((r) => r.name));
      state = state.copyWith(uiState: HomeSuccess(recipes));
    } catch (e) {
      state = state.copyWith(
        uiState: HomeError(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  Future<void> loadFridgeSuggestions() async {
    final ingredients = _fridgeRepository.load();
    if (ingredients.length < 2) {
      state = state.copyWith(fridgeSuggestions: FridgeSuggestionsEmpty());
      return;
    }
    state = state.copyWith(fridgeSuggestions: FridgeSuggestionsLoading());
    try {
      final recipes = await _repository.generateFridgeSuggestions(
        (ingredients..shuffle()).take(6).toList(),
      );
      state = state.copyWith(fridgeSuggestions: FridgeSuggestionsSuccess(recipes));
    } catch (_) {
      state = state.copyWith(fridgeSuggestions: FridgeSuggestionsEmpty());
    }
  }

  void setIngredients(List<String> list) {
    state = state.copyWith(query: list.join(', '));
  }

  void clearAll() {
    _shownRecipeNames.clear();
    state = HomeState();
  }

  Future<void> saveRecipe(Recipe recipe) async {
    await _repository.saveRecipe(recipe);
  }

  static String getCategory(String name) {
    final lower = name.toLowerCase();
    if (_containsAny(lower, ['macarrão', 'pasta', 'espaguete', 'lasanha', 'nhoque', 'penne'])) return 'Massas';
    if (_containsAny(lower, ['salada', 'bowl'])) return 'Saladas';
    if (_containsAny(lower, ['bolo', 'torta', 'pudim', 'mousse', 'sorvete', 'brigadeiro', 'brownie'])) return 'Sobremesas';
    if (_containsAny(lower, ['peixe', 'salmão', 'atum', 'tilápia', 'bacalhau', 'camarão'])) return 'Peixes';
    if (_containsAny(lower, ['frango', 'galinha', 'chester'])) return 'Frango';
    if (_containsAny(lower, ['taco', 'burrito', 'guacamole', 'nachos'])) return 'Mexicana';
    return 'Outras';
  }

  static bool _containsAny(String text, List<String> keywords) =>
      keywords.any((k) => text.contains(k));
}
