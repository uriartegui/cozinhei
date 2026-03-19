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
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  left: 20,
                  right: 20,
                  bottom: 8,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Minhas Receitas',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 28,
                              letterSpacing: -0.8,
                              color: neutralDark,
                            ),
                      ),
                      const SizedBox(height: 4),
                      state.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (recipes) => Text(
                          recipes.isEmpty
                              ? 'Seu caderno está vazio'
                              : 'Você tem ${recipes.length} receita${recipes.length == 1 ? '' : 's'} salva${recipes.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: textMedium,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
              const SliverPadding(padding: EdgeInsets.only(bottom: 110)),
            ],
          ),

          // Bottom pill FAB
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: GestureDetector(
              onTap: () => context.push('/recipe-editor'),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  gradient: brandGradient,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: brandOrange.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Nova receita',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Cover
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F0ED),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(recipe.coverEmoji,
                        style: const TextStyle(fontSize: 28, height: 1.0)),
                  ),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              recipe.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: neutralDark,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (recipe.isPublic) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: brandSecondary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'PÚBLICA',
                                style: TextStyle(
                                  color: brandSecondary,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.format_list_bulleted,
                              size: 12, color: textMedium),
                          const SizedBox(width: 4),
                          Text('${recipe.steps.length} passos',
                              style: const TextStyle(
                                  color: textMedium,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400)),
                          const SizedBox(width: 14),
                          const Icon(Icons.restaurant_outlined,
                              size: 12, color: textMedium),
                          const SizedBox(width: 4),
                          Text('${recipe.ingredients.length} ingredientes',
                              style: const TextStyle(
                                  color: textMedium,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Delete
                GestureDetector(
                  onTap: () => showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Excluir receita?'),
                      content: Text(
                          'Tem certeza que quer excluir "${recipe.name}"?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('Cancelar')),
                        TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              onDelete();
                            },
                            child: const Text('Excluir',
                                style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.delete_outline,
                        color: Color(0xFFCCCCCC), size: 20),
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
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text('📓', style: TextStyle(fontSize: 34)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Caderno vazio',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: neutralDark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Salve receitas favoritas, de família\nou crie novas do zero.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textMedium,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
