import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repository/fridge_repository.dart';

class FridgeNotifier extends StateNotifier<List<String>> {
  final FridgeRepository _repository;

  FridgeNotifier(this._repository) : super(_repository.load());

  void addIngredient(String item) {
    if (item.isNotEmpty && !state.contains(item)) {
      state = [...state, item];
      _repository.setIngredients(state);
    }
  }

  void removeIngredient(int index) {
    final updated = [...state]..removeAt(index);
    state = updated;
    _repository.setIngredients(state);
  }

  void setIngredients(List<String> ingredients) {
    state = ingredients;
    _repository.setIngredients(state);
  }
}
