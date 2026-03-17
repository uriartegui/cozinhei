import 'dart:convert';
import 'package:uuid/uuid.dart';
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
  final _uuid = const Uuid();

  RecipeRepository(
      this._groqService,
      this._unsplashService,
      this._db,
      );

  // ── Fridge Suggestions ────────────────────────────────────────────────────

  Future<List<Recipe>> generateFridgeSuggestions(List<String> ingredients) async {
    return await _generateFridgeSuggestionsWithAI(ingredients);
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

  Future<List<Recipe>> _generateFridgeSuggestionsWithAI(List<String> ingredients) async {
    final ingredientList = ingredients.join(', ');
    final prompt = '''
Tenho estes ingredientes disponíveis: $ingredientList
Crie 3 receitas usando APENAS ingredientes que fazem sentido juntos.
Regras obrigatórias:
- NUNCA misture proteínas diferentes na mesma receita
- Cada receita usa apenas 2 a 4 dos ingredientes disponíveis
- Pode complementar com temperos básicos (sal, alho, azeite, cebola, manteiga)
- As 3 receitas devem ser diferentes entre si
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
    await _db.insertRecipe(RecipesCompanion(
      id: Value(recipe.id),
      name: Value(recipe.name),
      description: Value(recipe.description),
      ingredients: Value(jsonEncode(recipe.ingredients)),
      steps: Value(jsonEncode(recipe.steps)),
      cookingTime: Value(recipe.cookingTime),
      servings: Value(recipe.servings),
      isFavorite: Value(recipe.isFavorite),
      createdAt: Value(recipe.createdAt),
      imageUrl: Value(recipe.imageUrl),
      source: Value(recipe.source),
    ));
  }

  Stream<List<Recipe>> getSavedRecipes() =>
      _db.getAllRecipes().map((list) => list.map(_entityToDomain).toList());

  Stream<List<Recipe>> getFavoriteRecipes() =>
      _db.getFavorites().map((list) => list.map(_entityToDomain).toList());

  Future<void> toggleFavorite(String id, bool isFavorite) =>
      _db.toggleFavorite(id, isFavorite);

  Future<void> deleteRecipe(String id) => _db.deleteRecipe(id);

  Future<Recipe?> getById(String id) async {
    final entity = await _db.getById(id);
    return entity != null ? _entityToDomain(entity) : null;
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
