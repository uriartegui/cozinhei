import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers.dart';
import '../../viewmodel/house_notifier.dart';
import '../screens/home/home_screen.dart';
import '../screens/fridge/fridge_screen.dart';
import '../screens/saved/saved_recipes_screen.dart';
import '../screens/my_recipes/my_recipes_screen.dart';
import '../screens/my_recipes/recipe_editor_screen.dart';
import '../screens/recipe/recipe_detail_screen.dart';
import '../screens/recipe/cooking_mode_screen.dart';
import '../screens/house/house_setup_screen.dart';
import '../screens/auth/login_screen.dart';
import '../../model/recipe.dart';
import '../../model/user_recipe.dart';
import '../../ui/theme/app_colors.dart';
import '../screens/my_recipes/user_recipe_detail_screen.dart';

// ── Router como provider (acessa Riverpod) ────────────────────────────────────

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/house-setup',
        builder: (_, __) => const HouseSetupScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, state) => LoginScreen(
          redirectTo: state.uri.queryParameters['redirect'],
        ),
      ),
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
});

// ── Notifier que escuta o houseProvider e aciona o redirect ───────────────────

class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  _RouterNotifier(this._ref) {
    _ref.listen(houseProvider, (_, __) => notifyListeners());
    _ref.listen(isUserActivatedProvider, (_, __) => notifyListeners());
    Supabase.instance.client.auth.onAuthStateChange.listen((_) => notifyListeners());
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final houseState = _ref.read(houseProvider);
    final location = state.matchedLocation;
    final isSetupRoute = location == '/house-setup';
    final isFridgeRoute = location == '/fridge';
    final isMyRecipesRoute = location == '/my-recipes';
    final isLoginRoute = location == '/login';

    final user = _ref.read(authProvider);
    final isLoggedIn = user != null;

    // Rotas protegidas → redireciona para login se não autenticado
    if ((isFridgeRoute || isMyRecipesRoute) && !isLoggedIn) {
      final from = Uri.encodeComponent(location);
      return '/login?redirect=$from';
    }

    // Se já está logado e tenta ir para login → vai para home
    if (isLoginRoute && isLoggedIn) {
      return '/';
    }

    if (houseState.status == HouseStatus.loading) return null;

    // Só redireciona para setup se tentar acessar a geladeira sem casa
    if (isFridgeRoute && isLoggedIn && houseState.status == HouseStatus.noHouse) {
      return '/house-setup';
    }

    // Se já tem casa e está no setup, volta para geladeira
    if (isSetupRoute && houseState.status == HouseStatus.hasHouse) {
      return '/fridge';
    }

    return null;
  }
}

// ── Nav item model ────────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color activeColor;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.activeColor,
  });
}

const _navItems = [
  _NavItem(
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    label: 'Início',
    activeColor: brandOrange,
  ),
  _NavItem(
    icon: Icons.menu_book_outlined,
    activeIcon: Icons.menu_book_rounded,
    label: 'Receitas',
    activeColor: brandOrange,
  ),
  _NavItem(
    icon: Icons.kitchen_outlined,
    activeIcon: Icons.kitchen_rounded,
    label: 'Geladeira',
    activeColor: brandTertiary,
  ),
  _NavItem(
    icon: Icons.bookmark_outline,
    activeIcon: Icons.bookmark_rounded,
    label: 'Salvas',
    activeColor: brandOrange,
  ),
];

// ── Custom nav bar ────────────────────────────────────────────────────────────

class _AppNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const _AppNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8E8ED), width: 0.5)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom, top: 6),
        child: SizedBox(
          height: 52,
          child: Row(
            children: List.generate(_navItems.length, (i) {
              final item = _navItems[i];
              final active = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        active ? item.activeIcon : item.icon,
                        size: 24,
                        color: active ? item.activeColor : textMedium,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: active
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: active ? item.activeColor : textMedium,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Main scaffold ─────────────────────────────────────────────────────────────

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
      bottomNavigationBar: _AppNavBar(
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
      ),
    );
  }
}
