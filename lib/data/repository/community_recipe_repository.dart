import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../model/recipe.dart';
import '../../model/recipe_filter.dart';
import '../../model/user_recipe.dart';
import '../api/groq_service.dart';

class CommunityRecipeRepository {
  final SupabaseClient _supabase;
  final GroqService _groq;

  CommunityRecipeRepository(this._supabase, this._groq);

  /// Busca receitas por palavras-chave; filtro de categoria server-side via RPC.
  /// Se não há ingredientes mas há categoria, busca todas da categoria.
  Future<List<Recipe>> searchByQuery(String query, {String? category}) async {
    final words = query
        .toLowerCase()
        .split(RegExp(r'[,\s]+'))
        .where((w) => w.length > 2)
        .take(3)
        .toList();

    // Sem ingredientes e sem categoria → nada a buscar
    if (words.isEmpty && category == null) return [];

    // Sem ingredientes mas com categoria → busca todos da categoria
    if (words.isEmpty) {
      final data = await _supabase.rpc('search_community_recipes',
          params: {'keyword': '', 'category_filter': category});
      return (data as List)
          .take(6)
          .map((row) => _fromRow(row as Map<String, dynamic>))
          .toList();
    }

    final seen = <String>{};
    final results = <Map<String, dynamic>>[];

    for (final word in words) {
      final params = <String, dynamic>{'keyword': word};
      if (category != null) params['category_filter'] = category;

      final data = await _supabase.rpc('search_community_recipes', params: params);

      for (final row in data as List) {
        final id = row['id'] as String;
        if (seen.add(id)) results.add(row as Map<String, dynamic>);
      }
    }

    return results.take(6).map((e) => _fromRow(e)).toList();
  }

  /// Valida com Groq, categoriza automaticamente por IA e publica no Supabase
  Future<({bool ok, String? reason})> publish({
    required UserRecipe recipe,
    required String deviceId,
  }) async {
    // Validação + categorização em uma única chamada Groq
    final validCategories = _categories.join(', ');
    final prompt = '''
Você é um moderador e categorizador de receitas culinárias.

Receita: ${recipe.name}
Ingredientes: ${recipe.ingredients.join(', ')}

Tarefas:
1. Aprove a receita a menos que contenha conteúdo ofensivo, spam ou ingredientes impossíveis.
2. Se aprovada, determine em quais categorias ela se enquadra (máximo 3).

Categorias válidas: $validCategories

Responda APENAS com JSON:
{"aprovado": true, "categories": ["Frango", "Massas"]}
ou
{"aprovado": false, "motivo": "motivo curto"}
''';

    List<String> aiCategories = recipe.category != null ? [recipe.category!] : [];

    try {
      final raw = await _groq.generateRaw(prompt);
      final json = jsonDecode(raw.replaceAll('```json', '').replaceAll('```', '').trim());

      if (json['aprovado'] != true) {
        return (ok: false, reason: json['motivo'] as String?);
      }

      // Valida que as categorias retornadas existem na lista
      final returned = (json['categories'] as List? ?? []).cast<String>();
      aiCategories = returned.where((c) => _categories.contains(c)).toList();
      if (aiCategories.isEmpty && recipe.category != null) {
        aiCategories = [recipe.category!];
      }
    } catch (_) {
      // Se falhar, usa a categoria escolhida pelo usuário
    }

    await _supabase.from('community_recipes').insert({
      'name': recipe.name,
      'description': recipe.description,
      'ingredients': recipe.ingredients,
      'steps': recipe.steps.map((s) => {
        'description': s.description,
        'duration_minutes': s.durationMinutes,
      }).toList(),
      'cover_emoji': recipe.coverEmoji,
      'author_name': recipe.authorName,
      'device_id': deviceId,
      'category': recipe.category,
      'subcategory': recipe.subcategory,
      'categories': aiCategories,
      'tags': recipe.tags,
      'status': 'approved',
    });

    return (ok: true, reason: null);
  }

  Recipe _fromRow(Map<String, dynamic> row) {
    final ingredients = (row['ingredients'] as List).cast<String>();
    final steps = (row['steps'] as List)
        .map((s) => s is Map ? (s['description'] as String? ?? s.toString()) : s.toString())
        .toList();
    final categories = (row['categories'] as List? ?? []).cast<String>();

    return Recipe(
      id: row['id'] as String,
      name: row['name'] as String,
      description: row['description'] as String? ?? '',
      ingredients: ingredients,
      steps: steps,
      cookingTime: row['cooking_time'] as String? ?? '-',
      servings: row['servings'] as String? ?? '-',
      imageUrl: null,
      createdAt: DateTime.parse(row['created_at'] as String).millisecondsSinceEpoch,
      authorName: row['author_name'] as String? ?? '',
      categories: categories,
    );
  }
}

// Lista canônica de categorias (espelha allCategories em recipe_filter.dart)
final _categories = allCategories.map((c) => c.name).toList();
