import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/repository/fridge_repository.dart';
import '../model/fridge_item.dart';
import '../model/shopping_item.dart';
import 'fridge_state.dart';

class FridgeNotifier extends StateNotifier<FridgeState> {
  final FridgeRepository _repository;
  final _uuid = const Uuid();

  FridgeNotifier(this._repository) : super(FridgeState(
    items: _repository.loadFridge(),
    shoppingList: _repository.loadShopping(),
    quickItems: _repository.getTopQuickItems(),
  ));

  // ── Fridge ──────────────────────────────────────────────────────────────────

  void addItem(
    String name,
    FridgeCategory category, {
    DateTime? expiresAt,
    double? quantity,
    FridgeUnit? unit,
  }) {
    final item = FridgeItem(
      id: _uuid.v4(),
      name: name.trim(),
      category: category,
      addedAt: DateTime.now(),
      expiresAt: expiresAt,
      quantity: quantity,
      unit: unit,
    );
    state = state.copyWith(items: [...state.items, item]);
    _repository.saveFridge(state.items);
    _repository.incrementQuickItemUsage(name.trim()).then((_) {
      state = state.copyWith(quickItems: _repository.getTopQuickItems());
    });
  }

  void removeItem(String id) {
    state = state.copyWith(items: state.items.where((e) => e.id != id).toList());
    _repository.saveFridge(state.items);
  }

  void updateItem(FridgeItem updated) {
    state = state.copyWith(
      items: state.items.map((e) => e.id == updated.id ? updated : e).toList(),
    );
    _repository.saveFridge(state.items);
  }

  // ── Shopping List ────────────────────────────────────────────────────────────

  void addShoppingItem(String name, FridgeCategory category) {
    final item = ShoppingItem(
      id: _uuid.v4(),
      name: name.trim(),
      category: category,
      addedAt: DateTime.now(),
    );
    state = state.copyWith(shoppingList: [...state.shoppingList, item]);
    _repository.saveShopping(state.shoppingList);
  }

  void toggleShoppingItem(String id) {
    final updated = state.shoppingList
        .map((e) => e.id == id ? e.copyWith(isChecked: !e.isChecked) : e)
        .toList();
    state = state.copyWith(shoppingList: updated);
    _repository.saveShopping(state.shoppingList);
  }

  void removeShoppingItem(String id) {
    state = state.copyWith(
      shoppingList: state.shoppingList.where((e) => e.id != id).toList(),
    );
    _repository.saveShopping(state.shoppingList);
  }

  void moveCheckedToFridge() {
    final checked = state.shoppingList.where((e) => e.isChecked).toList();
    final remaining = state.shoppingList.where((e) => !e.isChecked).toList();

    final newFridgeItems = checked.map((s) => FridgeItem(
      id: _uuid.v4(),
      name: s.name,
      category: s.category,
      addedAt: DateTime.now(),
    )).toList();

    state = state.copyWith(
      items: [...state.items, ...newFridgeItems],
      shoppingList: remaining,
    );
    _repository.saveFridge(state.items);
    _repository.saveShopping(state.shoppingList);

    for (final item in checked) {
      _repository.incrementQuickItemUsage(item.name);
    }
  }

  List<String> get ingredientNames => state.items.map((e) => e.name).toList();
}
