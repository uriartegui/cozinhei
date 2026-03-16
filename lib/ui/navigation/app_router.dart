import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home/home_screen.dart';
import '../screens/fridge/fridge_screen.dart';
import '../screens/saved/saved_recipes_screen.dart';
import '../screens/recipe/recipe_detail_screen.dart';
import '../screens/recipe/cooking_mode_screen.dart';
import '../../model/recipe.dart';
import '../../ui/theme/app_colors.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => _MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/fridge',
          builder: (context, state) => const FridgeScreen(),
        ),
        GoRoute(
          path: '/saved',
          builder: (context, state) => const SavedRecipesScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/recipe',
      builder: (context, state) {
        final recipe = state.extra as Recipe;
        return RecipeDetailScreen(recipe: recipe);
      },
    ),
    GoRoute(
      path: '/cooking',
      builder: (context, state) {
        final recipe = state.extra as Recipe;
        return CookingModeScreen(recipe: recipe);
      },
    ),
  ],
);

class _MainScaffold extends StatelessWidget {
  final Widget child;
  const _MainScaffold({required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/fridge')) return 1;
    if (location.startsWith('/saved')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
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
            if (i == 0) context.go('/');
            if (i == 1) context.go('/fridge');
            if (i == 2) context.go('/saved');
          },
          selectedItemColor: brandOrange,
          unselectedItemColor: textMedium,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Início',
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
