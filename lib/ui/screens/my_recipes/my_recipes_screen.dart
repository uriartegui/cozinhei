import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../model/user_recipe.dart';
import '../../../providers.dart';
import '../../theme/app_colors.dart';

class MyRecipesScreen extends ConsumerWidget {
  const MyRecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userRecipesProvider);

    return Scaffold(
      backgroundColor: brandOrangeLight,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              bottom: 8,
            ),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Minhas Receitas 📓',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: brandOrange)),
                      Text('Seu caderno digital',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: textMedium)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          state.when(
            loading: () => const SliverFillRemaining(
              child: Center(
                  child: CircularProgressIndicator(color: brandOrange)),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Erro: $e')),
            ),
            data: (recipes) {
              if (recipes.isEmpty) {
                return SliverFillRemaining(
                  child: _EmptyState(
                    onAdd: () => context.push('/recipe-editor'),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _RecipeListItem(
                      recipe: recipes[i],
                      onTap: () =>
                          context.push('/user-recipe', extra: recipes[i]),
                      onDelete: () => ref
                          .read(userRecipesProvider.notifier)
                          .delete(recipes[i].id),
                    ),
                    childCount: recipes.length,
                  ),
                ),
              );
            },
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/recipe-editor'),
        backgroundColor: brandOrange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nova receita',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _RecipeListItem extends StatelessWidget {
  final UserRecipe recipe;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _RecipeListItem({
    required this.recipe,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: brandOrangeLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(recipe.coverEmoji,
                        style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(recipe.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.list_alt,
                              size: 13, color: textMedium),
                          const SizedBox(width: 4),
                          Text('${recipe.steps.length} passos',
                              style: const TextStyle(
                                  color: textMedium, fontSize: 12)),
                          const SizedBox(width: 12),
                          const Icon(Icons.kitchen_outlined,
                              size: 13, color: textMedium),
                          const SizedBox(width: 4),
                          Text('${recipe.ingredients.length} ingredientes',
                              style: const TextStyle(
                                  color: textMedium, fontSize: 12)),
                        ],
                      ),
                      if (recipe.isPublic) ...[
                        const SizedBox(height: 4),
                        const Row(
                          children: [
                            Icon(Icons.public, size: 12, color: brandOrange),
                            SizedBox(width: 3),
                            Text('Pública',
                                style: TextStyle(
                                    color: brandOrange,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: textMedium, size: 20),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Excluir receita?'),
                      content: Text(
                          'Tem certeza que quer excluir "${recipe.name}"?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar')),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              onDelete();
                            },
                            child: const Text('Excluir',
                                style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: brandOrangeLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text('📓', style: TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Caderno vazio',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          const Text(
            'Salve aqui suas receitas favoritas, de família ou crie novas do zero.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textMedium, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                gradient: brandGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text('Criar primeira receita',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
