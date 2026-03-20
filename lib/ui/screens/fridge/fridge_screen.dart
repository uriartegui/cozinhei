import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../providers.dart';
import '../../../model/fridge_item.dart';
import '../../../model/shopping_item.dart';
import '../../../viewmodel/house_notifier.dart';
import '../../theme/app_colors.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────

const _kPageBg       = brandOrangeLight;
const _kCardBg       = Colors.white;
const _kBorderColor  = Color(0xFFE8E8ED);
const _kRadius       = 14.0;
const _kSeparator    = Color(0xFFF2F2F7);
const _kBlue         = Color(0xFF007AFF); // iOS blue
const _kFieldBg      = Color(0xFFF2F2F7); // iOS input background

const _kCardShadow = [
  BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
];

// ── House menu button ─────────────────────────────────────────────────────────

class _HouseMenuButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final house = ref.watch(houseProvider);
    final notifier = ref.read(houseProvider.notifier);

    return PopupMenuButton<String>(
      icon: const Icon(Icons.settings_outlined, color: neutralDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (value) async {
        if (value == 'rename') {
          _showRenameDialog(context, notifier, house.houseName ?? '');
        } else if (value == 'invite') {
          _showInviteSheet(context, house.inviteCode ?? '');
        } else if (value == 'delete') {
          _showDeleteDialog(context, notifier);
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'invite',
          child: Row(children: [
            Icon(Icons.person_add_outlined, size: 20, color: _kBlue),
            SizedBox(width: 12),
            Text('Convidar para Geladeira'),
          ]),
        ),
        const PopupMenuItem(
          value: 'rename',
          child: Row(children: [
            Icon(Icons.edit_outlined, size: 20),
            SizedBox(width: 12),
            Text('Renomear Geladeira'),
          ]),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete_outline, size: 20, color: Colors.red),
            SizedBox(width: 12),
            Text('Excluir Geladeira', style: TextStyle(color: Colors.red)),
          ]),
        ),
      ],
    );
  }

  void _showRenameDialog(BuildContext context, notifier, String currentName) {
    final ctrl = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Renomear Geladeira', style: TextStyle(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: _kFieldBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kBlue, width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                notifier.renameHouse(ctrl.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Salvar', style: TextStyle(color: _kBlue, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showInviteSheet(BuildContext context, String code) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Convidar para Geladeira',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text(
              'Compartilhe o código abaixo com quem quiser convidar',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: _kFieldBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                code,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 8,
                  color: _kBlue,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: code));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Código copiado!')),
                      );
                    },
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _kFieldBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Copiar',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Share.share(
                        'Entre na minha geladeira no app Cozinhei! Use o código: $code',
                      );
                    },
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _kBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Compartilhar',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Excluir Geladeira', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
          'Todos os itens e a lista de compras serão removidos. Essa ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await notifier.deleteHouse();
            },
            child: const Text('Excluir',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

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
      backgroundColor: _kPageBg,
      floatingActionButton: ListenableBuilder(
        listenable: _tabController,
        builder: (context, _) {
          final idx = _tabController.index;
          final isCompras = idx == 1;
          return FloatingActionButton(
            key: ValueKey(isCompras),
            onPressed: isCompras
                ? () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const _AddShoppingItemSheet(),
                    )
                : () => _openAddFridge(context),
            backgroundColor: _kBlue,
            elevation: 3,
            child: const Icon(Icons.add, color: Colors.white),
          );
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20,
              right: 20,
              bottom: 4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ref.watch(houseProvider).houseName ?? 'Minha Geladeira',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                              color: neutralDark,
                            ),
                      ),
                    ),
                    _HistoryButton(),
                    _HouseMenuButton(),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Organize o que você tem em casa',
                  style: TextStyle(
                    fontSize: 15,
                    color: neutralMedium,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),

          // ── Alerta de validade ───────────────────────────────────────────
          if (state.expiringItems.isNotEmpty)
            _ExpiryBanner(count: state.expiringItems.length),

          const SizedBox(height: 12),

          // ── TabBar ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: _kSeparator,
                borderRadius: BorderRadius.circular(_kRadius),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: _kBlue,
                  borderRadius: BorderRadius.circular(_kRadius - 2),
                  boxShadow: [
                    BoxShadow(
                      color: _kBlue.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(3),
                labelColor: Colors.white,
                unselectedLabelColor: neutralMedium,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: -0.1,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                dividerColor: Colors.transparent,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                tabs: const [
                  Tab(text: 'Geladeira'),
                  Tab(text: 'Compras'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Tab content ──────────────────────────────────────────────────
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

  void _openAddFridge(BuildContext context, {String? initialName}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddFridgeItemSheet(initialName: initialName),
    );
  }
}

// ── Expiry banner ─────────────────────────────────────────────────────────────

class _ExpiryBanner extends StatelessWidget {
  final int count;
  const _ExpiryBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EC),
        borderRadius: BorderRadius.circular(_kRadius),
        border: Border.all(color: const Color(0xFFFFD60A).withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 15)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$count item${count > 1 ? 's' : ''} vencendo em breve',
              style: const TextStyle(
                color: Color(0xFF92400E),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Aba Geladeira ─────────────────────────────────────────────────────────────

class _FridgeTab extends ConsumerWidget {
  final dynamic state;
  const _FridgeTab({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fridgeState = ref.watch(fridgeProvider);

    return fridgeState.items.isEmpty
        ? _EmptyFridge(
            quickItems: fridgeState.quickItems,
            onAddTap: () => _openAddSheet(context),
            onQuickTap: (name) => _openAddSheet(context, initialName: name),
          )
        : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              // Contagem
              Text(
                '${fridgeState.items.length} ${fridgeState.items.length != 1 ? 'itens' : 'item'} na geladeira',
                style: const TextStyle(
                  color: neutralMedium,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 14),

              // Lista agrupada
              ...fridgeState.itemsByCategory.entries.map((entry) {
                return _CategorySection(
                  category: entry.key,
                  items: entry.value,
                  onRemove: (id) =>
                      ref.read(fridgeProvider.notifier).removeItem(id),
                  onEdit: (item) => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => _EditFridgeItemSheet(item: item),
                  ),
                );
              }),
              const SizedBox(height: 100),
            ],
          );
  }

  void _openAddSheet(BuildContext context, {WidgetRef? ref, String? initialName}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddFridgeItemSheet(initialName: initialName),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyFridge extends StatelessWidget {
  final List<String> quickItems;
  final VoidCallback onAddTap;
  final void Function(String) onQuickTap;

  const _EmptyFridge({
    required this.quickItems,
    required this.onAddTap,
    required this.onQuickTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _kBlue.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.kitchen_outlined,
              size: 40,
              color: _kBlue,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Sua geladeira está vazia',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: neutralDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Toque em + para adicionar ingredientes',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: neutralMedium,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick add ─────────────────────────────────────────────────────────────────

class _QuickAddRow extends ConsumerWidget {
  final List<String> quickItems;
  final void Function(String name) onTap;
  const _QuickAddRow({required this.quickItems, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ADICIONADOS FREQUENTEMENTE',
          style: TextStyle(
            fontSize: 11,
            color: neutralLight,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: quickItems
                .map((name) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => onTap(name),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: brandTertiary.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.add,
                                  size: 13,
                                  color: brandTertiary.withValues(alpha: 0.9)),
                              const SizedBox(width: 4),
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: brandTertiary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

// ── Category section ──────────────────────────────────────────────────────────

class _CategorySection extends StatelessWidget {
  final FridgeCategory category;
  final List<FridgeItem> items;
  final void Function(String id) onRemove;
  final void Function(FridgeItem item) onEdit;

  const _CategorySection({
    required this.category,
    required this.items,
    required this.onRemove,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(category.emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                category.label.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: neutralMedium,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
        ),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _FridgeItemCard(
                item: item,
                onRemove: () => onRemove(item.id),
                onEdit: () => onEdit(item),
              ),
            )),
        const SizedBox(height: 12),
      ],
    );
  }
}

// ── Item card ─────────────────────────────────────────────────────────────────

class _FridgeItemCard extends StatelessWidget {
  final FridgeItem item;
  final VoidCallback onRemove;
  final VoidCallback onEdit;
  const _FridgeItemCard({required this.item, required this.onRemove, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(_kRadius),
        border: Border.all(color: _kBorderColor),
        boxShadow: _kCardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                    color: neutralDark,
                  ),
                ),
                if (item.expiresAt != null) ...[
                  const SizedBox(height: 4),
                  _ExpiryBadge(item: item),
                ],
              ],
            ),
          ),
          if (item.quantityLabel != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: brandTertiary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.quantityLabel!,
                style: const TextStyle(
                  fontSize: 12,
                  color: brandTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _kSeparator,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: neutralMedium, size: 15),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

// ── Expiry badge ──────────────────────────────────────────────────────────────

class _ExpiryBadge extends StatelessWidget {
  final FridgeItem item;
  const _ExpiryBadge({required this.item});

  @override
  Widget build(BuildContext context) {
    final days = item.daysUntilExpiry!;

    Color color;
    String text;

    if (item.isExpired) {
      color = const Color(0xFFFF3B30);
      text = 'Vencido há ${days.abs()} dia${days.abs() != 1 ? 's' : ''}';
    } else if (item.expiresSoon) {
      color = const Color(0xFFFF9500);
      text = days == 0 ? 'Vence hoje' : 'Vence em $days dia${days != 1 ? 's' : ''}';
    } else {
      color = const Color(0xFF34C759);
      text = 'Vence em $days dias';
    }

    return Row(
      children: [
        Icon(Icons.circle, size: 7, color: color),
        const SizedBox(width: 5),
        Text(text,
            style: TextStyle(
                fontSize: 12, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ── Bottom sheet: adicionar à geladeira ───────────────────────────────────────

class _AddFridgeItemSheet extends ConsumerStatefulWidget {
  final String? initialName;
  const _AddFridgeItemSheet({this.initialName});

  @override
  ConsumerState<_AddFridgeItemSheet> createState() =>
      _AddFridgeItemSheetState();
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
      if (!cat.suggestedUnits.contains(_unit)) _unit = cat.defaultUnit;
    });
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final qty =
        double.tryParse(_quantityCtrl.text.trim().replaceAll(',', '.'));
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
      initialDate: _expiresAt ?? DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: _kBlue,
                surface: brandOrangeLight,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _expiresAt = picked);
  }

  @override
  Widget build(BuildContext context) {
    final suggestedUnits = _category.suggestedUnits;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: _kBorderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Adicionar à geladeira',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: neutralDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Preencha as informações do ingrediente',
              style: TextStyle(
                fontSize: 13,
                color: neutralLight,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(height: 20),

            // Nome
            _StyledField(
              controller: _nameCtrl,
              hintText: 'Ex: Leite, Frango, Ovos…',
              autofocus: widget.initialName == null,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),

            // Quantidade + Unidade
            Row(
              children: [
                Expanded(
                  child: _StyledField(
                    controller: _quantityCtrl,
                    hintText: 'Quantidade (opcional)',
                    hintFontSize: 13,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                  ),
                ),
                const SizedBox(width: 10),
                _UnitPicker(
                  units: suggestedUnits,
                  selected: _unit,
                  onSelect: (u) => setState(() => _unit = u),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Categoria
            const Text(
              'Categoria',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: neutralMedium,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: FridgeCategory.values
                    .map((cat) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _CategoryChip(
                            cat: cat,
                            selected: _category == cat,
                            onTap: () => _onCategoryChanged(cat),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  color: _kFieldBg,
                  borderRadius: BorderRadius.circular(_kRadius),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 17,
                      color: _expiresAt != null ? _kBlue : neutralLight,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _expiresAt == null
                            ? 'Data de validade (opcional)'
                            : 'Vence em ${_expiresAt!.day.toString().padLeft(2, '0')}/${_expiresAt!.month.toString().padLeft(2, '0')}/${_expiresAt!.year}',
                        style: TextStyle(
                          fontSize: 15,
                          color: _expiresAt == null
                              ? neutralLight
                              : neutralDark,
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
            const SizedBox(height: 24),

            // Botão
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    letterSpacing: -0.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_kRadius),
                  ),
                ),
                child: const Text('Adicionar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom sheet: mover compras para geladeira ───────────────────────────────

class _MoveToFridgeSheet extends ConsumerStatefulWidget {
  final List<ShoppingItem> items;
  const _MoveToFridgeSheet({required this.items});

  @override
  ConsumerState<_MoveToFridgeSheet> createState() => _MoveToFridgeSheetState();
}

class _MoveToFridgeSheetState extends ConsumerState<_MoveToFridgeSheet> {
  late final List<TextEditingController> _qtyCtrl;
  late final List<FridgeUnit> _units;
  late final List<DateTime?> _expiries;

  @override
  void initState() {
    super.initState();
    _qtyCtrl = widget.items.map((_) => TextEditingController()).toList();
    _units = widget.items.map((i) => i.category.defaultUnit).toList();
    _expiries = List<DateTime?>.filled(widget.items.length, null);
  }

  @override
  void dispose() {
    for (final c in _qtyCtrl) c.dispose();
    super.dispose();
  }

  Future<void> _pickDate(int index) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiries[index] ?? DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: _kBlue,
                surface: brandOrangeLight,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _expiries[index] = picked);
  }

  void _submit() {
    final notifier = ref.read(fridgeProvider.notifier);
    for (int i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      final qty = double.tryParse(_qtyCtrl[i].text.trim().replaceAll(',', '.'));
      notifier.moveShoppingItemToFridge(
        item.id,
        item.name,
        item.category,
        expiresAt: _expiries[i],
        quantity: qty,
        unit: qty != null ? _units[i] : null,
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Cabeçalho fixo ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: _kBorderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Adicionar à geladeira',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: neutralDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Preencha os detalhes de ${widget.items.length} ${widget.items.length == 1 ? 'item' : 'itens'}',
                  style: const TextStyle(fontSize: 13, color: neutralLight),
                ),
              ],
            ),
          ),

          // ── Lista rolável ─────────────────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(widget.items.length, (i) {
                  final item = widget.items[i];
                  final expiry = _expiries[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(item.category.emoji,
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: neutralDark,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _StyledField(
                                controller: _qtyCtrl[i],
                                hintText: 'Quantidade (opcional)',
                                hintFontSize: 13,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _UnitPicker(
                              units: item.category.suggestedUnits,
                              selected: _units[i],
                              onSelect: (u) => setState(() => _units[i] = u),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _pickDate(i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                            decoration: BoxDecoration(
                              color: _kFieldBg,
                              borderRadius: BorderRadius.circular(_kRadius),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 15,
                                  color: expiry != null ? _kBlue : neutralLight,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    expiry == null
                                        ? 'Validade (opcional)'
                                        : 'Vence em ${expiry.day.toString().padLeft(2, '0')}/${expiry.month.toString().padLeft(2, '0')}/${expiry.year}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: expiry == null ? neutralLight : neutralDark,
                                    ),
                                  ),
                                ),
                                if (expiry != null)
                                  GestureDetector(
                                    onTap: () => setState(() => _expiries[i] = null),
                                    child: const Icon(Icons.close, size: 14, color: neutralMedium),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        if (i < widget.items.length - 1) ...[
                          const SizedBox(height: 16),
                          const Divider(color: _kBorderColor, height: 1),
                        ],
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),

          // ── Botão fixo ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    letterSpacing: -0.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_kRadius),
                  ),
                ),
                child: Text(
                  'Adicionar ${widget.items.length} ${widget.items.length == 1 ? 'item' : 'itens'} à geladeira',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom sheet: editar item da geladeira ────────────────────────────────────

class _EditFridgeItemSheet extends ConsumerStatefulWidget {
  final FridgeItem item;
  const _EditFridgeItemSheet({required this.item});

  @override
  ConsumerState<_EditFridgeItemSheet> createState() =>
      _EditFridgeItemSheetState();
}

class _EditFridgeItemSheetState extends ConsumerState<_EditFridgeItemSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _quantityCtrl;
  late FridgeCategory _category;
  late FridgeUnit _unit;
  DateTime? _expiresAt;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.item.name);
    _quantityCtrl = TextEditingController(
      text: widget.item.quantity != null
          ? widget.item.quantity!.toStringAsFixed(
              widget.item.quantity! % 1 == 0 ? 0 : 1)
          : '',
    );
    _category = widget.item.category;
    _unit = widget.item.unit ?? widget.item.category.defaultUnit;
    _expiresAt = widget.item.expiresAt;
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
      if (!cat.suggestedUnits.contains(_unit)) _unit = cat.defaultUnit;
    });
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final qty =
        double.tryParse(_quantityCtrl.text.trim().replaceAll(',', '.'));
    ref.read(fridgeProvider.notifier).updateItem(
          widget.item.copyWith(
            name: name,
            category: _category,
            expiresAt: _expiresAt,
            clearExpiry: _expiresAt == null,
            quantity: qty,
            unit: qty != null ? _unit : null,
            clearQuantity: qty == null,
          ),
        );
    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: _kBlue,
                surface: brandOrangeLight,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _expiresAt = picked);
  }

  @override
  Widget build(BuildContext context) {
    final suggestedUnits = _category.suggestedUnits;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: _kBorderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Editar ingrediente',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: neutralDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Altere as informações do ingrediente',
              style: TextStyle(
                fontSize: 13,
                color: neutralLight,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(height: 20),
            _StyledField(
              controller: _nameCtrl,
              hintText: 'Nome do ingrediente',
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StyledField(
                    controller: _quantityCtrl,
                    hintText: 'Quantidade (opcional)',
                    hintFontSize: 13,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 10),
                _UnitPicker(
                  units: suggestedUnits,
                  selected: _unit,
                  onSelect: (u) => setState(() => _unit = u),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Categoria',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: neutralMedium,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: FridgeCategory.values
                    .map((cat) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _CategoryChip(
                            cat: cat,
                            selected: _category == cat,
                            onTap: () => _onCategoryChanged(cat),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  color: _kFieldBg,
                  borderRadius: BorderRadius.circular(_kRadius),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 17,
                      color: _expiresAt != null ? _kBlue : neutralLight,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _expiresAt == null
                            ? 'Data de validade (opcional)'
                            : 'Vence em ${_expiresAt!.day.toString().padLeft(2, '0')}/${_expiresAt!.month.toString().padLeft(2, '0')}/${_expiresAt!.year}',
                        style: TextStyle(
                          fontSize: 15,
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
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    letterSpacing: -0.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_kRadius),
                  ),
                ),
                child: const Text('Salvar alterações'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers de UI do sheet ────────────────────────────────────────────────────

class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final double hintFontSize;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final VoidCallback? onSubmitted;

  const _StyledField({
    required this.controller,
    required this.hintText,
    this.hintFontSize = 15,
    this.autofocus = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(_kRadius)),
      borderSide: BorderSide.none,
    );
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      onSubmitted: onSubmitted != null ? (_) => onSubmitted!() : null,
      style: const TextStyle(fontSize: 15, color: neutralDark),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: neutralLight, fontSize: hintFontSize),
        border: border,
        enabledBorder: border,
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(_kRadius)),
          borderSide: BorderSide(color: _kBlue, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        filled: true,
        fillColor: _kFieldBg,
      ),
    );
  }
}

class _UnitPicker extends StatelessWidget {
  final List<FridgeUnit> units;
  final FridgeUnit selected;
  final void Function(FridgeUnit) onSelect;

  const _UnitPicker({
    required this.units,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_kRadius),
        color: _kFieldBg,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: units.map((u) {
          final sel = selected == u;
          return GestureDetector(
            onTap: () => onSelect(u),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: sel ? _kBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(_kRadius - 4),
              ),
              child: Text(
                u.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : neutralMedium,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final FridgeCategory cat;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.cat,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? _kBlue : _kFieldBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _kBlue : Colors.transparent,
          ),
        ),
        child: Text(
          '${cat.emoji} ${cat.label}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : neutralMedium,
          ),
        ),
      ),
    );
  }
}

// ── Aba Compras ───────────────────────────────────────────────────────────────

class _ShoppingTab extends ConsumerWidget {
  final dynamic state;
  const _ShoppingTab({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fridgeState = ref.watch(fridgeProvider);
    final shopping = fridgeState.shoppingList;
    final checkedCount = shopping.where((e) => e.isChecked).length;

    final pendingCount = shopping.where((e) => !e.isChecked).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lista de Compras',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: neutralDark,
                ),
              ),
              if (shopping.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  pendingCount == 0
                      ? 'Tudo comprado!'
                      : '$pendingCount ${pendingCount == 1 ? 'item pendente' : 'itens pendentes'}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: neutralMedium,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Mover para geladeira
        if (checkedCount > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: GestureDetector(
              onTap: () {
                final checked =
                    shopping.where((e) => e.isChecked).toList();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => _MoveToFridgeSheet(items: checked),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: brandPrimary,
                  borderRadius: BorderRadius.circular(_kRadius),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.kitchen_outlined,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Adicionar $checkedCount item${checkedCount != 1 ? 's' : ''} à geladeira',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Lista
        Expanded(
          child: shopping.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shopping_cart_outlined,
                            size: 34, color: neutralMedium),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Lista de compras vazia',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: neutralDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Adicione itens que você precisa comprar',
                        style: TextStyle(
                            color: neutralMedium, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: shopping.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final item = shopping[i];
                    return _ShoppingItemCard(
                      item: item,
                      onToggle: () => ref
                          .read(fridgeProvider.notifier)
                          .toggleShoppingItem(item.id),
                      onRemove: () => ref
                          .read(fridgeProvider.notifier)
                          .removeShoppingItem(item.id),
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
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: _kCardBg,
          borderRadius: BorderRadius.circular(_kRadius),
          border: Border.all(color: _kBorderColor),
          boxShadow: _kCardShadow,
        ),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                item.isChecked ? Icons.check_circle : Icons.circle_outlined,
                key: ValueKey(item.isChecked),
                color: item.isChecked ? _kBlue : neutralLight,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(item.category.emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      decoration: item.isChecked ? TextDecoration.lineThrough : null,
                      color: item.isChecked ? neutralLight : neutralDark,
                      letterSpacing: -0.1,
                    ),
                  ),
                  if (item.store != null) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.storefront_outlined, size: 11, color: neutralMedium),
                        const SizedBox(width: 3),
                        Text(
                          item.store!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: neutralMedium,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: _kSeparator,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: neutralMedium, size: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom sheet: adicionar à lista de compras ────────────────────────────────

class _AddShoppingItemSheet extends ConsumerStatefulWidget {
  const _AddShoppingItemSheet();

  @override
  ConsumerState<_AddShoppingItemSheet> createState() =>
      _AddShoppingItemSheetState();
}

class _AddShoppingItemSheetState
    extends ConsumerState<_AddShoppingItemSheet> {
  final _nameCtrl = TextEditingController();
  final _storeCtrl = TextEditingController();
  FridgeCategory _category = FridgeCategory.other;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _storeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    ref.read(fridgeProvider.notifier).addShoppingItem(
          name,
          _category,
          store: _storeCtrl.text.trim().isEmpty ? null : _storeCtrl.text.trim(),
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: _kBorderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Adicionar à lista de compras',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: neutralDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Preencha as informações do item',
              style: TextStyle(fontSize: 13, color: neutralLight, letterSpacing: -0.1),
            ),
            const SizedBox(height: 20),

            // Nome
            _StyledField(
              controller: _nameCtrl,
              hintText: 'Ex: Leite, Arroz, Tomate…',
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: _submit,
            ),
            const SizedBox(height: 12),

            // Onde comprar (opcional)
            _StyledField(
              controller: _storeCtrl,
              hintText: 'Onde comprar (opcional)',
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Categoria
            const Text(
              'Categoria',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: neutralMedium,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: FridgeCategory.values
                    .map((cat) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _CategoryChip(
                            cat: cat,
                            selected: _category == cat,
                            onTap: () => setState(() => _category = cat),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    letterSpacing: -0.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_kRadius),
                  ),
                ),
                child: const Text('Adicionar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Botão histórico ───────────────────────────────────────────────────────────

class _HistoryButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.remove_red_eye_outlined, color: neutralDark),
      onPressed: () => _showHistorySheet(context, ref),
    );
  }

  void _showHistorySheet(BuildContext context, WidgetRef ref) {
    final houseId = ref.read(houseProvider).houseId ?? '';
    final logRepo = ref.read(logRepositoryProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Histórico',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<dynamic>>(
                stream: logRepo.watchLogs(houseId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: _kBlue));
                  }

                  final logs = snapshot.data ?? [];

                  if (logs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.history_rounded, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          const Text(
                            'Nenhuma atividade ainda',
                            style: TextStyle(color: Color(0xFF8E8E93), fontSize: 15),
                          ),
                        ],
                      ),
                    );
                  }

                  // Agrupa por data
                  final Map<String, List<dynamic>> grouped = {};
                  for (final log in logs) {
                    final key = _dateKey(log.createdAt);
                    grouped.putIfAbsent(key, () => []).add(log);
                  }
                  final dateKeys = grouped.keys.toList();

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: dateKeys.length,
                    itemBuilder: (context, i) {
                      final dateKey = dateKeys[i];
                      final dateLogs = grouped[dateKey]!;
                      final isFirst = i == 0;

                      return _DateGroup(
                        dateLabel: _formatDateLabel(dateLogs.first.createdAt),
                        logs: dateLogs,
                        initiallyExpanded: isFirst,
                        formatTime: _formatTime,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  String _formatDateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(date).inDays;
    if (diff == 0) return 'Hoje';
    if (diff == 1) return 'Ontem';
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d/${m}/${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Agora mesmo';
    if (diff.inMinutes < 60) return 'Há ${diff.inMinutes} min';
    if (diff.inHours < 24) {
      final h = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return 'às $h:$min';
    }
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return 'às $h:$min';
  }
}

// ── Grupo de logs por data ────────────────────────────────────────────────────

class _DateGroup extends StatefulWidget {
  final String dateLabel;
  final List<dynamic> logs;
  final bool initiallyExpanded;
  final String Function(DateTime) formatTime;

  const _DateGroup({
    required this.dateLabel,
    required this.logs,
    required this.initiallyExpanded,
    required this.formatTime,
  });

  @override
  State<_DateGroup> createState() => _DateGroupState();
}

class _DateGroupState extends State<_DateGroup> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _kFieldBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          // Header da data
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _kBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.dateLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _kBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${widget.logs.length} ${widget.logs.length == 1 ? 'ação' : 'ações'}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
                  ),
                  const Spacer(),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF8E8E93),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          // Logs da data
          if (_expanded) ...[
            const Divider(height: 1, color: Color(0xFFE5E5EA)),
            ...widget.logs.asMap().entries.map((entry) {
              final i = entry.key;
              final log = entry.value;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(log.emoji, style: const TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                log.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: neutralDark,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                widget.formatTime(log.createdAt),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF8E8E93),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i < widget.logs.length - 1)
                    const Divider(height: 1, indent: 64, color: Color(0xFFE5E5EA)),
                ],
              );
            }),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}
