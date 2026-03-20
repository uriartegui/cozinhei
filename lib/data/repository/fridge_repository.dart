import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../model/fridge_item.dart';
import '../../model/shopping_item.dart';

class FridgeRepository {
  final SupabaseClient _client;
  final SharedPreferences _prefs;

  static const String _quickItemsKey = 'quick_add_items_v1';

  FridgeRepository(this._client, this._prefs);

  String get _userId => _client.auth.currentUser?.id ?? '';

  // ── Fridge (Supabase realtime) ───────────────────────────────────────────────

  Stream<List<FridgeItem>> watchFridge(String houseId) {
    return _client
        .from('fridge_items')
        .stream(primaryKey: ['id'])
        .eq('house_id', houseId)
        .order('added_at')
        .map((data) => data.map((e) => FridgeItem.fromSupabase(e)).toList());
  }

  Future<void> saveFridgeItem(String houseId, FridgeItem item) async {
    try {
      await _client
          .from('fridge_items')
          .upsert(item.toSupabase(houseId, _userId));
    } catch (e) {
      debugPrint('❌ saveFridgeItem error: $e');
      rethrow;
    }
  }

  Future<void> deleteFridgeItem(String itemId) async {
    await _client.from('fridge_items').delete().eq('id', itemId);
  }

  Future<void> updateFridgeItem(String houseId, FridgeItem item) async {
    await _client
        .from('fridge_items')
        .update(item.toSupabase(houseId, _userId))
        .eq('id', item.id);
  }

  // ── Shopping (Supabase realtime) ─────────────────────────────────────────────

  Stream<List<ShoppingItem>> watchShopping(String houseId) {
    return _client
        .from('shopping_items')
        .stream(primaryKey: ['id'])
        .eq('house_id', houseId)
        .order('added_at')
        .map((data) => data.map((e) => ShoppingItem.fromSupabase(e)).toList());
  }

  Future<void> saveShoppingItem(String houseId, ShoppingItem item) async {
    await _client
        .from('shopping_items')
        .upsert(item.toSupabase(houseId, _userId));
  }

  Future<void> updateShoppingItem(String houseId, ShoppingItem item) async {
    await _client
        .from('shopping_items')
        .update(item.toSupabase(houseId, _userId))
        .eq('id', item.id);
  }

  Future<void> deleteShoppingItem(String itemId) async {
    await _client.from('shopping_items').delete().eq('id', itemId);
  }

  // ── Quick Add (mantém local) ──────────────────────────────────────────────────

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
