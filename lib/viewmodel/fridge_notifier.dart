import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/repository/fridge_repository.dart';
import '../data/repository/log_repository.dart';
import '../model/fridge_item.dart';
import '../model/shopping_item.dart';
import 'fridge_state.dart';

class FridgeNotifier extends StateNotifier<FridgeState> {
  final FridgeRepository _repository;
  final LogRepository _log;
  final String _houseId;
  final String _displayName;
  final _uuid = const Uuid();

  StreamSubscription? _fridgeSub;
  StreamSubscription? _shoppingSub;

  FridgeNotifier(this._repository, this._log, this._houseId, this._displayName)
      : super(FridgeState(
          items: [],
          shoppingList: [],
          quickItems: _repository.getTopQuickItems(),
        )) {
    _subscribe();
  }

  void _subscribe() {
    if (_houseId.isEmpty) return;
    _fridgeSub = _repository.watchFridge(_houseId).listen((items) {
      if (mounted) state = state.copyWith(items: items);
    });
    _shoppingSub = _repository.watchShopping(_houseId).listen((items) {
      if (mounted) state = state.copyWith(shoppingList: items);
    });
  }

  @override
  void dispose() {
    _fridgeSub?.cancel();
    _shoppingSub?.cancel();
    super.dispose();
  }

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
    // Atualização otimista — aparece imediatamente na UI
    state = state.copyWith(items: [...state.items, item]);
    _repository.saveFridgeItem(_houseId, item);
    _log.log(_houseId, 'add_fridge', itemName: item.name, displayName: _displayName);
    _repository.incrementQuickItemUsage(name.trim()).then((_) {
      if (mounted) state = state.copyWith(quickItems: _repository.getTopQuickItems());
    });
  }

  void removeItem(String id) {
    final item = state.items.firstWhere((e) => e.id == id);
    state = state.copyWith(items: state.items.where((e) => e.id != id).toList());
    _repository.deleteFridgeItem(id);
    _log.log(_houseId, 'remove_fridge', itemName: item.name, displayName: _displayName);
  }

  void updateItem(FridgeItem updated) {
    state = state.copyWith(
      items: state.items.map((e) => e.id == updated.id ? updated : e).toList(),
    );
    _repository.updateFridgeItem(_houseId, updated);
    _log.log(_houseId, 'update_fridge', itemName: updated.name, displayName: _displayName);
  }

  // ── Shopping List ────────────────────────────────────────────────────────────

  void addShoppingItem(String name, FridgeCategory category, {String? store}) {
    final item = ShoppingItem(
      id: _uuid.v4(),
      name: name.trim(),
      category: category,
      addedAt: DateTime.now(),
      store: store?.trim().isEmpty == true ? null : store?.trim(),
    );
    state = state.copyWith(shoppingList: [...state.shoppingList, item]);
    _repository.saveShoppingItem(_houseId, item);
    _log.log(_houseId, 'add_shopping', itemName: item.name, displayName: _displayName);
  }

  void toggleShoppingItem(String id) {
    final item = state.shoppingList.firstWhere((e) => e.id == id);
    final updated = item.copyWith(isChecked: !item.isChecked);
    state = state.copyWith(
      shoppingList: state.shoppingList.map((e) => e.id == id ? updated : e).toList(),
    );
    _repository.updateShoppingItem(_houseId, updated);
    final action = updated.isChecked ? 'check_shopping' : 'uncheck_shopping';
    _log.log(_houseId, action, itemName: item.name, displayName: _displayName);
  }

  void removeShoppingItem(String id) {
    final item = state.shoppingList.firstWhere((e) => e.id == id);
    state = state.copyWith(
      shoppingList: state.shoppingList.where((e) => e.id != id).toList(),
    );
    _repository.deleteShoppingItem(id);
    _log.log(_houseId, 'remove_shopping', itemName: item.name, displayName: _displayName);
  }

  void moveShoppingItemToFridge(
    String shoppingId,
    String name,
    FridgeCategory category, {
    DateTime? expiresAt,
    double? quantity,
    FridgeUnit? unit,
  }) {
    final fridgeItem = FridgeItem(
      id: _uuid.v4(),
      name: name.trim(),
      category: category,
      addedAt: DateTime.now(),
      expiresAt: expiresAt,
      quantity: quantity,
      unit: unit,
    );
    state = state.copyWith(
      items: [...state.items, fridgeItem],
      shoppingList: state.shoppingList.where((e) => e.id != shoppingId).toList(),
    );
    _repository.saveFridgeItem(_houseId, fridgeItem);
    _repository.deleteShoppingItem(shoppingId);
    _repository.incrementQuickItemUsage(name.trim());
    _log.log(_houseId, 'move_to_fridge', itemName: name.trim(), displayName: _displayName);
  }

  void moveCheckedToFridge() {
    final checked = state.shoppingList.where((e) => e.isChecked).toList();
    for (final s in checked) {
      final fridgeItem = FridgeItem(
        id: _uuid.v4(),
        name: s.name,
        category: s.category,
        addedAt: DateTime.now(),
      );
      _repository.saveFridgeItem(_houseId, fridgeItem);
      _repository.deleteShoppingItem(s.id);
      _repository.incrementQuickItemUsage(s.name);
    }
    if (checked.isNotEmpty) {
      _log.log(_houseId, 'move_to_fridge', displayName: _displayName);
    }
  }

  List<String> get ingredientNames => state.items.map((e) => e.name).toList();
}
