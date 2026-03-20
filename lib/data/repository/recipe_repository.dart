import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../api/groq_service.dart';
import '../api/unsplash_service.dart';
import '../api/model/chat_request.dart';
import '../api/model/recipe_dto.dart';
import '../database/app_database.dart';
import '../../model/recipe.dart';
import 'package:drift/drift.dart';

class RecipeRepository {
  final GroqService _groqService;
  final UnsplashService _unsplashService;
  final AppDatabase _db;
  final SupabaseClient _supabase;
  final _uuid = const Uuid();

  RecipeRepository(
      this._groqService,
      this._unsplashService,
      this._db,
      this._supabase,
      );

  String? get _userId => _supabase.auth.currentUser?.id;

  // ── Fridge Suggestions ────────────────────────────────────────────────────

  Future<List<Recipe>> generateFridgeSuggestions(
    List<String> ingredients, {
    List<String> excludeNames = const [],
  }) async {
    return await _generateFridgeSuggestionsWithAI(ingredients, excludeNames: excludeNames);
  }

  // ── Main Recipe Generation ────────────────────────────────────────────────

  Future<List<Recipe>> generateRecipes({
    required String ingredients,
    int count = 4,
    int servings = 4,
    List<String> excludeNames = const [],
  }) async {
    try {
      return await _generateRecipesWithAI(
        ingredients: ingredients,
        count: count,
        servings: servings,
        excludeNames: excludeNames,
      );
    } catch (_) {
      return [];
    }
  }

  // ── AI ────────────────────────────────────────────────────────────────────

  Future<List<Recipe>> _generateRecipesWithAI({
    required String ingredients,
    int count = 4,
    int servings = 4,
    List<String> excludeNames = const [],
  }) async {
    final excludeText = excludeNames.isNotEmpty
        ? '\n- NÃO repita estas receitas já mostradas: ${excludeNames.join(', ')}'
        : '';

    final prompt = '''
Crie $count receitas diferentes e variadas usando: $ingredients
Responda APENAS com um JSON array válido:
[
  {
    "name": "Nome da receita",
    "description": "Descrição curta e apetitosa",
    "ingredients": ["200g de arroz", "2 dentes de alho picados"],
    "steps": ["Passo 1: ...", "Passo 2: ..."],
    "cookingTime": "30 minutos",
    "servings": "$servings pessoas",
    "photoSearchTerm": "nome do prato finalizado em inglês"
  }
]
Regras:
- Exatamente $count receitas DIFERENTES entre si$excludeText
- Cada receita deve ser para $servings pessoas
- Cada ingrediente com quantidade exata
- Mínimo de 6 passos por receita, cada passo detalhado e profissional
- photoSearchTerm sempre em inglês
''';

    final response = await _groqService.sendMessage(
      ChatRequest(messages: [Message(role: 'user', content: prompt)]),
    );
    final content = response.choices.first.message.content;
    final json = _cleanJson(content);
    final dtos = (jsonDecode(json) as List)
        .map((e) => RecipeDto.fromJson(e))
        .toList();

    return await Future.wait(dtos.map((dto) async {
      final recipe = _dtoToDomain(dto);
      final imageUrl = await _fetchImage(
        dto.photoSearchTerm.isNotEmpty ? dto.photoSearchTerm : recipe.name,
      );
      return recipe.copyWith(imageUrl: imageUrl, source: 'IA');
    }));
  }

  Future<List<Recipe>> _generateFridgeSuggestionsWithAI(
    List<String> ingredients, {
    List<String> excludeNames = const [],
  }) async {
    final ingredientList = ingredients.join(', ');
    final excludeClause = excludeNames.isNotEmpty
        ? '\n- NÃO sugira nenhuma dessas receitas que já foram mostradas: ${excludeNames.join(', ')}'
        : '';
    final ingredientRule = ingredients.length == 1
        ? '- Use o ingrediente disponível como base principal da receita'
        : '- Cada receita usa apenas 2 a 4 dos ingredientes disponíveis';
    final prompt = '''
Tenho estes ingredientes disponíveis: $ingredientList
Crie 3 receitas usando os ingredientes disponíveis.
Regras obrigatórias:
- NUNCA misture proteínas diferentes na mesma receita
$ingredientRule
- Pode complementar com temperos básicos (sal, alho, azeite, cebola, manteiga)
- As 3 receitas devem ser diferentes entre si$excludeClause
Responda APENAS com um JSON array válido:
[
  {
    "name": "Nome da receita",
    "description": "Descrição curta e apetitosa",
    "ingredients": ["200g de arroz", "2 dentes de alho picados"],
    "steps": ["Passo 1: ...", "Passo 2: ..."],
    "cookingTime": "30 minutos",
    "servings": "2 porções",
    "photoSearchTerm": "nome do prato em inglês"
  }
]
''';

    final response = await _groqService.sendMessage(
      ChatRequest(messages: [Message(role: 'user', content: prompt)]),
    );
    final content = response.choices.first.message.content;
    final json = _cleanJson(content);
    final dtos = (jsonDecode(json) as List)
        .map((e) => RecipeDto.fromJson(e))
        .toList();

    return await Future.wait(dtos.map((dto) async {
      final recipe = _dtoToDomain(dto);
      final imageUrl = await _fetchImage(
        dto.photoSearchTerm.isNotEmpty ? dto.photoSearchTerm : recipe.name,
      );
      return recipe.copyWith(imageUrl: imageUrl, source: 'IA');
    }));
  }

  // ── Database ──────────────────────────────────────────────────────────────

  Future<void> saveRecipe(Recipe recipe) async {
    final uid = _userId;
    if (uid == null) return;
    await _supabase.from('saved_recipes').upsert({
      'id': recipe.id,
      'user_id': uid,
      'name': recipe.name,
      'description': recipe.description,
      'ingredients': recipe.ingredients,
      'steps': recipe.steps,
      'cooking_time': recipe.cookingTime,
      'servings': recipe.servings,
      'is_favorite': recipe.isFavorite,
      'created_at': recipe.createdAt,
      'image_url': recipe.imageUrl,
      'source': recipe.source,
    });
  }

  Stream<List<Recipe>> getSavedRecipes() {
    final uid = _userId;
    if (uid == null) return Stream.value([]);
    return _supabase
        .from('saved_recipes')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .map((data) => data.map(_rowToDomain).toList());
  }

  Stream<List<Recipe>> getFavoriteRecipes() {
    final uid = _userId;
    if (uid == null) return Stream.value([]);
    return _supabase
        .from('saved_recipes')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .map((data) => data
            .where((r) => r['is_favorite'] == true)
            .map(_rowToDomain)
            .toList());
  }

  Future<void> toggleFavorite(String id, bool isFavorite) async {
    await _supabase
        .from('saved_recipes')
        .update({'is_favorite': !isFavorite})
        .eq('id', id);
  }

  Future<void> deleteRecipe(String id) async {
    await _supabase.from('saved_recipes').delete().eq('id', id);
  }

  Future<Recipe?> getById(String id) async {
    final row = await _supabase
        .from('saved_recipes')
        .select()
        .eq('id', id)
        .maybeSingle();
    return row != null ? _rowToDomain(row) : null;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<String?> _fetchImage(String query) async {
    try {
      final result = await _unsplashService.searchPhoto(
        '$query food photography plated',
      );
      return result.results.firstOrNull?.urls.regular;
    } catch (_) {
      return null;
    }
  }

  String _cleanJson(String content) =>
      content.replaceAll('```json', '').replaceAll('```', '').trim();

  Recipe _dtoToDomain(RecipeDto dto) => Recipe(
    id: _uuid.v4(),
    name: dto.name,
    description: dto.description,
    ingredients: dto.ingredients,
    steps: dto.steps,
    cookingTime: dto.cookingTime,
    servings: dto.servings,
    imageUrl: dto.imageUrl,
    source: null,
  );

  Recipe _rowToDomain(Map<String, dynamic> row) => Recipe(
    id: row['id'] as String,
    name: row['name'] as String,
    description: row['description'] as String? ?? '',
    ingredients: List<String>.from(row['ingredients'] as List),
    steps: List<String>.from(row['steps'] as List),
    cookingTime: row['cooking_time'] as String? ?? '',
    servings: row['servings'] as String? ?? '',
    isFavorite: row['is_favorite'] as bool? ?? false,
    createdAt: row['created_at'] as int? ?? 0,
    imageUrl: row['image_url'] as String?,
    source: row['source'] as String?,
  );

  Recipe _entityToDomain(RecipeEntity entity) => Recipe(
    id: entity.id,
    name: entity.name,
    description: entity.description,
    ingredients: List<String>.from(jsonDecode(entity.ingredients)),
    steps: List<String>.from(jsonDecode(entity.steps)),
    cookingTime: entity.cookingTime,
    servings: entity.servings,
    isFavorite: entity.isFavorite,
    createdAt: entity.createdAt,
    imageUrl: entity.imageUrl,
    source: entity.source,
  );
}
