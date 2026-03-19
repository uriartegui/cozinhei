import '../model/fridge_item.dart';
import '../model/shopping_item.dart';

class FridgeState {
  final List<FridgeItem> items;
  final List<ShoppingItem> shoppingList;
  final List<String> quickItems;

  const FridgeState({
    this.items = const [],
    this.shoppingList = const [],
    this.quickItems = const [],
  });

  FridgeState copyWith({
    List<FridgeItem>? items,
    List<ShoppingItem>? shoppingList,
    List<String>? quickItems,
  }) {
    return FridgeState(
      items: items ?? this.items,
      shoppingList: shoppingList ?? this.shoppingList,
      quickItems: quickItems ?? this.quickItems,
    );
  }

  Map<FridgeCategory, List<FridgeItem>> get itemsByCategory {
    final map = <FridgeCategory, List<FridgeItem>>{};
    for (final item in items) {
      map.putIfAbsent(item.category, () => []).add(item);
    }
    return map;
  }

  List<FridgeItem> get expiringItems =>
      items.where((e) => e.expiresAt != null && ((e.daysUntilExpiry ?? 999) <= 3)).toList();
}
