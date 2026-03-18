import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../data/repository/community_recipe_repository.dart';
import '../../../di/injection.dart';
import '../../../model/recipe_filter.dart';
import '../../../model/user_recipe.dart';
import '../../../providers.dart';
import '../../theme/app_colors.dart';

const _emojis = [
  '🍽','🍕','🍔','🍣','🍜','🥗','🍲','🥘','🍱','🥩',
  '🍗','🥚','🧀','🥦','🍅','🌽','🍋','🍰','🎂','🍩',
  '🥐','🍞','🧇','🥞','🫕','🥙','🌮','🫔','🍛','🍤',
];

const _categories = [
  'Café da Manhã', 'Massas', 'Carnes', 'Frango',
  'Peixes', 'Saladas', 'Lanches', 'Sopas', 'Arroz',
  'Pizzas', 'Sobremesas', 'Cozinhas do Mundo', 'Vegetariano',
];

const _tagOptions = [
  '⚡ Rápido', '🔥 Air Fryer', '🥑 Saudável', '🌱 Vegano',
  '💪 Proteico', '💰 Econômico', '🍽️ Fácil', '👨‍🍳 Gourmet',
];

class RecipeEditorScreen extends ConsumerStatefulWidget {
  final UserRecipe? existing;
  const RecipeEditorScreen({super.key, this.existing});

  @override
  ConsumerState<RecipeEditorScreen> createState() => _RecipeEditorScreenState();
}

class _RecipeEditorScreenState extends ConsumerState<RecipeEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late String _emoji;
  late bool _isPublic;
  late List<String> _ingredients;
  late List<UserRecipeStep> _steps;

  final _ingredientCtrl = TextEditingController();

  late final TextEditingController _authorCtrl;
  String? _category;
  String? _subcategory;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    final r = widget.existing;
    _nameCtrl = TextEditingController(text: r?.name ?? '');
    _descCtrl = TextEditingController(text: r?.description ?? '');
    _emoji = r?.coverEmoji ?? '🍽';
    _isPublic = r?.isPublic ?? false;
    _authorCtrl = TextEditingController(text: r?.authorName ?? '');
    _category = r?.category;
    _subcategory = r?.subcategory;
    _tags = List.from(r?.tags ?? []);
    _ingredients = List.from(r?.ingredients ?? []);
    _steps = List.from(r?.steps ?? [const UserRecipeStep(description: '')]);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _ingredientCtrl.dispose();
    super.dispose();
    _authorCtrl.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(userRecipesProvider.notifier);
    final existing = widget.existing;
    final recipe = UserRecipe(
      id: existing?.id ?? notifier.generateId(),
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      ingredients: _ingredients,
      steps: _steps.where((s) => s.description.trim().isNotEmpty).toList(),
      coverEmoji: _emoji,
      isPublic: _isPublic,
      createdAt: existing?.createdAt,
      authorName: _authorCtrl.text.trim(),
      category: _category,
      subcategory: _subcategory,
      tags: _tags,
    );
    await notifier.save(recipe);

    if (_isPublic) {
      final communityRepo = ref.read(communityRecipeRepositoryProvider);
      await _publishToCommunity(recipe, communityRepo);
    }

    if (mounted) context.pop();
  }

  Future<void> _publishToCommunity(
    UserRecipe recipe,
    CommunityRecipeRepository communityRepo,
  ) async {
    try {
      final prefs = getIt<SharedPreferences>();
      var deviceId = prefs.getString('device_id');
      if (deviceId == null) {
        deviceId = const Uuid().v4();
        await prefs.setString('device_id', deviceId);
      }
      final result = await communityRepo.publish(recipe: recipe, deviceId: deviceId);
      if (!result.ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Receita não aprovada: ${result.reason ?? "tente novamente"}'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (e) {
      debugPrint('PUBLISH ERROR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao publicar: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  void _addIngredient() {
    final v = _ingredientCtrl.text.trim();
    if (v.isNotEmpty) {
      setState(() => _ingredients.add(v));
      _ingredientCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brandOrangeLight,
      appBar: AppBar(
        backgroundColor: brandOrangeLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: brandOrange),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.existing == null ? 'Nova Receita' : 'Editar Receita',
          style: const TextStyle(
              color: brandOrange, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Salvar',
                style: TextStyle(
                    color: brandOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Emoji + Nome
            Row(
              children: [
                GestureDetector(
                  onTap: _pickEmoji,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(_emoji,
                          style: const TextStyle(fontSize: 32)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _nameCtrl,
                    decoration: _inputDecoration('Nome da receita *'),
                    validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Obrigatório' : null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Descrição
            TextFormField(
              controller: _descCtrl,
              decoration: _inputDecoration('Descrição (opcional)'),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 20),

            // Público / Privado
            _sectionHeader('Visibilidade'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                value: _isPublic,
                onChanged: (v) => setState(() => _isPublic = v),
                activeColor: brandOrange,
                title: Text(
                  _isPublic ? '🌐 Pública' : '🔒 Privada',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  _isPublic
                      ? 'Aparece para outros usuários'
                      : 'Só você pode ver',
                  style: const TextStyle(color: textMedium, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Nível 1 — Categoria (obrigatório)
            _sectionHeader('Categoria *'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: _inputDecoration('Selecione uma categoria'),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() {
                _category = v;
                _subcategory = null; // reseta subcategoria ao trocar categoria
              }),
              validator: (v) => v == null ? 'Selecione uma categoria' : null,
            ),
            const SizedBox(height: 12),

            // Nível 2 — Subcategoria (opcional, aparece se categoria tem subcategorias)
            Builder(builder: (_) {
              final subs = allCategories
                  .where((c) => c.name == _category)
                  .firstOrNull
                  ?.subcategories ?? [];
              if (subs.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('Subcategoria (opcional)'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _subcategory,
                    decoration: _inputDecoration('Selecione uma subcategoria'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Nenhuma')),
                      ...subs.map((s) => DropdownMenuItem(value: s, child: Text(s))),
                    ],
                    onChanged: (v) => setState(() => _subcategory = v),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            }),

            // Nível 3 — Tags (opcional)
            _sectionHeader('Tags (opcional)'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _tagOptions.map((tag) {
                final selected = _tags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: selected,
                  onSelected: (v) => setState(() =>
                  v ? _tags.add(tag) : _tags.remove(tag)),
                  selectedColor: brandOrangeLight,
                  checkmarkColor: brandOrange,
                  labelStyle: TextStyle(
                    color: selected ? brandOrange : textMedium,
                    fontSize: 12,
                  ),
                  side: BorderSide(
                    color: selected ? brandOrange : const Color(0xFFDDD8D3),
                  ),
                  backgroundColor: Colors.white,
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Nome do autor — só quando pública
            if (_isPublic) ...[
              _sectionHeader('Informações públicas'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _authorCtrl,
                decoration: _inputDecoration('Seu nome (aparece na receita) *'),
                textCapitalization: TextCapitalization.words,
                validator: (v) => _isPublic && (v == null || v.trim().isEmpty)
                    ? 'Obrigatório para receitas públicas'
                    : null,
              ),
              const SizedBox(height: 20),
            ],

            // Ingredientes
            _sectionHeader('Ingredientes'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ingredientCtrl,
                    decoration: _inputDecoration('Ex: 2 xícaras de farinha'),
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _addIngredient(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _addIngredient,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      gradient: brandGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._ingredients.asMap().entries.map((e) => _IngredientTile(
              text: e.value,
              onDelete: () =>
                  setState(() => _ingredients.removeAt(e.key)),
            )),
            const SizedBox(height: 20),

            // Passos
            _sectionHeader('Modo de preparo'),
            const SizedBox(height: 8),
            ..._steps.asMap().entries.map((e) => _StepTile(
              index: e.key,
              step: e.value,
              onChanged: (updated) =>
                  setState(() => _steps[e.key] = updated),
              onDelete: _steps.length > 1
                  ? () => setState(() => _steps.removeAt(e.key))
                  : null,
            )),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => setState(() =>
                  _steps.add(const UserRecipeStep(description: ''))),
              icon: const Icon(Icons.add, color: brandOrange, size: 18),
              label: const Text('Adicionar passo',
                  style: TextStyle(color: brandOrange)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: brandOrange),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),

            // Salvar
            GestureDetector(
              onTap: _save,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: brandGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Salvar receita',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _pickEmoji() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Escolha um ícone',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _emojis
                  .map((e) => GestureDetector(
                onTap: () {
                  setState(() => _emoji = e);
                  Navigator.pop(context);
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _emoji == e
                        ? brandOrangeLight
                        : const Color(0xFFF5F2EE),
                    borderRadius: BorderRadius.circular(10),
                    border: _emoji == e
                        ? Border.all(color: brandOrange, width: 2)
                        : null,
                  ),
                  child: Center(
                      child: Text(e,
                          style: const TextStyle(fontSize: 24))),
                ),
              ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) => Text(title,
      style: const TextStyle(
          fontWeight: FontWeight.bold, fontSize: 15, color: brandOrange));

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: textMedium),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );
}

// ── Tiles ─────────────────────────────────────────────────────────────────────

class _IngredientTile extends StatelessWidget {
  final String text;
  final VoidCallback onDelete;
  const _IngredientTile({required this.text, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.only(right: 10),
            decoration: const BoxDecoration(
                color: brandOrange, shape: BoxShape.circle),
          ),
          Expanded(
              child: Text(text, style: const TextStyle(fontSize: 14))),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close, size: 18, color: textMedium),
          ),
        ],
      ),
    );
  }
}

class _StepTile extends StatefulWidget {
  final int index;
  final UserRecipeStep step;
  final ValueChanged<UserRecipeStep> onChanged;
  final VoidCallback? onDelete;

  const _StepTile(
      {required this.index,
        required this.step,
        required this.onChanged,
        this.onDelete});

  @override
  State<_StepTile> createState() => _StepTileState();
}

class _StepTileState extends State<_StepTile> {
  late final TextEditingController _ctrl;
  late final TextEditingController _durationCtrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.step.description);
    _durationCtrl = TextEditingController(
        text: widget.step.durationMinutes?.toString() ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 10, top: 10),
            decoration: const BoxDecoration(
                color: brandOrange, shape: BoxShape.circle),
            child: Center(
              child: Text('${widget.index + 1}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _ctrl,
                  decoration: const InputDecoration(
                    hintText: 'Descreva o passo...',
                    hintStyle: TextStyle(color: textMedium),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (v) => widget.onChanged(
                      widget.step.copyWith(description: v)),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        size: 14, color: textMedium),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 60,
                      child: TextField(
                        controller: _durationCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          hintText: '0',
                          hintStyle:
                          TextStyle(color: textMedium, fontSize: 12),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(fontSize: 12),
                        onChanged: (v) {
                          final mins = int.tryParse(v);
                          widget.onChanged(mins == null || mins == 0
                              ? widget.step.copyWith(clearDuration: true)
                              : widget.step.copyWith(durationMinutes: mins));
                        },
                      ),
                    ),
                    const Text(' min',
                        style:
                        TextStyle(color: textMedium, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          if (widget.onDelete != null)
            GestureDetector(
              onTap: widget.onDelete,
              child: const Padding(
                padding: EdgeInsets.only(top: 8, left: 4),
                child:
                Icon(Icons.close, size: 18, color: textMedium),
              ),
            ),
        ],
      ),
    );
  }
}
