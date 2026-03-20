import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repository/recipe_repository.dart';
import '../data/repository/community_recipe_repository.dart';
import '../model/recipe.dart';
import 'home_state.dart';

class HomeNotifier extends StateNotifier<HomeState> {
  final RecipeRepository _repository;
  final List<String> Function() _getFridgeIngredients;
  final CommunityRecipeRepository _communityRepository;
  final List<String> _shownRecipeNames = [];
  final List<String> _shownFridgeNames = [];
  String _loadedFridgeKey = '';

  HomeNotifier(this._repository, this._getFridgeIngredients, this._communityRepository)
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
      // 1. Busca na comunidade — usa só os chips de ingredientes como keyword;
      //    o filtro de categoria é passado separadamente para a RPC.
      final ingredientQuery = state.chips.join(', ');
      final allCommunity = await _communityRepository.searchByQuery(
        ingredientQuery,
        category: state.selectedCategory,
      );
      final communityRecipes = allCommunity
          .where((r) => !_shownRecipeNames.contains(r.name))
          .toList();

      // 2. Completa com IA se tiver menos de 4 receitas
      final needed = 4 - communityRecipes.length;
      final excludeNames = [
        ...List<String>.from(_shownRecipeNames),
        ...communityRecipes.map((r) => r.name),
      ];

      final aiRecipes = needed > 0
          ? await _repository.generateRecipes(
              ingredients: q,
              count: needed,
              servings: servings,
              excludeNames: excludeNames,
            )
          : <Recipe>[];

      final combined = [...communityRecipes, ...aiRecipes];
      _shownRecipeNames.addAll(combined.map((r) => r.name));
      state = state.copyWith(uiState: HomeSuccess(combined));
    } catch (e) {
      state = state.copyWith(
        uiState: HomeError(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  /// Chamado ao navegar para home: só recarrega se a geladeira mudou ou ainda não carregou.
  Future<void> syncFridgeSuggestions() async {
    if (state.fridgeSuggestions is FridgeSuggestionsLoading) return;
    final ingredients = _getFridgeIngredients();
    final key = (List<String>.from(ingredients)..sort()).join(',');
    if (key == _loadedFridgeKey && state.fridgeSuggestions is FridgeSuggestionsSuccess) return;
    if (key != _loadedFridgeKey) _shownFridgeNames.clear();
    await loadFridgeSuggestions();
  }

  Future<void> loadFridgeSuggestions() async {
    final ingredients = _getFridgeIngredients();
    if (ingredients.isEmpty) {
      state = state.copyWith(fridgeSuggestions: FridgeSuggestionsEmpty());
      return;
    }
    state = state.copyWith(fridgeSuggestions: FridgeSuggestionsLoading());
    try {
      final sample = (List<String>.from(ingredients)..shuffle()).take(6).toList();

      // Busca comunidade primeiro, excluindo receitas já mostradas
      final ingredientQuery = sample.take(3).join(', ');
      final allCommunity = await _communityRepository.searchByQuery(ingredientQuery);
      final communityResults = allCommunity
          .where((r) => !_shownFridgeNames.contains(r.name))
          .take(3)
          .toList();

      // Completa com IA até 3 no total
      final needed = 3 - communityResults.length;
      final excludeNames = [
        ...List<String>.from(_shownFridgeNames),
        ...communityResults.map((r) => r.name),
      ];
      final aiRecipes = needed > 0
          ? (await _repository.generateFridgeSuggestions(sample, excludeNames: excludeNames))
              .take(needed)
              .toList()
          : <Recipe>[];

      final combined = [...communityResults, ...aiRecipes];
      _shownFridgeNames.addAll(combined.map((r) => r.name));
      _loadedFridgeKey = (List<String>.from(ingredients)..sort()).join(',');
      state = state.copyWith(
        fridgeSuggestions: FridgeSuggestionsSuccess(combined),
      );
    } catch (e) {
      // ignore: avoid_print
      print('[HomeNotifier] loadFridgeSuggestions error: $e');
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
