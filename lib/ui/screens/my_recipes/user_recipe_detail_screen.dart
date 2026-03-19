import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../model/recipe.dart';
import '../../../model/user_recipe.dart';
import '../../../providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/step_timer_widget.dart';
import 'package:share_plus/share_plus.dart';

class UserRecipeDetailScreen extends ConsumerWidget {
  final UserRecipe recipe;
  const UserRecipeDetailScreen({super.key, required this.recipe});

  Recipe _toRecipe(UserRecipe recipe) {
    final totalMinutes = recipe.steps
        .where((s) => s.durationMinutes != null)
        .fold(0, (sum, s) => sum + s.durationMinutes!);
    return Recipe(
      id: recipe.id,
      name: recipe.name,
      description: recipe.description ?? '',
      ingredients: recipe.ingredients,
      steps: recipe.steps.map((s) {
        // Se durationMinutes definido e a descrição já não menciona tempo,
        // adiciona ao final para que cooking mode detecte o timer.
        // Se a descrição já tem tempo (ex: "4 minutos"), não duplica.
        if (s.durationMinutes != null && s.durationMinutes! > 0) {
          final hasTimeInText = parseStepSeconds(s.description) != null;
          if (!hasTimeInText) {
            return '${s.description} (${s.durationMinutes} minutos)';
          }
        }
        return s.description;
      }).toList(),
      cookingTime: totalMinutes > 0 ? '$totalMinutes min' : '-',
      servings: '-',
      imageUrl: recipe.imageUrl,
      createdAt: recipe.createdAt,
    );
  }

  int _totalMinutes(UserRecipe r) => r.steps
      .where((s) => s.durationMinutes != null)
      .fold(0, (sum, s) => sum + s.durationMinutes!);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observa o provider e usa a versão mais recente da receita pelo ID
    final current = ref.watch(userRecipesProvider).maybeWhen(
          data: (list) =>
              list.where((r) => r.id == recipe.id).firstOrNull ?? recipe,
          orElse: () => recipe,
        );

    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F2),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Hero ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _HeroSection(
                  recipe: current,
                  topPadding: topPadding,
                  onBack: () => context.pop(),
                  onShare: () => _shareRecipe(current),
                  onEdit: () => context.push('/recipe-editor', extra: current),
                ),
              ),

              // ── Descrição ─────────────────────────────────────────
              if (current.description != null && current.description!.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Text(
                      current.description!,
                      style: const TextStyle(
                        color: textMedium,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),

              // ── Ingredientes ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Text(
                    'Ingredientes',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          letterSpacing: -0.4,
                          color: neutralDark,
                        ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: brandOrange.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 12,
                              color: brandOrange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              current.ingredients[i],
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: neutralDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    childCount: current.ingredients.length,
                  ),
                ),
              ),

              // ── Modo de Preparo ───────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Modo de Preparo',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                    letterSpacing: -0.4,
                                    color: neutralDark,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final step = current.steps[i];
                      // Prefere tempo do texto da descrição (ex: "4 minutos");
                      // usa durationMinutes só se descrição não tiver tempo
                      final secsFromText = parseStepSeconds(step.description);
                      final secs = secsFromText ??
                          (step.durationMinutes != null && step.durationMinutes! > 0
                              ? step.durationMinutes! * 60
                              : null);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: brandOrange,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${i + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text(
                                      step.description,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.6,
                                        color: neutralDark,
                                      ),
                                    ),
                                  ),
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
                    childCount: current.steps.length,
                  ),
                ),
              ),
            ],
          ),

          // ── Botão fixo no fundo ───────────────────────────────────
          Positioned(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).padding.bottom + 16,
            child: GestureDetector(
              onTap: () => context.push('/cooking', extra: _toRecipe(current)),
              child: Container(
                height: 56,
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
                    Icon(Icons.restaurant_menu,
                        color: Colors.white, size: 18),
                    SizedBox(width: 10),
                    Text(
                      'Iniciar Modo Cozinha',
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

  void _shareRecipe(UserRecipe r) {
    final buf = StringBuffer();
    buf.writeln('${r.coverEmoji} ${r.name}');
    if (r.description != null && r.description!.isNotEmpty) {
      buf.writeln(r.description);
    }
    buf.writeln();
    buf.writeln('📝 Ingredientes:');
    for (final i in r.ingredients) {
      buf.writeln('• $i');
    }
    buf.writeln();
    buf.writeln('👨‍🍳 Modo de preparo:');
    for (int i = 0; i < r.steps.length; i++) {
      buf.writeln('${i + 1}. ${r.steps[i].description}');
    }
    buf.writeln();
    buf.writeln('Feito com Cozinhei 🍽️');
    Share.share(buf.toString());
  }
}

// ── Hero Section ──────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final UserRecipe recipe;
  final double topPadding;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onEdit;

  const _HeroSection({
    required this.recipe,
    required this.topPadding,
    required this.onBack,
    required this.onShare,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty;

    return SizedBox(
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background ──────────────────────────────────────────────
          if (hasImage)
            _buildCoverImage(recipe.imageUrl!)
          else
            _gradientBackground(),

          // ── Emoji centralizado (quando sem foto) ─────────────────────
          if (!hasImage)
            Positioned(
              top: topPadding + 52,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  recipe.coverEmoji,
                  style: const TextStyle(fontSize: 72, height: 1.0),
                ),
              ),
            ),

          // ── Overlay escuro degradê no fundo ──────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: hasImage ? 0.15 : 0.0),
                  Colors.black.withValues(alpha: 0.0),
                  Colors.black.withValues(alpha: 0.55),
                ],
                stops: const [0.0, 0.35, 1.0],
              ),
            ),
          ),

          // ── Botão voltar ────────────────────────────────────────────
          Positioned(
            top: topPadding + 8,
            left: 12,
            child: _circleButton(Icons.arrow_back_ios_new, onBack, size: 16),
          ),

          // ── Share + Edit ────────────────────────────────────────────
          Positioned(
            top: topPadding + 8,
            right: 12,
            child: Row(
              children: [
                _circleButton(Icons.share_outlined, onShare),
                const SizedBox(width: 8),
                _circleButton(Icons.edit_outlined, onEdit),
              ],
            ),
          ),

          // ── Nome + badges na base ────────────────────────────────────
          Positioned(
            left: 20,
            right: 20,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  recipe.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                    height: 1.1,
                    shadows: [
                      Shadow(
                        color: Colors.black38,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _heroBadge('${recipe.steps.length} passo${recipe.steps.length == 1 ? '' : 's'}'),
                    _heroBadge('${recipe.ingredients.length} ingrediente${recipe.ingredients.length == 1 ? '' : 's'}'),
                    if (recipe.isPublic) _heroBadge('Pública', highlight: true),
                    if (recipe.category != null) _heroBadge(recipe.category!),
                    if (recipe.subcategory != null) _heroBadge(recipe.subcategory!),
                    ...recipe.tags.map((t) => _heroBadge(t)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage(String url) {
    final isLocal = url.startsWith('/') || url.startsWith('file://');
    if (isLocal) {
      return Image.file(
        File(url.replaceFirst('file://', '')),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _gradientBackground(),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _gradientBackground(),
    );
  }

  Widget _gradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFAE310E), brandOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap, {double size = 18}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.28),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }

  Widget _heroBadge(String label, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: highlight
            ? brandOrange.withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.30),
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
