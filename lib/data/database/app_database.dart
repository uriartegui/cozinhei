import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('RecipeEntity')
class Recipes extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  TextColumn get ingredients => text()();
  TextColumn get steps => text()();
  TextColumn get cookingTime => text()();
  TextColumn get servings => text()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get source => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('UserRecipeEntity')
class UserRecipes extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get ingredients => text()(); // JSON
  TextColumn get steps => text()();       // JSON com durationMinutes
  TextColumn get coverEmoji => text().withDefault(const Constant('🍽'))();
  TextColumn get imageUrl => text().nullable()();
  BoolColumn get isPublic => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
  TextColumn get authorName => text().withDefault(const Constant(''))();
  TextColumn get category => text().nullable()();
  TextColumn get subcategory => text().nullable()();
  TextColumn get tags => text().withDefault(const Constant('[]'))(); // JSON

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Recipes, UserRecipes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'cozinhei_db'));

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(userRecipes);
      }
      if (from < 3) {
        await migrator.addColumn(userRecipes, userRecipes.authorName);
        await migrator.addColumn(userRecipes, userRecipes.category);
        await migrator.addColumn(userRecipes, userRecipes.tags);
      }
      if (from < 4) {
        await migrator.addColumn(userRecipes, userRecipes.subcategory);
      }
    },
  );

  // ── Recipes (geradas por IA) ──────────────────────────────────────────────

  Future<void> insertRecipe(RecipesCompanion recipe) =>
      into(recipes).insertOnConflictUpdate(recipe);

  Stream<List<RecipeEntity>> getAllRecipes() =>
      (select(recipes)..orderBy([(r) => OrderingTerm.desc(r.createdAt)])).watch();

  Stream<List<RecipeEntity>> getFavorites() =>
      (select(recipes)..where((r) => r.isFavorite.equals(true))).watch();

  Future<void> toggleFavorite(String id, bool isFavorite) =>
      (update(recipes)..where((r) => r.id.equals(id)))
          .write(RecipesCompanion(isFavorite: Value(isFavorite)));

  Future<void> deleteRecipe(String id) =>
      (delete(recipes)..where((r) => r.id.equals(id))).go();

  Future<RecipeEntity?> getById(String id) =>
      (select(recipes)..where((r) => r.id.equals(id))).getSingleOrNull();

  // ── UserRecipes (caderno) ─────────────────────────────────────────────────

  Future<void> upsertUserRecipe(UserRecipesCompanion recipe) =>
      into(userRecipes).insertOnConflictUpdate(recipe);

  Stream<List<UserRecipeEntity>> watchUserRecipes() =>
      (select(userRecipes)..orderBy([(r) => OrderingTerm.desc(r.createdAt)])).watch();

  Future<void> deleteUserRecipe(String id) =>
      (delete(userRecipes)..where((r) => r.id.equals(id))).go();

  Future<UserRecipeEntity?> getUserRecipeById(String id) =>
      (select(userRecipes)..where((r) => r.id.equals(id))).getSingleOrNull();
}
