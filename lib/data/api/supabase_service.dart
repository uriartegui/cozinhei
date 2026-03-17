import 'package:supabase_flutter/supabase_flutter.dart';
import 'model/recipe_dto.dart';

class SupabaseRecipeService {
  final SupabaseClient _client;

  SupabaseRecipeService(this._client);

  Future<List<RecipeDto>> searchByIngredients(List<String> ingredients) async {
    if (ingredients.isEmpty) return [];

    try {
      final response = await _client
          .from('recipes')
          .select()
          .limit(300);

      final all = response as List;
      final terms = ingredients.map((i) => i.toLowerCase()).toList();

      final filtered = all.where((r) {
        final name = (r['name'] as String? ?? '').toLowerCase();
        final category = (r['category'] as String? ?? '').toLowerCase();
        return terms.every((t) => name.contains(t) || category.contains(t));
      }).take(10).toList();

      return filtered
          .map((e) => RecipeDto.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
