import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../model/recipe.dart';
import '../../../providers.dart';
import '../../theme/app_colors.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final Recipe recipe;
  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = ref.read(savedRecipesActionsProvider.notifier);

    // Get latest favorite state from saved recipes
    final savedAsync = ref.watch(savedRecipesProvider);
    final currentRecipe = savedAsync.maybeWhen(
      data: (list) => list.where((r) => r.id == recipe.id).firstOrNull ?? recipe,
      orElse: () => recipe,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero image
                SizedBox(
                  height: 280,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      currentRecipe.imageUrl != null
                          ? CachedNetworkImage(
                        imageUrl: currentRecipe.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: surfaceGray),
                        errorWidget: (_, __, ___) => Container(
                          color: surfaceGray,
                          child: const Center(
                              child: Text('🍽',
                                  style: TextStyle(fontSize: 48))),
                        ),
                      )
                          : Container(
                        color: surfaceGray,
                        child: const Center(
                            child: Text('🍽',
                                style: TextStyle(fontSize: 48))),
                      ),
                      // Gradient overlay
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x59000000),
                              Colors.transparent,
                              Color(0x99000000),
                            ],
                            stops: [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                      // Title overlay
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentRecipe.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              children: [
                                _badge('⏱ ${currentRecipe.cookingTime}'),
                                _badge('🍽 ${currentRecipe.servings}'),
                                if (currentRecipe.source != null)
                                  _badge('🌐 ${currentRecipe.source!}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      Text(
                        currentRecipe.description,
                        style: const TextStyle(
                            color: textMedium, fontSize: 15, height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Color(0xFFF0F0F0)),
                      const SizedBox(height: 20),

                      // Ingredients
                      const Text('Ingredientes',
                          style: TextStyle(
                              color: brandOrange,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ...currentRecipe.ingredients.map((ingredient) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(top: 6, right: 12),
                              decoration: const BoxDecoration(
                                color: brandOrange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(ingredient,
                                  style: const TextStyle(fontSize: 14)),
                            ),
                          ],
                        ),
                      )),

                      const SizedBox(height: 20),
                      const Divider(color: Color(0xFFF0F0F0)),
                      const SizedBox(height: 20),

                      // Steps
                      const Text('Modo de preparo',
                          style: TextStyle(
                              color: brandOrange,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ...currentRecipe.steps.asMap().entries.map((entry) {
                        final index = entry.key;
                        final step = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: const BoxDecoration(
                                  color: brandOrange,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(step,
                                      style: const TextStyle(
                                          fontSize: 14, height: 1.5)),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 8),

                      // Cook button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () =>
                              context.go('/cooking', extra: currentRecipe),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandOrange,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text(
                            'Iniciar Modo Cozinha 👨‍🍳',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Back button overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back,
                    color: Colors.white, size: 20),
              ),
            ),
          ),

          // Favorite button overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: GestureDetector(
              onTap: () => actions.toggleFavorite(
                  currentRecipe.id, currentRecipe.isFavorite),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  currentRecipe.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: currentRecipe.isFavorite
                      ? brandOrange
                      : Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}
