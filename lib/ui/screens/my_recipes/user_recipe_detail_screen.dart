import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../model/recipe.dart';
import '../../../model/user_recipe.dart';
import '../../theme/app_colors.dart';
import '../../widgets/step_timer_widget.dart';

class UserRecipeDetailScreen extends StatelessWidget {
  final UserRecipe recipe;
  const UserRecipeDetailScreen({super.key, required this.recipe});

  Recipe _toRecipe() {
    final totalMinutes = recipe.steps
        .where((s) => s.durationMinutes != null)
        .fold(0, (sum, s) => sum + s.durationMinutes!);
    return Recipe(
      id: recipe.id,
      name: recipe.name,
      description: recipe.description ?? '',
      ingredients: recipe.ingredients,
      steps: recipe.steps.map((s) {
        if (s.durationMinutes != null && s.durationMinutes! > 0) {
          return '${s.description} (${s.durationMinutes} minutos)';
        }
        return s.description;
      }).toList(),
      cookingTime: totalMinutes > 0 ? '$totalMinutes min' : '-',
      servings: '-',
      imageUrl: recipe.imageUrl,
      createdAt: recipe.createdAt,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brandOrangeLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: brandOrange,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                tooltip: 'Editar receita',
                onPressed: () => context.push('/recipe-editor', extra: recipe),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [brandOrange, brandOrangeDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Text(recipe.coverEmoji,
                        style: const TextStyle(fontSize: 72)),
                    const SizedBox(height: 8),
                    Text(
                      recipe.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Badges
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  _badge(Icons.list_alt, '${recipe.steps.length} passos'),
                  const SizedBox(width: 8),
                  _badge(Icons.kitchen_outlined,
                      '${recipe.ingredients.length} ingredientes'),
                  if (recipe.isPublic) ...[
                    const SizedBox(width: 8),
                    _badge(Icons.public, 'Pública',
                        color: badgeGreen),
                  ],
                ],
              ),
            ),
          ),

          // Descrição
          if (recipe.description != null && recipe.description!.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(
                  recipe.description!,
                  style: const TextStyle(
                      color: textMedium, fontSize: 14, height: 1.6),
                ),
              ),
            ),

          // Ingredientes
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text('Ingredientes',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Icon(Icons.circle, size: 6, color: brandOrange),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(recipe.ingredients[i],
                            style: const TextStyle(fontSize: 14, height: 1.5)),
                      ),
                    ],
                  ),
                ),
                childCount: recipe.ingredients.length,
              ),
            ),
          ),

          // Passos
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text('Modo de preparo',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (_, i) {
                  final step = recipe.steps[i];
                  final secs = parseStepSeconds(step.description +
                      (step.durationMinutes != null
                          ? ' ${step.durationMinutes} minutos'
                          : ''));
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: brandOrange,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text('${i + 1}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(step.description,
                                  style: const TextStyle(
                                      fontSize: 14, height: 1.6)),
                              if (secs != null) ...[
                                const SizedBox(height: 8),
                                StepTimerWidget(totalSeconds: secs),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: recipe.steps.length,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: ElevatedButton.icon(
            onPressed: () => context.push('/cooking', extra: _toRecipe()),
            icon: const Icon(Icons.restaurant_menu, color: Colors.white),
            label: const Text('Iniciar Modo Cozinha 👨‍🍳',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: brandOrange,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(IconData icon, String label, {Color color = brandOrange}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
