import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../data/api/groq_service.dart';
import '../data/api/meal_db_service.dart';
import '../data/api/unsplash_service.dart';
import '../data/database/app_database.dart';
import '../data/repository/fridge_repository.dart';
import '../data/repository/recipe_repository.dart';
import '../core/constants.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Shared Preferences
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // Database
  getIt.registerSingleton<AppDatabase>(AppDatabase());

  // Dio
  final dio = Dio();
  getIt.registerSingleton<Dio>(dio);

  // Services
  getIt.registerSingleton<GroqService>(
    GroqService(dio, AppConstants.groqApiKey),
  );
  getIt.registerSingleton<MealDbService>(MealDbService(dio));
  getIt.registerSingleton<UnsplashService>(
    UnsplashService(dio, AppConstants.unsplashApiKey),
  );

  // Repositories
  getIt.registerSingleton<FridgeRepository>(
    FridgeRepository(prefs),
  );
  getIt.registerSingleton<RecipeRepository>(
    RecipeRepository(
      getIt<GroqService>(),
      getIt<MealDbService>(),
      getIt<UnsplashService>(),
      getIt<AppDatabase>(),
    ),
  );
}
