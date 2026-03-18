import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../model/recipe_filter.dart';
import '../../../providers.dart';
import '../../../viewmodel/home_state.dart';
import '../../../viewmodel/home_notifier.dart';
import '../../theme/app_colors.dart';
import '../../widgets/recipe_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _inputController = TextEditingController();
  final _servingsController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    _servingsController.dispose();
    super.dispose();
  }

  void _addChip() {
    final item = _inputController.text.trim();
    if (item.isNotEmpty) {
      ref.read(homeProvider.notifier).addChip(item);
      _inputController.clear();
    }
  }

  String _buildQuery(List<String> chips, String? selectedCategory,
      String? selectedSubcategory, Set<String> selectedTags) {
    final sb = StringBuffer();
    if (chips.isNotEmpty) sb.write(chips.join(', '));
    if (selectedCategory != null) {
      if (sb.isNotEmpty) sb.write(' - ');
      sb.write(selectedCategory);
      if (selectedSubcategory != null) sb.write(': $selectedSubcategory');
    }
    if (selectedTags.isNotEmpty) {
      if (sb.isNotEmpty) sb.write(' - ');
      sb.write('estilo: ${selectedTags.join(', ')}');
    }
    return sb.toString();
  }

  void _showServingsDialog(List<String> chips, String? selectedCategory,
      String? selectedSubcategory, Set<String> selectedTags) {
    _servingsController.clear();
    showDialog(
      context: context,
      builder: (_) => _ServingsDialog(
        controller: _servingsController,
        onGenerate: (servings) {
          FocusScope.of(context).unfocus();
          Navigator.of(context, rootNavigator: true).pop();
          if (chips.isEmpty && selectedCategory == null && selectedTags.isEmpty) {
            _showNoIngredientsDialog(selectedCategory, selectedSubcategory, selectedTags);
          } else {
            final notifier = ref.read(homeProvider.notifier);
            notifier.onQueryChange(
                _buildQuery(chips, selectedCategory, selectedSubcategory, selectedTags));
            notifier.generateRecipes(servings: servings);
          }
        },
      ),
    );
  }

  void _showNoIngredientsDialog(String? selectedCategory,
      String? selectedSubcategory, Set<String> selectedTags) {
    showDialog(
      context: context,
      builder: (_) => _NoIngredientsDialog(
        onGenerateWithout: () {
          Navigator.pop(context);
          final query = selectedCategory != null
              ? '$selectedCategory${selectedSubcategory != null ? ': $selectedSubcategory' : ''}'
                  '${selectedTags.isNotEmpty ? ' - estilo: ${selectedTags.join(', ')}' : ''}'
              : 'receitas variadas';
          final notifier = ref.read(homeProvider.notifier);
          notifier.onQueryChange(query);
          notifier.generateRecipes();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeProvider);
    final notifier = ref.read(homeProvider.notifier);
    final chips = state.chips;
    final uiState = state.uiState;
    final fridgeSuggestions = state.fridgeSuggestions;
    final selectedCategory = state.selectedCategory;
    final selectedSubcategory = state.selectedSubcategory;
    final selectedTags = state.selectedTags;
    final currentCategory =
        allCategories.where((c) => c.name == selectedCategory).firstOrNull;

    return Scaffold(
      backgroundColor: brandOrangeLight,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Header
                Text('Olá, Chef! 🍳',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold, color: brandOrange)),
                Text('O que vamos cozinhar hoje?',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: textMedium)),
                const SizedBox(height: 16),

                // Fridge section header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.kitchen, size: 18, color: brandOrange),
                        const SizedBox(width: 6),
                        Text('Da sua geladeira',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    if (fridgeSuggestions is FridgeSuggestionsSuccess)
                      TextButton(
                        onPressed: notifier.loadFridgeSuggestions,
                        child: const Text('Gerar novas',
                            style: TextStyle(color: brandOrange, fontSize: 12)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Fridge content
                _buildFridgeSection(fridgeSuggestions, notifier),
                const SizedBox(height: 12),
                const Divider(color: Color(0xFFE0E0E0)),
                const SizedBox(height: 8),

                // Categories
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: allCategories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final cat = allCategories[i];
                      final isSelected = selectedCategory == cat.name;
                      return GestureDetector(
                        onTap: () {
                          if (isSelected) {
                            notifier.setCategory(null);
                          } else {
                            notifier.setCategory(cat.name);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? brandOrange : surfaceGray,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            '${cat.emoji} ${cat.name}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Subcategories
                if (currentCategory != null &&
                    currentCategory.subcategories.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: currentCategory.subcategories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final sub = currentCategory.subcategories[i];
                        final isSelected = selectedSubcategory == sub;
                        return GestureDetector(
                          onTap: () {
                            notifier.setSubcategory(isSelected ? null : sub);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? brandOrange.withOpacity(0.12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: isSelected
                                    ? brandOrange
                                    : const Color(0xFFDDDDDD),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              sub,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? brandOrange
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                // Tags
                if (selectedSubcategory != null) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: allTags.map((tag) {
                      final isSelected = selectedTags.contains(tag);
                      return GestureDetector(
                        onTap: () => notifier.toggleTag(tag),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? brandOrange : surfaceGray,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 12),

                // Input row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        decoration: InputDecoration(
                          hintText: 'Ex: leite, ovo, macarrão...',
                          hintStyle: const TextStyle(color: textMedium),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide:
                                const BorderSide(color: Color(0xFFE0E0E0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide:
                                const BorderSide(color: Color(0xFFE0E0E0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: brandOrange),
                          ),
                          filled: true,
                          fillColor: surfaceGray,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: (_) => _addChip(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _addChip,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          gradient: brandGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),

                // Chips
                if (chips.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: chips
                        .map((chip) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: brandGradient,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(chip,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12)),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () => notifier.removeChip(chip),
                                    child: const Icon(Icons.close,
                                        color: Colors.white, size: 14),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ],

                const SizedBox(height: 10),

                // Generate button
                GestureDetector(
                  onTap: uiState is! HomeLoading
                      ? () => _showServingsDialog(
                          chips, selectedCategory, selectedSubcategory, selectedTags)
                      : null,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: uiState is! HomeLoading
                            ? [brandOrange, brandOrangePink]
                            : [
                                brandOrange.withOpacity(0.4),
                                brandOrangePink.withOpacity(0.4)
                              ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome,
                            color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('Gerar Receitas',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Loading — skeleton grid
                if (uiState is HomeLoading) ...[
                  const SizedBox(height: 8),
                  const Text('Buscando receitas...',
                      style: TextStyle(color: textMedium, fontSize: 13)),
                  const SizedBox(height: 12),
                ],

                // Error
                if (uiState is HomeError)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEEEE),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(uiState.message,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  ),

                // Success header
                if (uiState is HomeSuccess) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${uiState.recipes.length} receitas encontradas',
                          style: const TextStyle(
                              color: textMedium, fontSize: 12)),
                      TextButton(
                        onPressed: notifier.clearAll,
                        child: const Text('Limpar',
                            style: TextStyle(color: brandOrange)),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _showServingsDialog(
                        chips, selectedCategory, selectedSubcategory, selectedTags),
                    icon: const Icon(Icons.auto_awesome,
                        color: brandOrange, size: 16),
                    label: const Text('Gerar outras',
                        style: TextStyle(color: brandOrange)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: brandOrange),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ]),
            ),
          ),

          // Recipe Grid
          if (uiState is HomeSuccess)
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.70,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final recipe = uiState.recipes[i];
                    return RecipeCard(
                      recipe: recipe,
                      onClick: () {
                        notifier.saveRecipe(recipe);
                        context.push('/recipe', extra: recipe);
                      },
                      onToggleFavorite: () {},
                      onDelete: () {},
                    );
                  },
                  childCount: uiState.recipes.length,
                ),
              ),
            ),
          // Skeleton Grid
          if (uiState is HomeLoading)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.70,
                ),
                delegate: SliverChildBuilderDelegate(
                      (_, __) => _SkeletonCard(),
                  childCount: 4,
                ),
              ),
            ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }

  Widget _buildFridgeSection(
      FridgeSuggestionsState fridgeSuggestions, HomeNotifier notifier) {
    if (fridgeSuggestions is FridgeSuggestionsLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: brandOrange, strokeWidth: 2)),
            SizedBox(width: 10),
            Text('Buscando sugestões...',
                style: TextStyle(color: textMedium)),
          ],
        ),
      );
    }

    if (fridgeSuggestions is FridgeSuggestionsSuccess) {
      return SizedBox(
        height: 160,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: fridgeSuggestions.recipes.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final recipe = fridgeSuggestions.recipes[i];
            return GestureDetector(
              onTap: () {
                notifier.saveRecipe(recipe);
                context.push('/recipe', extra: recipe);
              },
              child: Container(
                width: 130,
                decoration: BoxDecoration(
                  color: surfaceGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    recipe.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: recipe.imageUrl!,
                            height: 80,
                            width: 130,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 80,
                            color: const Color(0xFFEEEEEE),
                            child: const Center(
                                child: Icon(Icons.restaurant,
                                    color: Colors.grey)),
                          ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(recipe.name,
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.schedule, size: 11, color: textMedium),
                              const SizedBox(width: 3),
                              Text(recipe.cookingTime,
                                  style: const TextStyle(color: textMedium, fontSize: 10)),
                            ],
                          ),
                          if (recipe.source != null)
                            Row(
                              children: [
                                const Icon(Icons.public, size: 11, color: textMedium),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(recipe.source!,
                                      style: const TextStyle(color: textMedium, fontSize: 10),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    // Empty state
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: brandOrangeLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.kitchen, size: 20, color: brandOrange),
              SizedBox(width: 6),
              Text('Sua geladeira está vazia',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Preencha com os ingredientes que você tem em casa para ver receitas sugeridas aqui',
            textAlign: TextAlign.center,
            style: TextStyle(color: textMedium, fontSize: 12),
          ),
          TextButton(
            onPressed: () => context.go('/fridge'),
            child: const Text('Ir para geladeira  >',
                style: TextStyle(
                    color: brandOrange, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatefulWidget {
  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFFE8E4E0),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 12, width: double.infinity,
                      decoration: BoxDecoration(color: const Color(0xFFE8E4E0),
                          borderRadius: BorderRadius.circular(6))),
                  const SizedBox(height: 6),
                  Container(height: 12, width: 100,
                      decoration: BoxDecoration(color: const Color(0xFFEEEAE6),
                          borderRadius: BorderRadius.circular(6))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dialogs ───────────────────────────────────────────────────────────────────

class _ServingsDialog extends StatelessWidget {
  final TextEditingController controller;
  final void Function(int servings) onGenerate;

  const _ServingsDialog(
      {required this.controller, required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Spacer(),
                const Text('Para quantas pessoas? 👨‍👩‍👧‍👦',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'A IA vai ajustar as quantidades dos ingredientes para o número certo de pessoas.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textMedium, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              decoration: InputDecoration(
                hintText: 'Quantidade de pessoas',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                final servings =
                    (int.tryParse(controller.text) ?? 4).clamp(1, 100);
                onGenerate(servings);
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: brandGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Gerar Receitas',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoIngredientsDialog extends StatelessWidget {
  final VoidCallback onGenerateWithout;

  const _NoIngredientsDialog({required this.onGenerateWithout});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.grey),
              ),
            ),
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                    colors: [Color(0xFFFFE0CC), Color(0xFFFFF3EC)]),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    gradient: brandGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('!',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Nenhum ingrediente\nadicionado',
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                children: [
                  const TextSpan(text: 'Escreva os ingredientes, clique no '),
                  const TextSpan(
                      text: '+',
                      style: TextStyle(
                          color: brandOrange,
                          fontWeight: FontWeight.bold)),
                  const TextSpan(text: ' e depois em '),
                  const TextSpan(
                      text: 'Gerar Receitas.',
                      style: TextStyle(
                          color: brandOrange,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: brandOrangeLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(color: Colors.black87, fontSize: 13),
                  children: [
                    TextSpan(
                        text:
                            'Caso queira continuar sem ingredientes, clique em '),
                    TextSpan(
                        text: '"Gerar sem ingrediente".',
                        style: TextStyle(
                            color: brandOrange,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onGenerateWithout,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: brandGradient,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Center(
                  child: Text('Gerar sem ingrediente',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Center(
                  child: Text('Voltar',
                      style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
