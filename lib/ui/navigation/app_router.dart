import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers.dart';
import '../screens/home/home_screen.dart';
import '../screens/fridge/fridge_screen.dart';
import '../screens/saved/saved_recipes_screen.dart';
import '../screens/my_recipes/my_recipes_screen.dart';
import '../screens/my_recipes/recipe_editor_screen.dart';
import '../screens/recipe/recipe_detail_screen.dart';
import '../screens/recipe/cooking_mode_screen.dart';
import '../../model/recipe.dart';
import '../../model/user_recipe.dart';
import '../../ui/theme/app_colors.dart';
import '../screens/my_recipes/user_recipe_detail_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => _MainScaffold(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/my-recipes', builder: (_, __) => const MyRecipesScreen()),
        GoRoute(path: '/fridge', builder: (_, __) => const FridgeScreen()),
        GoRoute(path: '/saved', builder: (_, __) => const SavedRecipesScreen()),
      ],
    ),
    GoRoute(
      path: '/recipe',
      builder: (context, state) =>
          RecipeDetailScreen(recipe: state.extra as Recipe),
    ),
    GoRoute(
      path: '/cooking',
      builder: (context, state) =>
          CookingModeScreen(recipe: state.extra as Recipe),
    ),
    GoRoute(
      path: '/recipe-editor',
      builder: (context, state) =>
          RecipeEditorScreen(existing: state.extra as UserRecipe?),
    ),
    GoRoute(
      path: '/user-recipe',
      builder: (context, state) =>
          UserRecipeDetailScreen(recipe: state.extra as UserRecipe),
    ),
  ],
);

class _MainScaffold extends ConsumerWidget {
  final Widget child;
  const _MainScaffold({required this.child});

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    if (loc.startsWith('/my-recipes')) return 1;
    if (loc.startsWith('/fridge')) return 2;
    if (loc.startsWith('/saved')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = _currentIndex(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (i) {
            if (i == 0) {
              context.go('/');
              ref.read(homeProvider.notifier).syncFridgeSuggestions();
            }
            if (i == 1) context.go('/my-recipes');
            if (i == 2) context.go('/fridge');
            if (i == 3) context.go('/saved');
          },
          selectedItemColor: brandOrange,
          unselectedItemColor: textMedium,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'Receitas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.kitchen_outlined),
              activeIcon: Icon(Icons.kitchen),
              label: 'Geladeira',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_outline),
              activeIcon: Icon(Icons.bookmark),
              label: 'Salvas',
            ),
          ],
        ),
      ),
    );
  }
}
