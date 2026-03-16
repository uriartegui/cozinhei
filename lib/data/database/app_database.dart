import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'dart:convert';

part 'app_database.g.dart';

@DataClassName('RecipeEntity')
class Recipes extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  TextColumn get ingredients => text()(); // JSON string
  TextColumn get steps => text()(); // JSON string
  TextColumn get cookingTime => text()();
  TextColumn get servings => text()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get source => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Recipes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'cozinhei_db'));

  @override
  int get schemaVersion => 1;

  Future<void> insertRecipe(RecipesCompanion recipe) =>
      into(recipes).insertOnConflictUpdate(recipe);

  Stream<List<RecipeEntity>> getAllRecipes() =>
      (select(recipes)
        ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]))
          .watch();

  Stream<List<RecipeEntity>> getFavorites() =>
      (select(recipes)..where((r) => r.isFavorite.equals(true))).watch();

  Future<void> toggleFavorite(String id, bool isFavorite) =>
      (update(recipes)..where((r) => r.id.equals(id)))
          .write(RecipesCompanion(isFavorite: Value(isFavorite)));

  Future<void> deleteRecipe(String id) =>
      (delete(recipes)..where((r) => r.id.equals(id))).go();

  Future<RecipeEntity?> getById(String id) =>
      (select(recipes)..where((r) => r.id.equals(id))).getSingleOrNull();
}
