import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../model/recipe.dart';
import '../../viewmodel/home_notifier.dart';
import '../theme/app_colors.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onClick;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDelete;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onClick,
    required this.onToggleFavorite,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final category = HomeNotifier.getCategory(recipe.name);

    return GestureDetector(
      onTap: onClick,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          color: Colors.white,
          surfaceTintColor: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: recipe.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: recipe.imageUrl!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _placeholder(),
                            errorWidget: (_, __, ___) => _placeholder(),
                          )
                        : _placeholder(),
                  ),
                  if (category != 'Outras')
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delete, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
              // Info
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.schedule, size: 12, color: textMedium),
                            const SizedBox(width: 3),
                            Text(recipe.cookingTime,
                                style: const TextStyle(color: textMedium, fontSize: 11)),
                          ],
                        ),
                        GestureDetector(
                          onTap: onToggleFavorite,
                          child: Icon(
                            recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: recipe.isFavorite ? brandOrange : const Color(0xFFCCCCCC),
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    if (recipe.source != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.public, size: 12, color: textMedium),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              recipe.source!,
                              style: const TextStyle(color: textMedium, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 150,
      color: surfaceGray,
      child: const Center(
        child: Icon(Icons.restaurant, color: Color(0xFFCCBFB8), size: 40),
      ),
    );
  }
}
