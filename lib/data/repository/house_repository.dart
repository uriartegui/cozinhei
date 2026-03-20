import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class HouseRepository {
  final SupabaseClient _client;
  static const _houseIdKey = 'current_house_id';
  static const _displayNameKey = 'display_name';

  HouseRepository(this._client);

  SupabaseClient get client => _client;

  // ── Auth anônimo ─────────────────────────────────────────────────────────────

  Future<String> signInAnonymously() async {
    final session = _client.auth.currentSession;
    if (session != null) return session.user.id;

    final response = await _client.auth.signInAnonymously();
    return response.user!.id;
  }

  String? get currentUserId => _client.auth.currentUser?.id;

  bool get isCurrentUserAnonymous {
    final user = _client.auth.currentUser;
    if (user == null) return true;
    return user.isAnonymous;
  }

  // ── Casa ─────────────────────────────────────────────────────────────────────

  Future<String> createHouse(String name, String displayName) async {
    final userId = currentUserId!;
    final code = _generateCode();

    final house = await _client.from('houses').insert({
      'name': name,
      'invite_code': code,
    }).select().single();

    final houseId = house['id'] as String;

    await _client.from('house_members').insert({
      'house_id': houseId,
      'user_id': userId,
      'display_name': displayName.trim(),
    });

    await _saveHouseId(houseId);
    await _saveDisplayName(displayName.trim());
    return houseId;
  }

  Future<String> joinHouse(String inviteCode, String displayName) async {
    final userId = currentUserId!;

    final result = await _client
        .from('houses')
        .select()
        .eq('invite_code', inviteCode.toUpperCase())
        .maybeSingle();

    if (result == null) throw Exception('Código inválido');

    final houseId = result['id'] as String;

    await _client.from('house_members').upsert({
      'house_id': houseId,
      'user_id': userId,
      'display_name': displayName.trim(),
    });

    await _saveHouseId(houseId);
    await _saveDisplayName(displayName.trim());
    return houseId;
  }

  Future<String?> getSavedDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_displayNameKey);
  }

  Future<void> _saveDisplayName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_displayNameKey, name);
  }

  Future<String?> getSavedHouseId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_houseIdKey);
  }

  /// Busca a casa do usuário atual direto no Supabase (via house_members).
  Future<String?> getHouseIdFromSupabase() async {
    final userId = currentUserId;
    if (userId == null) return null;
    try {
      final result = await _client
          .from('house_members')
          .select('house_id')
          .eq('user_id', userId)
          .maybeSingle();
      return result?['house_id'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveHouseId(String houseId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_houseIdKey, houseId);
  }

  Future<Map<String, dynamic>?> getHouseInfo(String houseId) async {
    return await _client
        .from('houses')
        .select()
        .eq('id', houseId)
        .maybeSingle();
  }

  Future<void> renameHouse(String houseId, String newName) async {
    await _client.from('houses').update({'name': newName}).eq('id', houseId);
  }

  Future<void> deleteHouse(String houseId) async {
    await _client.from('houses').delete().eq('id', houseId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_houseIdKey);
    await prefs.remove('fridge_items_v2');
    await prefs.remove('shopping_items_v1');
    await prefs.remove('quick_add_items_v1');
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}
