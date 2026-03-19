import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers.dart';
import '../../../model/fridge_item.dart';
import '../../../model/shopping_item.dart';
import '../../theme/app_colors.dart';

class FridgeScreen extends ConsumerStatefulWidget {
  const FridgeScreen({super.key});

  @override
  ConsumerState<FridgeScreen> createState() => _FridgeScreenState();
}

class _FridgeScreenState extends ConsumerState<FridgeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fridgeProvider);

    return Scaffold(
      backgroundColor: neutralBackground,
      floatingActionButton: ListenableBuilder(
        listenable: _tabController,
        builder: (context, _) {
          if (_tabController.index != 0) return const SizedBox.shrink();
          return FloatingActionButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const _AddFridgeItemSheet(),
            ),
            backgroundColor: brandTertiary,
            child: const Icon(Icons.add, color: Colors.white),
          );
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              bottom: 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Minha Geladeira 🧊',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Organize o que você tem em casa',
                    style: TextStyle(color: neutralMedium)),
              ],
            ),
          ),

          // Alerta de validade
          if (state.expiringItems.isNotEmpty)
            _ExpiryBanner(count: state.expiringItems.length),

          // TabBar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: neutralSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: brandTertiary,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: neutralMedium,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: '🧊  Geladeira'),
                  Tab(text: '🛒  Compras'),
                ],
              ),
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _FridgeTab(state: state),
                _ShoppingTab(state: state),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Banner de alerta ─────────────────────────────────────────────────────────

class _ExpiryBanner extends StatelessWidget {
  final int count;
  const _ExpiryBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B), width: 1),
      ),
      child: Row(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$count item${count > 1 ? 'ns' : ''} vencendo em breve ou já vencido${count > 1 ? 's' : ''}',
              style: const TextStyle(
                  color: Color(0xFF92400E), fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Aba Geladeira ────────────────────────────────────────────────────────────

class _FridgeTab extends ConsumerWidget {
  final dynamic state;
  const _FridgeTab({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fridgeState = ref.watch(fridgeProvider);

    return fridgeState.items.isEmpty
        ? _EmptyFridge(
            quickItems: fridgeState.quickItems,
            onAddTap: () => _showAddItemSheet(context, ref),
          )
        : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // Modo rápido
              if (fridgeState.quickItems.isNotEmpty) ...[
                _QuickAddRow(
                  quickItems: fridgeState.quickItems,
                  onTap: (name) => _showAddItemSheet(context, ref, initialName: name),
                ),
                const SizedBox(height: 8),
              ],

              // Contagem
              Text(
                '${fridgeState.items.length} ${fridgeState.items.length != 1 ? 'itens' : 'item'} na geladeira',
                style: const TextStyle(color: neutralMedium, fontSize: 12),
              ),
              const SizedBox(height: 12),

              // Lista agrupada por categoria
              ...fridgeState.itemsByCategory.entries.map((entry) {
                return _CategorySection(
                  category: entry.key,
                  items: entry.value,
                  onRemove: (id) => ref.read(fridgeProvider.notifier).removeItem(id),
                );
              }),
              const SizedBox(height: 80),
            ],
          );
  }

  void _showAddItemSheet(BuildContext context, WidgetRef ref, {String? initialName}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddFridgeItemSheet(initialName: initialName),
    );
  }
}

class _EmptyFridge extends StatelessWidget {
  final List<String> quickItems;
  final VoidCallback onAddTap;
  const _EmptyFridge({required this.quickItems, required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (quickItems.isNotEmpty) ...[
            _QuickAddRow(
              quickItems: quickItems,
              onTap: (name) => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => _AddFridgeItemSheet(initialName: name),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: neutralSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('🛒', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                const Text('Sua geladeira está vazia',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                  'Adicione ingredientes para receber sugestões de receitas personalizadas',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: neutralMedium),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: onAddTap,
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar ingrediente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandTertiary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAddRow extends ConsumerWidget {
  final List<String> quickItems;
  final void Function(String name) onTap;
  const _QuickAddRow({required this.quickItems, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Adicionados frequentemente',
            style: TextStyle(fontSize: 12, color: neutralMedium)),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: quickItems
                .map((name) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text('+ $name'),
                        onPressed: () => onTap(name),
                        backgroundColor: brandTertiaryLight,
                        labelStyle: const TextStyle(
                            color: brandTertiary, fontWeight: FontWeight.w500),
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  final FridgeCategory category;
  final List<FridgeItem> items;
  final void Function(String id) onRemove;

  const _CategorySection({
    required this.category,
    required this.items,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            '${category.emoji}  ${category.label}',
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13, color: neutralMedium),
          ),
        ),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _FridgeItemCard(item: item, onRemove: () => onRemove(item.id)),
            )),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _FridgeItemCard extends StatelessWidget {
  final FridgeItem item;
  final VoidCallback onRemove;
  const _FridgeItemCard({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: neutralSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(item.name,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500)),
                    ),
                    if (item.quantityLabel != null)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: brandTertiaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.quantityLabel!,
                          style: const TextStyle(
                              fontSize: 12,
                              color: brandTertiary,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
                if (item.expiresAt != null) ...[
                  const SizedBox(height: 2),
                  _ExpiryBadge(item: item),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, color: neutralMedium, size: 18),
          ),
        ],
      ),
    );
  }
}

class _ExpiryBadge extends StatelessWidget {
  final FridgeItem item;
  const _ExpiryBadge({required this.item});

  @override
  Widget build(BuildContext context) {
    final days = item.daysUntilExpiry!;

    Color color;
    String text;

    if (item.isExpired) {
      color = const Color(0xFFDC2626);
      text = 'Vencido há ${days.abs()} dia${days.abs() != 1 ? 's' : ''}';
    } else if (item.expiresSoon) {
      color = const Color(0xFFD97706);
      text = days == 0 ? 'Vence hoje' : 'Vence em $days dia${days != 1 ? 's' : ''}';
    } else {
      color = const Color(0xFF059669);
      text = 'Vence em $days dias';
    }

    return Row(
      children: [
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 11, color: color)),
      ],
    );
  }
}

// ── Bottom sheet: adicionar item à geladeira ─────────────────────────────────

class _AddFridgeItemSheet extends ConsumerStatefulWidget {
  final String? initialName;
  const _AddFridgeItemSheet({this.initialName});

  @override
  ConsumerState<_AddFridgeItemSheet> createState() => _AddFridgeItemSheetState();
}

class _AddFridgeItemSheetState extends ConsumerState<_AddFridgeItemSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _quantityCtrl;
  FridgeCategory _category = FridgeCategory.other;
  late FridgeUnit _unit;
  DateTime? _expiresAt;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName ?? '');
    _quantityCtrl = TextEditingController();
    _unit = _category.defaultUnit;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

  void _onCategoryChanged(FridgeCategory cat) {
    setState(() {
      _category = cat;
      // Só troca a unidade se a atual não for válida para a nova categoria
      if (!cat.suggestedUnits.contains(_unit)) {
        _unit = cat.defaultUnit;
      }
    });
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final qty = double.tryParse(_quantityCtrl.text.trim().replaceAll(',', '.'));
    ref.read(fridgeProvider.notifier).addItem(
          name,
          _category,
          expiresAt: _expiresAt,
          quantity: qty,
          unit: qty != null ? _unit : null,
        );
    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _expiresAt = picked);
  }

  @override
  Widget build(BuildContext context) {
    final suggestedUnits = _category.suggestedUnits;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: neutralLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Adicionar à geladeira',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Nome
            TextField(
              controller: _nameCtrl,
              autofocus: widget.initialName == null,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Ex: Leite, Frango, Ovos...',
                hintStyle: const TextStyle(color: neutralLight),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: brandTertiary),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),

            // Quantidade + Unidade
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'Quantidade (opcional)',
                      hintStyle: const TextStyle(color: neutralLight, fontSize: 13),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: brandTertiary),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Seletor de unidade
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: suggestedUnits.map((u) {
                      final selected = _unit == u;
                      return GestureDetector(
                        onTap: () => setState(() => _unit = u),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 2, vertical: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: selected ? brandTertiary : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            u.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : neutralMedium,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Categorias
            const Text('Categoria',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: FridgeCategory.values
                    .map((cat) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text('${cat.emoji} ${cat.label}'),
                            selected: _category == cat,
                            onSelected: (_) => _onCategoryChanged(cat),
                            selectedColor: brandTertiary,
                            labelStyle: TextStyle(
                              color: _category == cat ? Colors.white : neutralMedium,
                              fontSize: 12,
                            ),
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Validade
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 18, color: neutralMedium),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _expiresAt == null
                            ? 'Data de validade (opcional)'
                            : 'Vence em ${_expiresAt!.day.toString().padLeft(2, '0')}/${_expiresAt!.month.toString().padLeft(2, '0')}/${_expiresAt!.year}',
                        style: TextStyle(
                          color: _expiresAt == null ? neutralLight : neutralDark,
                        ),
                      ),
                    ),
                    if (_expiresAt != null)
                      GestureDetector(
                        onTap: () => setState(() => _expiresAt = null),
                        child: const Icon(Icons.close,
                            size: 16, color: neutralMedium),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Botão
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandTertiary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Adicionar',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Aba Compras ──────────────────────────────────────────────────────────────

class _ShoppingTab extends ConsumerWidget {
  final dynamic state;
  const _ShoppingTab({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fridgeState = ref.watch(fridgeProvider);
    final shopping = fridgeState.shoppingList;
    final checkedCount = shopping.where((e) => e.isChecked).length;

    return Column(
      children: [
        // Botão adicionar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const _AddShoppingItemSheet(),
              ),
              icon: const Icon(Icons.add, color: brandTertiary),
              label: const Text('Adicionar item',
                  style: TextStyle(color: brandTertiary)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: brandTertiary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),

        // Botão mover para geladeira
        if (checkedCount > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    ref.read(fridgeProvider.notifier).moveCheckedToFridge(),
                icon: const Icon(Icons.kitchen_outlined),
                label: Text(
                    'Adicionar $checkedCount item${checkedCount != 1 ? 'ns' : ''} à geladeira'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

        // Lista
        Expanded(
          child: shopping.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🛒', style: TextStyle(fontSize: 40)),
                      SizedBox(height: 8),
                      Text('Lista de compras vazia',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Adicione itens que você precisa comprar',
                          style: TextStyle(color: neutralMedium)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: shopping.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final item = shopping[i];
                    return _ShoppingItemCard(
                      item: item,
                      onToggle: () =>
                          ref.read(fridgeProvider.notifier).toggleShoppingItem(item.id),
                      onRemove: () =>
                          ref.read(fridgeProvider.notifier).removeShoppingItem(item.id),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ShoppingItemCard extends StatelessWidget {
  final ShoppingItem item;
  final VoidCallback onToggle;
  final VoidCallback onRemove;
  const _ShoppingItemCard(
      {required this.item, required this.onToggle, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: neutralSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              item.isChecked
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: item.isChecked ? brandTertiary : neutralLight,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Text(item.category.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.name,
              style: TextStyle(
                fontSize: 15,
                decoration:
                    item.isChecked ? TextDecoration.lineThrough : null,
                color: item.isChecked ? neutralMedium : neutralDark,
              ),
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, color: neutralMedium, size: 18),
          ),
        ],
      ),
    );
  }
}

// ── Bottom sheet: adicionar item à lista de compras ──────────────────────────

class _AddShoppingItemSheet extends ConsumerStatefulWidget {
  const _AddShoppingItemSheet();

  @override
  ConsumerState<_AddShoppingItemSheet> createState() =>
      _AddShoppingItemSheetState();
}

class _AddShoppingItemSheetState extends ConsumerState<_AddShoppingItemSheet> {
  final _nameCtrl = TextEditingController();
  FridgeCategory _category = FridgeCategory.other;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    ref.read(fridgeProvider.notifier).addShoppingItem(name, _category);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: neutralLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Adicionar à lista de compras',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: 'Ex: Leite, Arroz, Tomate...',
                hintStyle: const TextStyle(color: neutralLight),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: brandTertiary),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Categoria',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: FridgeCategory.values
                    .map((cat) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text('${cat.emoji} ${cat.label}'),
                            selected: _category == cat,
                            onSelected: (_) => setState(() => _category = cat),
                            selectedColor: brandTertiary,
                            labelStyle: TextStyle(
                              color: _category == cat ? Colors.white : neutralMedium,
                              fontSize: 12,
                            ),
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandTertiary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Adicionar',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
