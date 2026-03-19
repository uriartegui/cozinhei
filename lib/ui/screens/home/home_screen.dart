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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeProvider.notifier).syncFridgeSuggestions();
    });
  }

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
    // ── Se não tem ingredientes, pergunta primeiro ──────────────
    if (chips.isEmpty) {
      _showNoIngredientsDialog(selectedCategory, selectedSubcategory, selectedTags);
      return;
    }
    _openServingsDialog(chips, selectedCategory, selectedSubcategory, selectedTags);
  }

  void _openServingsDialog(List<String> chips, String? selectedCategory,
      String? selectedSubcategory, Set<String> selectedTags) {
    _servingsController.clear();
    showDialog(
      context: context,
      builder: (_) => _ServingsDialog(
        controller: _servingsController,
        onGenerate: (servings) {
          FocusScope.of(context).unfocus();
          Navigator.of(context, rootNavigator: true).pop();
          final notifier = ref.read(homeProvider.notifier);
          final q = _buildQuery(chips, selectedCategory, selectedSubcategory, selectedTags);
          notifier.onQueryChange(q.isEmpty ? 'receitas variadas' : q);
          notifier.generateRecipes(servings: servings);
        },
      ),
    );
  }

  void _showNoIngredientsDialog(String? selectedCategory,
      String? selectedSubcategory, Set<String> selectedTags) {
    showDialog(
      context: context,
      builder: (dialogContext) => _NoIngredientsDialog(
        onGenerateWithout: () {
          Navigator.of(dialogContext).pop();
          // Depois de confirmar sem ingredientes, pede a quantidade
          _openServingsDialog([], selectedCategory, selectedSubcategory, selectedTags);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<String>>(fridgeProvider, (previous, next) {
      if (previous != null && previous.length != next.length) {
        ref.read(homeProvider.notifier).syncFridgeSuggestions();
      }
    });

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
                Row(
                  children: [
                    const Icon(Icons.restaurant_menu,
                        color: brandOrange, size: 22),
                    const SizedBox(width: 8),
                    Text('Olá, Chef!',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: neutralDark,
                                letterSpacing: -0.3)),
                  ],
                ),
                const SizedBox(height: 20),

                // Hero headline
                const Text(
                  'O que vamos\ncozinhar hoje?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    letterSpacing: -0.8,
                    color: neutralDark,
                  ),
                ),
                const SizedBox(height: 8),

                // Fridge CTA — link de texto minimalista
                GestureDetector(
                  onTap: () => _showFridgeSheet(context, notifier),
                  child: const Text(
                    'Ver receitas da sua geladeira →',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: brandOrange,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Categories
                SizedBox(
                  height: 34,
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
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? brandOrange
                                : const Color(0xFFEAE7EA),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            cat.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : neutralDark,
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

                // Tags (visível ao selecionar categoria)
                if (selectedCategory != null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: allTags.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final tag = allTags[i];
                        final isSelected = selectedTags.contains(tag);
                        return GestureDetector(
                          onTap: () => notifier.toggleTag(tag),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
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
                              tag,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? brandOrange
                                    : neutralDark,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
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
                          prefixIcon: const Icon(Icons.flatware,
                              color: Color(0xFF59413B), size: 20),
                          hintText: 'Ex: Frango, batata...',
                          hintStyle: const TextStyle(
                              color: Color(0xFF59413B), fontSize: 14),
                          filled: true,
                          fillColor: const Color(0xFFEAE7EA),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                                color: brandOrange, width: 1.5),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
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
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAE7EA),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.add,
                            color: neutralDark),
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
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: uiState is! HomeLoading
                            ? [const Color(0xFFAE310E), brandOrange]
                            : [
                                const Color(0xFFAE310E).withOpacity(0.4),
                                brandOrange.withOpacity(0.4),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: uiState is! HomeLoading
                          ? [
                              BoxShadow(
                                color: brandOrange.withOpacity(0.25),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              )
                            ]
                          : [],
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
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                letterSpacing: 0.2)),
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
                  GestureDetector(
                    onTap: () => _showServingsDialog(
                        chips, selectedCategory, selectedSubcategory, selectedTags),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: brandOrange.withOpacity(0.5), width: 1.5),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome,
                              color: brandOrange, size: 16),
                          SizedBox(width: 8),
                          Text('Gerar outras',
                              style: TextStyle(
                                  color: brandOrange,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)),
                        ],
                      ),
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

  void _showFridgeSheet(BuildContext context, HomeNotifier notifier) {
    notifier.syncFridgeSuggestions();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Consumer(
        builder: (ctx, ref, __) {
          final fridgeSuggestions = ref.watch(homeProvider).fridgeSuggestions;
          final fridgeCount = ref.watch(fridgeProvider).length;
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Da sua geladeira',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: neutralDark,
                        )),
                    if (fridgeSuggestions is FridgeSuggestionsSuccess)
                      GestureDetector(
                        onTap: notifier.loadFridgeSuggestions,
                        child: const Text('Gerar novas',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: brandOrange,
                            )),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFridgeSection(fridgeSuggestions, notifier, fridgeCount),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFridgeSection(
      FridgeSuggestionsState fridgeSuggestions, HomeNotifier notifier,
      int fridgeCount) {
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
              Icon(Icons.kitchen, size: 20, color: brandOrange),
              SizedBox(width: 6),
              const Text('Sua geladeira está vazia',
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

class _ServingsDialog extends StatefulWidget {
  final TextEditingController controller;
  final void Function(int servings) onGenerate;

  const _ServingsDialog(
      {required this.controller, required this.onGenerate});

  @override
  State<_ServingsDialog> createState() => _ServingsDialogState();
}

class _ServingsDialogState extends State<_ServingsDialog> {
  String? _error;

  void _submit() {
    final raw = int.tryParse(widget.controller.text.trim());
    if (raw == null || raw < 1) {
      setState(() => _error = 'Informe um número entre 1 e 100');
      return;
    }
    if (raw > 100) {
      setState(() => _error = 'O máximo é 100 pessoas');
      return;
    }
    setState(() => _error = null);
    widget.onGenerate(raw);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Título + fechar ────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: Text(
                    'Para quantas pessoas?',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Color(0xFF1C1C1E),
                      letterSpacing: -0.3,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0EDEA),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close,
                        color: Color(0xFF888888), size: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Descrição ──────────────────────────────────────────
            const Text(
              'As quantidades dos ingredientes serão ajustadas para o número de pessoas informado.',
              style: TextStyle(
                color: textMedium,
                fontSize: 13,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 16),

            // ── Campo de texto ─────────────────────────────────────
            TextField(
              controller: widget.controller,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1C1C1E),
              ),
              decoration: InputDecoration(
                hintText: 'Quantidade de pessoas',
                hintStyle: const TextStyle(
                  color: Color(0xFFBBBBBB),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.group_outlined,
                  color: Color(0xFFBBBBBB),
                  size: 20,
                ),
                errorText: _error,
                errorStyle: const TextStyle(fontSize: 12),
                filled: true,
                fillColor: const Color(0xFFF5F2EE),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: brandOrange, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Colors.redAccent, width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Colors.redAccent, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),

            // ── Botão ──────────────────────────────────────────────
            GestureDetector(
              onTap: _submit,
              child: Container(
                height: 52,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: brandGradient,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: brandOrange.withValues(alpha: 0.30),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Gerar Receitas',
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
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── X fechar ──────────────────────────────────────────
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0EDEA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close,
                      color: Color(0xFF888888), size: 14),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── Ícone de alerta ────────────────────────────────────
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: brandOrange.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    gradient: brandGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Título ─────────────────────────────────────────────
            const Text(
              'Nenhum ingrediente\nadicionado',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Color(0xFF1C1C1E),
                letterSpacing: -0.3,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),

            // ── Instrução principal ────────────────────────────────
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                    color: textMedium, fontSize: 13, height: 1.5),
                children: [
                  const TextSpan(text: 'Escreva os ingredientes, clique no '),
                  TextSpan(
                    text: '+',
                    style: TextStyle(
                        color: brandOrange, fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(text: ' e depois em '),
                  TextSpan(
                    text: 'Gerar Receitas.',
                    style: TextStyle(
                        color: brandOrange, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Dica secundária ────────────────────────────────────
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: brandOrange.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: brandOrange.withValues(alpha: 0.18),
                  width: 1,
                ),
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                      color: textMedium, fontSize: 12, height: 1.5),
                  children: [
                    const TextSpan(
                        text: 'Caso queira continuar sem ingredientes, '
                            'clique em '),
                    TextSpan(
                      text: '"Gerar sem ingrediente".',
                      style: TextStyle(
                          color: brandOrange, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Botão principal ────────────────────────────────────
            GestureDetector(
              onTap: onGenerateWithout,
              child: Container(
                height: 52,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: brandGradient,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: brandOrange.withValues(alpha: 0.30),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Gerar sem ingrediente',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ── Link voltar ────────────────────────────────────────
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  'Voltar e editar',
                  style: TextStyle(
                    color: textMedium,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
