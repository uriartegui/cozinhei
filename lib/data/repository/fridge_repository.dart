import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FridgeRepository {
  static const String _key = 'fridge_ingredients';
  final SharedPreferences _prefs;

  FridgeRepository(this._prefs);

  List<String> load() {
    final json = _prefs.getString(_key);
    if (json == null) return [];
    try {
      return List<String>.from(jsonDecode(json));
    } catch (_) {
      return [];
    }
  }

  Future<void> setIngredients(List<String> ingredients) async {
    await _prefs.setString(_key, jsonEncode(ingredients));
  }
}
