import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/api/groq_service.dart';
import '../data/api/unsplash_service.dart';
import '../data/database/app_database.dart';
import '../data/repository/fridge_repository.dart';
import '../data/repository/recipe_repository.dart';
import '../data/repository/user_recipe_repository.dart';
import '../data/repository/community_recipe_repository.dart';
import '../core/constants.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  getIt.registerSingleton<AppDatabase>(AppDatabase());

  final dio = Dio();
  getIt.registerSingleton<Dio>(dio);

  getIt.registerSingleton<SupabaseClient>(Supabase.instance.client);

  getIt.registerSingleton<GroqService>(
    GroqService(dio, AppConstants.groqApiKey),
  );
  getIt.registerSingleton<UnsplashService>(
    UnsplashService(dio, AppConstants.unsplashApiKey),
  );

  getIt.registerSingleton<FridgeRepository>(
    FridgeRepository(prefs),
  );
  getIt.registerSingleton<RecipeRepository>(
    RecipeRepository(
      getIt<GroqService>(),
      getIt<UnsplashService>(),
      getIt<AppDatabase>(),
    ),
  );
  getIt.registerSingleton<UserRecipeRepository>(
    UserRecipeRepository(getIt<AppDatabase>()),
  );
  getIt.registerSingleton<CommunityRecipeRepository>(
    CommunityRecipeRepository(getIt<SupabaseClient>(), getIt<GroqService>()),
  );
}
