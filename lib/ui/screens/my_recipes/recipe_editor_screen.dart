import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  'Rápido', 'Air Fryer', 'Saudável', 'Vegano',
  'Proteico', 'Econômico', 'Fácil', 'Gourmet',
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
  String? _localImagePath; // caminho da foto escolhida da galeria ou câmera

  @override
  void initState() {
    super.initState();
    final r = widget.existing;
    _nameCtrl = TextEditingController(text: r?.name ?? '');
    _descCtrl = TextEditingController(text: r?.description ?? '');
    _emoji = r?.coverEmoji ?? '🍽';
    _isPublic = r?.isPublic ?? false;
    // Carrega foto local existente se houver
    if (r?.imageUrl != null && (r!.imageUrl!.startsWith('/') || r.imageUrl!.startsWith('file://'))) {
      _localImagePath = r.imageUrl!.replaceFirst('file://', '');
    }
    // Pré-preenche o autor com o usuário logado; edição livre caso queira apelido
    final currentUser = Supabase.instance.client.auth.currentUser;
    final defaultAuthor = r?.authorName?.isNotEmpty == true
        ? r!.authorName!
        : (currentUser?.userMetadata?['display_name'] as String? ??
            currentUser?.userMetadata?['full_name'] as String? ??
            currentUser?.email ??
            '');
    _authorCtrl = TextEditingController(text: defaultAuthor);
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
    _authorCtrl.dispose();
    super.dispose();
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
      imageUrl: _localImagePath, // foto local, null se não escolheu
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Receita não aprovada: ${result.reason ?? "tente novamente"}'),
          backgroundColor: Colors.red.shade700,
        ));
      }
    } catch (e) {
      debugPrint('PUBLISH ERROR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro ao publicar: $e'),
          backgroundColor: Colors.red.shade700,
        ));
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
    final subcats = allCategories
            .where((c) => c.name == _category)
            .firstOrNull
            ?.subcategories ??
        [];

    return Scaffold(
      backgroundColor: brandOrangeLight,
      appBar: AppBar(
        backgroundColor: brandOrangeLight,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: neutralDark, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.existing == null ? 'Nova Receita' : 'Editar Receita',
          style: const TextStyle(
            color: neutralDark,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        actions: const [],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          children: [
            // ── Título dinâmico ────────────────────────────────────────────
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _nameCtrl,
              builder: (_, val, __) {
                final name = val.text.trim().isEmpty
                    ? (widget.existing == null ? 'Nova Receita' : 'Receita')
                    : val.text;
                return Text(
                  name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: neutralDark,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            const Text(
              'Ajuste os detalhes para tornar sua receita perfeita.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF888888),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // ── NOME DA RECEITA ────────────────────────────────────────────
            _sectionLabel('NOME DA RECEITA'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameCtrl,
              decoration: _inputDec('Ex: Peito de Frango Grelhado'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Obrigatório' : null,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 14),

            // ── TOGGLE PÚBLICO ─────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isPublic ? 'Pública' : 'Privada',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: neutralDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isPublic
                              ? 'Visível para outros usuários na busca'
                              : 'Só você pode ver',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF888888),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isPublic,
                    onChanged: (v) => setState(() => _isPublic = v),
                    activeColor: Colors.white,
                    activeTrackColor: brandOrange,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xFFDDDDDD),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── AUTOR (só se pública) ──────────────────────────────────────
            if (_isPublic) ...[
              _sectionLabel('AUTOR'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _authorCtrl,
                decoration: _inputDec('Seu nome ou perfil'),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    _isPublic && (v == null || v.trim().isEmpty)
                        ? 'Obrigatório para receitas públicas'
                        : null,
              ),
              const SizedBox(height: 14),
            ],

            // ── CATEGORIA / SUBCATEGORIA (lado a lado) ─────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('CATEGORIA'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _category,
                        isExpanded: true,
                        decoration: _inputDec('').copyWith(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down,
                            size: 20, color: Color(0xFF888888)),
                        style: const TextStyle(
                            fontSize: 13, color: neutralDark),
                        items: _categories
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() {
                          _category = v;
                          _subcategory = null;
                        }),
                        validator: (v) => v == null ? 'Selecione' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('SUBCATEGORIA'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _subcategory,
                        isExpanded: true,
                        decoration: _inputDec('').copyWith(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down,
                            size: 20, color: Color(0xFF888888)),
                        style: const TextStyle(
                            fontSize: 13, color: neutralDark),
                        items: subcats.isEmpty
                            ? [
                                const DropdownMenuItem(
                                    value: null, child: Text('—'))
                              ]
                            : [
                                const DropdownMenuItem(
                                    value: null, child: Text('Nenhuma')),
                                ...subcats.map((s) =>
                                    DropdownMenuItem(value: s, child: Text(s))),
                              ],
                        onChanged: subcats.isEmpty
                            ? null
                            : (v) => setState(() => _subcategory = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── TAGS SUGERIDAS ─────────────────────────────────────────────
            _sectionLabel('TAGS SUGERIDAS'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tagOptions.map((tag) {
                final selected = _tags.contains(tag);
                return GestureDetector(
                  onTap: () => setState(() =>
                      selected ? _tags.remove(tag) : _tags.add(tag)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected ? brandOrange : Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: selected
                            ? brandOrange
                            : const Color(0xFFDDDDDD),
                      ),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: selected
                            ? Colors.white
                            : const Color(0xFF555555),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── INGREDIENTES ───────────────────────────────────────────────
            Row(
              children: [
                _sectionLabel('INGREDIENTES'),
                const Spacer(),
                if (_ingredients.isNotEmpty)
                  Text(
                    '${_ingredients.length} ${_ingredients.length == 1 ? 'item adicionado' : 'itens adicionados'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: brandOrange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ingredientCtrl,
                    decoration: _inputDec('Ex: 2 xícaras de farinha'),
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
                    decoration: BoxDecoration(
                      color: brandOrange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 22),
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

            // ── MODO DE PREPARO ────────────────────────────────────────────
            _sectionLabel('MODO DE PREPARO'),
            const SizedBox(height: 10),
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
            GestureDetector(
              onTap: () => setState(
                  () => _steps.add(const UserRecipeStep(description: ''))),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFCCCCCC),
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline,
                        size: 18, color: Color(0xFF888888)),
                    SizedBox(width: 8),
                    Text(
                      'Adicionar Passo',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF888888),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── CAPA DA RECEITA ────────────────────────────────────────────
            _sectionLabel('CAPA DA RECEITA'),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickCover,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAE7EA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    // Foto ou emoji
                    if (_localImagePath != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(_localImagePath!),
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Center(
                        child: Text(_emoji,
                            style: const TextStyle(fontSize: 72)),
                      ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(16)),
                          color: Colors.black.withOpacity(0.32),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined,
                                color: Colors.white, size: 17),
                            SizedBox(width: 6),
                            Text(
                              'Alterar Capa',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── SALVAR ─────────────────────────────────────────────────────
            GestureDetector(
              onTap: _save,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: brandGradient,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: brandOrange.withOpacity(0.30),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Salvar receita',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCover() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDDDDD),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Capa da receita',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
              const SizedBox(height: 4),
              const Text('Escolha como quer personalizar',
                  style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
              const SizedBox(height: 20),
              _coverOption(
                icon: Icons.photo_library_outlined,
                label: 'Galeria de fotos',
                subtitle: 'Escolha uma imagem do seu álbum',
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final file = await picker.pickImage(
                      source: ImageSource.gallery, imageQuality: 80);
                  if (file != null) {
                    setState(() {
                      _localImagePath = file.path;
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              _coverOption(
                icon: Icons.camera_alt_outlined,
                label: 'Câmera',
                subtitle: 'Tire uma foto agora',
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final file = await picker.pickImage(
                      source: ImageSource.camera, imageQuality: 80);
                  if (file != null) {
                    setState(() {
                      _localImagePath = file.path;
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              _coverOption(
                icon: Icons.emoji_emotions_outlined,
                label: 'Usar ícone emoji',
                subtitle: 'Escolha um emoji como capa',
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _localImagePath = null);
                  _pickEmoji();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _coverOption({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F5F2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: brandPrimaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: brandPrimary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF1C1C1E))),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF888888))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: Color(0xFFCCCCCC), size: 20),
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

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF888888),
          letterSpacing: 1.2,
        ),
      );

  InputDecoration _inputDec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
        filled: true,
        fillColor: Colors.white,
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
          borderSide: const BorderSide(color: brandOrange, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );
}

// ── Tiles ──────────────────────────────────────────────────────────────────────

class _IngredientTile extends StatelessWidget {
  final String text;
  final VoidCallback onDelete;
  const _IngredientTile({required this.text, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 10),
            decoration: const BoxDecoration(
                color: brandOrange, shape: BoxShape.circle),
          ),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 14, color: neutralDark))),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close, size: 17, color: Color(0xFFAAAAAA)),
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

  const _StepTile({
    required this.index,
    required this.step,
    required this.onChanged,
    this.onDelete,
  });

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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            margin: const EdgeInsets.only(right: 12, top: 2),
            decoration: const BoxDecoration(
              color: Color(0xFFEEEEEE),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${widget.index + 1}',
                style: const TextStyle(
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
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
                    hintStyle: TextStyle(color: Color(0xFFAAAAAA)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (v) =>
                      widget.onChanged(widget.step.copyWith(description: v)),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        size: 13, color: Color(0xFFAAAAAA)),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 48,
                      child: TextField(
                        controller: _durationCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(
                              color: Color(0xFFAAAAAA), fontSize: 12),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF666666)),
                        onChanged: (v) {
                          final mins = int.tryParse(v);
                          widget.onChanged(mins == null || mins == 0
                              ? widget.step.copyWith(clearDuration: true)
                              : widget.step.copyWith(durationMinutes: mins));
                        },
                      ),
                    ),
                    const Text(' min',
                        style: TextStyle(
                            color: Color(0xFFAAAAAA), fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          if (widget.onDelete != null)
            GestureDetector(
              onTap: widget.onDelete,
              child: const Padding(
                padding: EdgeInsets.only(top: 4, left: 4),
                child: Icon(Icons.close, size: 17, color: Color(0xFFAAAAAA)),
              ),
            ),
        ],
      ),
    );
  }
}
