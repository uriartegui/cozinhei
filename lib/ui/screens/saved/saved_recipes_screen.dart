import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/recipe_card.dart';

class SavedRecipesScreen extends ConsumerStatefulWidget {
  const SavedRecipesScreen({super.key});

  @override
  ConsumerState<SavedRecipesScreen> createState() => _SavedRecipesScreenState();
}

class _SavedRecipesScreenState extends ConsumerState<SavedRecipesScreen> {
  bool _showFavoritesOnly = false;

  @override
  Widget build(BuildContext context) {
    final savedAsync = ref.watch(savedRecipesProvider);
    final favoritesAsync = ref.watch(favoriteRecipesProvider);
    final actions = ref.read(savedRecipesActionsProvider.notifier);

    final asyncData = _showFavoritesOnly ? favoritesAsync : savedAsync;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              bottom: 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Minhas Receitas',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _FilterChip(
                      label: 'Todas',
                      selected: !_showFavoritesOnly,
                      onTap: () => setState(() => _showFavoritesOnly = false),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Favoritas',
                      selected: _showFavoritesOnly,
                      onTap: () => setState(() => _showFavoritesOnly = true),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: asyncData.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: brandOrange),
              ),
              error: (e, _) => Center(child: Text('Erro: $e')),
              data: (recipes) {
                if (recipes.isEmpty) {
                  return Center(
                    child: Text(
                      _showFavoritesOnly
                          ? 'Nenhuma favorita ainda.'
                          : 'Nenhuma receita salva ainda.',
                      style: const TextStyle(color: textMedium),
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: recipes.length,
                  itemBuilder: (_, i) {
                    final recipe = recipes[i];
                    return RecipeCard(
                      recipe: recipe,
                      onClick: () => context.push('/recipe', extra: recipe),
                      onToggleFavorite: () => actions.toggleFavorite(
                          recipe.id, recipe.isFavorite),
                      onDelete: () => actions.deleteRecipe(recipe.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? brandOrange : surfaceGray,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
