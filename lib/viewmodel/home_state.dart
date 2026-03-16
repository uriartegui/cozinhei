import '../model/recipe.dart';

abstract class HomeUiState {}
class HomeIdle extends HomeUiState {}
class HomeLoading extends HomeUiState {}
class HomeSuccess extends HomeUiState {
  final List<Recipe> recipes;
  HomeSuccess(this.recipes);
}
class HomeError extends HomeUiState {
  final String message;
  HomeError(this.message);
}

abstract class FridgeSuggestionsState {}
class FridgeSuggestionsIdle extends FridgeSuggestionsState {}
class FridgeSuggestionsLoading extends FridgeSuggestionsState {}
class FridgeSuggestionsSuccess extends FridgeSuggestionsState {
  final List<Recipe> recipes;
  FridgeSuggestionsSuccess(this.recipes);
}
class FridgeSuggestionsEmpty extends FridgeSuggestionsState {}

class HomeState {
  final HomeUiState uiState;
  final FridgeSuggestionsState fridgeSuggestions;
  final String query;
  final List<String> chips;

  HomeState({
    HomeUiState? uiState,
    FridgeSuggestionsState? fridgeSuggestions,
    this.query = '',
    this.chips = const [],
  })  : uiState = uiState ?? HomeIdle(),
        fridgeSuggestions = fridgeSuggestions ?? FridgeSuggestionsIdle();

  HomeState copyWith({
    HomeUiState? uiState,
    FridgeSuggestionsState? fridgeSuggestions,
    String? query,
    List<String>? chips,
  }) {
    return HomeState(
      uiState: uiState ?? this.uiState,
      fridgeSuggestions: fridgeSuggestions ?? this.fridgeSuggestions,
      query: query ?? this.query,
      chips: chips ?? this.chips,
    );
  }
}
