import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/fridge_item.dart';
import '../../model/shopping_item.dart';

class FridgeRepository {
  static const String _fridgeKey     = 'fridge_items_v2';
  static const String _shoppingKey   = 'shopping_items_v1';
  static const String _quickItemsKey = 'quick_add_items_v1';
  final SharedPreferences _prefs;

  FridgeRepository(this._prefs);

  // ── Fridge ──────────────────────────────────────────────────────────────────

  List<FridgeItem> loadFridge() {
    final json = _prefs.getString(_fridgeKey);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List;
      return list.map((e) => FridgeItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveFridge(List<FridgeItem> items) async {
    await _prefs.setString(_fridgeKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  // ── Shopping List ────────────────────────────────────────────────────────────

  List<ShoppingItem> loadShopping() {
    final json = _prefs.getString(_shoppingKey);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List;
      return list.map((e) => ShoppingItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveShopping(List<ShoppingItem> items) async {
    await _prefs.setString(_shoppingKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  // ── Quick Add ────────────────────────────────────────────────────────────────

  Map<String, int> loadQuickItemUsage() {
    final json = _prefs.getString(_quickItemsKey);
    if (json == null) return {};
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, v as int));
    } catch (_) {
      return {};
    }
  }

  Future<void> incrementQuickItemUsage(String name) async {
    final usage = loadQuickItemUsage();
    usage[name] = (usage[name] ?? 0) + 1;
    await _prefs.setString(_quickItemsKey, jsonEncode(usage));
  }

  List<String> getTopQuickItems({int limit = 8}) {
    final usage = loadQuickItemUsage();
    final sorted = usage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).map((e) => e.key).toList();
  }
}
