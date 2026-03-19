# Refatoração da Geladeira — Cozinhei App

> Documento gerado em 19/03/2026 para continuidade no PC de casa.
> Projeto: `C:\dev\cozinhei` (Flutter + Riverpod + SharedPreferences + Supabase + GetIt)

---

## 1. Estado Atual (antes da refatoração)

### Arquivos envolvidos

| Arquivo | Responsabilidade |
|---|---|
| `lib/data/repository/fridge_repository.dart` | Persistência (SharedPreferences) |
| `lib/viewmodel/fridge_notifier.dart` | Estado (StateNotifier) |
| `lib/ui/screens/fridge/fridge_screen.dart` | UI |
| `lib/providers.dart` | Provider Riverpod (`fridgeProvider`) |
| `lib/di/injection.dart` | Registro do `FridgeRepository` no GetIt |
| `lib/viewmodel/home_notifier.dart` | Consome `fridgeProvider` para sugerir receitas |

### Model atual

Não existe uma classe `FridgeItem`. O estado é simplesmente:

```dart
// providers.dart
final fridgeProvider = StateNotifierProvider<FridgeNotifier, List<String>>((ref) {
  return FridgeNotifier(ref.read(fridgeRepositoryProvider));
});
```

### Repository atual

```dart
// lib/data/repository/fridge_repository.dart
class FridgeRepository {
  static const String _key = 'fridge_ingredients';
  final SharedPreferences _prefs;

  FridgeRepository(this._prefs);

  List<String> load() {
    final json = _prefs.getString(_key);
    if (json == null) return [];
    try {
      return List<String>.from(jsonDecode(json));
    } catch (_) {
      return [];
    }
  }

  Future<void> setIngredients(List<String> ingredients) async {
    await _prefs.setString(_key, jsonEncode(ingredients));
  }
}
```

### Notifier atual

```dart
// lib/viewmodel/fridge_notifier.dart
class FridgeNotifier extends StateNotifier<List<String>> {
  final FridgeRepository _repository;

  FridgeNotifier(this._repository) : super(_repository.load());

  void addIngredient(String item) {
    if (item.isNotEmpty && !state.contains(item)) {
      state = [...state, item];
      _repository.setIngredients(state);
    }
  }

  void removeIngredient(int index) {
    final updated = [...state]..removeAt(index);
    state = updated;
    _repository.setIngredients(state);
  }

  void setIngredients(List<String> ingredients) {
    state = ingredients;
    _repository.setIngredients(state);
  }
}
```

### Ponto de atenção: integração com Home

`home_notifier.dart` usa o fridge assim — ao refatorar, **não pode quebrar isso**:

```dart
// home_notifier.dart (trecho relevante)
// Ele acessa a lista de strings dos ingredientes para passar à IA
// O método syncFridgeSuggestions() lê fridgeProvider como List<String>
// e passa para generateFridgeSuggestions(List<String> ingredients)
```

Após a refatoração, onde hoje passa `List<String>`, deve passar `items.map((e) => e.name).toList()`.

---

## 2. Features a implementar (decisões já tomadas)

| # | Feature | Decisão |
|---|---|---|
| 1 | **Controle de validade** | ✅ Implementar — diferencial forte |
| 2 | **Categorias** | ✅ Implementar — separação visual |
| 3 | **Lista de compras** | ✅ Dentro da aba Geladeira (não aba separada) |
| 4 | **Modo rápido** | ✅ Aprende dos itens mais usados pelo usuário |
| 5 | Sugestão de receitas | Já existe, só adaptar para novo model |
| 6 | Histórico de compras | Futuro |
| 7 | Compartilhamento familiar | Futuro |

---

## 3. Novo modelo de dados

### FridgeItem

Criar arquivo `lib/model/fridge_item.dart`:

```dart
import 'dart:convert';

enum FridgeCategory {
  meats,      // 🥩 Carnes
  vegetables, // 🥬 Verduras
  drinks,     // 🥤 Bebidas
  dairy,      // 🧀 Laticínios
  fruits,     // 🍎 Frutas
  grains,     // 🌾 Grãos e Cereais
  frozen,     // 🧊 Congelados
  condiments, // 🧂 Temperos
  other,      // 📦 Outros
}

extension FridgeCategoryExtension on FridgeCategory {
  String get label {
    switch (this) {
      case FridgeCategory.meats: return 'Carnes';
      case FridgeCategory.vegetables: return 'Verduras';
      case FridgeCategory.drinks: return 'Bebidas';
      case FridgeCategory.dairy: return 'Laticínios';
      case FridgeCategory.fruits: return 'Frutas';
      case FridgeCategory.grains: return 'Grãos';
      case FridgeCategory.frozen: return 'Congelados';
      case FridgeCategory.condiments: return 'Temperos';
      case FridgeCategory.other: return 'Outros';
    }
  }

  String get emoji {
    switch (this) {
      case FridgeCategory.meats: return '🥩';
      case FridgeCategory.vegetables: return '🥬';
      case FridgeCategory.drinks: return '🥤';
      case FridgeCategory.dairy: return '🧀';
      case FridgeCategory.fruits: return '🍎';
      case FridgeCategory.grains: return '🌾';
      case FridgeCategory.frozen: return '🧊';
      case FridgeCategory.condiments: return '🧂';
      case FridgeCategory.other: return '📦';
    }
  }
}

class FridgeItem {
  final String id;
  final String name;
  final FridgeCategory category;
  final DateTime addedAt;
  final DateTime? expiresAt; // null = sem data de validade

  FridgeItem({
    required this.id,
    required this.name,
    required this.category,
    required this.addedAt,
    this.expiresAt,
  });

  // Quantos dias até vencer (negativo = já venceu)
  int? get daysUntilExpiry {
    if (expiresAt == null) return null;
    return expiresAt!.difference(DateTime.now()).inDays;
  }

  bool get isExpired => daysUntilExpiry != null && daysUntilExpiry! < 0;
  bool get expiresSoon => daysUntilExpiry != null && daysUntilExpiry! <= 3 && !isExpired;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category.name,
    'addedAt': addedAt.toIso8601String(),
    'expiresAt': expiresAt?.toIso8601String(),
  };

  factory FridgeItem.fromJson(Map<String, dynamic> json) {
    return FridgeItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: FridgeCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => FridgeCategory.other,
      ),
      addedAt: DateTime.parse(json['addedAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }

  FridgeItem copyWith({
    String? name,
    FridgeCategory? category,
    DateTime? expiresAt,
    bool clearExpiry = false,
  }) {
    return FridgeItem(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      addedAt: addedAt,
      expiresAt: clearExpiry ? null : (expiresAt ?? this.expiresAt),
    );
  }
}
```

### ShoppingItem

Criar arquivo `lib/model/shopping_item.dart`:

```dart
class ShoppingItem {
  final String id;
  final String name;
  final FridgeCategory category;
  final bool isChecked;
  final DateTime addedAt;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.category,
    this.isChecked = false,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category.name,
    'isChecked': isChecked,
    'addedAt': addedAt.toIso8601String(),
  };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
    id: json['id'] as String,
    name: json['name'] as String,
    category: FridgeCategory.values.firstWhere(
      (e) => e.name == json['category'],
      orElse: () => FridgeCategory.other,
    ),
    isChecked: json['isChecked'] as bool? ?? false,
    addedAt: DateTime.parse(json['addedAt'] as String),
  );

  ShoppingItem copyWith({bool? isChecked}) => ShoppingItem(
    id: id,
    name: name,
    category: category,
    isChecked: isChecked ?? this.isChecked,
    addedAt: addedAt,
  );
}
```

---

## 4. Novo FridgeRepository

Substituir completamente `lib/data/repository/fridge_repository.dart`:

```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/fridge_item.dart';
import '../../model/shopping_item.dart';

class FridgeRepository {
  static const String _fridgeKey = 'fridge_items_v2';
  static const String _shoppingKey = 'shopping_items_v1';
  static const String _quickItemsKey = 'quick_add_items_v1'; // histórico de uso
  final SharedPreferences _prefs;

  FridgeRepository(this._prefs);

  // ── Fridge ──────────────────────────────────────────────────────────────────

  List<FridgeItem> loadFridge() {
    final json = _prefs.getString(_fridgeKey);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List;
      return list.map((e) => FridgeItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveFridge(List<FridgeItem> items) async {
    await _prefs.setString(_fridgeKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  // ── Shopping List ────────────────────────────────────────────────────────────

  List<ShoppingItem> loadShopping() {
    final json = _prefs.getString(_shoppingKey);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List;
      return list.map((e) => ShoppingItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveShopping(List<ShoppingItem> items) async {
    await _prefs.setString(_shoppingKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  // ── Quick Add (histórico de frequência) ─────────────────────────────────────

  Map<String, int> loadQuickItemUsage() {
    final json = _prefs.getString(_quickItemsKey);
    if (json == null) return {};
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, v as int));
    } catch (_) {
      return {};
    }
  }

  Future<void> incrementQuickItemUsage(String name) async {
    final usage = loadQuickItemUsage();
    usage[name] = (usage[name] ?? 0) + 1;
    await _prefs.setString(_quickItemsKey, jsonEncode(usage));
  }

  /// Retorna os N itens mais usados (para o modo rápido)
  List<String> getTopQuickItems({int limit = 8}) {
    final usage = loadQuickItemUsage();
    final sorted = usage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).map((e) => e.key).toList();
  }
}
```

---

## 5. Novo FridgeState e FridgeNotifier

### FridgeState

Criar `lib/viewmodel/fridge_state.dart`:

```dart
import '../model/fridge_item.dart';
import '../model/shopping_item.dart';

class FridgeState {
  final List<FridgeItem> items;
  final List<ShoppingItem> shoppingList;
  final List<String> quickItems; // itens mais usados para modo rápido

  const FridgeState({
    this.items = const [],
    this.shoppingList = const [],
    this.quickItems = const [],
  });

  FridgeState copyWith({
    List<FridgeItem>? items,
    List<ShoppingItem>? shoppingList,
    List<String>? quickItems,
  }) {
    return FridgeState(
      items: items ?? this.items,
      shoppingList: shoppingList ?? this.shoppingList,
      quickItems: quickItems ?? this.quickItems,
    );
  }

  // Itens agrupados por categoria (para exibição)
  Map<FridgeCategory, List<FridgeItem>> get itemsByCategory {
    final map = <FridgeCategory, List<FridgeItem>>{};
    for (final item in items) {
      map.putIfAbsent(item.category, () => []).add(item);
    }
    return map;
  }

  // Itens que vencem em breve ou já venceram (para alertas)
  List<FridgeItem> get expiringItems =>
      items.where((e) => e.expiresAt != null && (e.expiresoon || e.isExpired)).toList();
      // Nota: corrigir typo expiresoon -> expiresSort ou usar:
      // items.where((e) => e.expiresAt != null && (e.expiresoon || e.isExpired)).toList()
      // -> items.where((e) => e.expiresAt != null && ((e.daysUntilExpiry ?? 999) <= 3)).toList()
}
```

### FridgeNotifier

Substituir `lib/viewmodel/fridge_notifier.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/repository/fridge_repository.dart';
import '../model/fridge_item.dart';
import '../model/shopping_item.dart';
import 'fridge_state.dart';

class FridgeNotifier extends StateNotifier<FridgeState> {
  final FridgeRepository _repository;
  final _uuid = const Uuid();

  FridgeNotifier(this._repository) : super(FridgeState(
    items: _repository.loadFridge(),
    shoppingList: _repository.loadShopping(),
    quickItems: _repository.getTopQuickItems(),
  ));

  // ── Fridge ──────────────────────────────────────────────────────────────────

  void addItem(String name, FridgeCategory category, {DateTime? expiresAt}) {
    final item = FridgeItem(
      id: _uuid.v4(),
      name: name.trim(),
      category: category,
      addedAt: DateTime.now(),
      expiresAt: expiresAt,
    );
    state = state.copyWith(items: [...state.items, item]);
    _repository.saveFridge(state.items);
    _repository.incrementQuickItemUsage(name.trim()).then((_) {
      state = state.copyWith(quickItems: _repository.getTopQuickItems());
    });
  }

  void removeItem(String id) {
    state = state.copyWith(items: state.items.where((e) => e.id != id).toList());
    _repository.saveFridge(state.items);
  }

  void updateItem(FridgeItem updated) {
    state = state.copyWith(
      items: state.items.map((e) => e.id == updated.id ? updated : e).toList(),
    );
    _repository.saveFridge(state.items);
  }

  // ── Shopping List ────────────────────────────────────────────────────────────

  void addShoppingItem(String name, FridgeCategory category) {
    final item = ShoppingItem(
      id: _uuid.v4(),
      name: name.trim(),
      category: category,
      addedAt: DateTime.now(),
    );
    state = state.copyWith(shoppingList: [...state.shoppingList, item]);
    _repository.saveShopping(state.shoppingList);
  }

  void toggleShoppingItem(String id) {
    final updated = state.shoppingList
        .map((e) => e.id == id ? e.copyWith(isChecked: !e.isChecked) : e)
        .toList();
    state = state.copyWith(shoppingList: updated);
    _repository.saveShopping(state.shoppingList);
  }

  void removeShoppingItem(String id) {
    state = state.copyWith(
      shoppingList: state.shoppingList.where((e) => e.id != id).toList(),
    );
    _repository.saveShopping(state.shoppingList);
  }

  /// Move itens marcados da lista de compras para a geladeira
  void moveCheckedToFridge() {
    final checked = state.shoppingList.where((e) => e.isChecked).toList();
    final remaining = state.shoppingList.where((e) => !e.isChecked).toList();

    final newFridgeItems = checked.map((s) => FridgeItem(
      id: _uuid.v4(),
      name: s.name,
      category: s.category,
      addedAt: DateTime.now(),
    )).toList();

    state = state.copyWith(
      items: [...state.items, ...newFridgeItems],
      shoppingList: remaining,
    );
    _repository.saveFridge(state.items);
    _repository.saveShopping(state.shoppingList);

    for (final item in checked) {
      _repository.incrementQuickItemUsage(item.name);
    }
  }

  // Helper para compatibilidade com home_notifier.dart
  List<String> get ingredientNames => state.items.map((e) => e.name).toList();
}
```

---

## 6. Atualizar providers.dart

```dart
// REMOVER:
// final fridgeProvider = StateNotifierProvider<FridgeNotifier, List<String>>(...

// ADICIONAR:
final fridgeProvider = StateNotifierProvider<FridgeNotifier, FridgeState>((ref) {
  return FridgeNotifier(ref.read(fridgeRepositoryProvider));
});
```

---

## 7. Adaptar home_notifier.dart

Buscar no arquivo onde usa `fridgeProvider` como `List<String>` e substituir por:

```dart
// ANTES (provavelmente algo assim):
final ingredients = ref.read(fridgeProvider);

// DEPOIS:
final ingredients = ref.read(fridgeProvider).items.map((e) => e.name).toList();
// ou usar o helper:
final ingredients = ref.read(fridgeProvider.notifier).ingredientNames;
```

---

## 8. Dependência nova necessária

Adicionar no `pubspec.yaml`:

```yaml
dependencies:
  uuid: ^4.0.0  # para gerar IDs únicos dos itens
```

Rodar: `flutter pub get`

---

## 9. Nova UI — FridgeScreen

A tela deve ter **duas abas** (TabBar ou segmented control):

```
[ 🧊 Geladeira ]  [ 🛒 Compras ]
```

### Aba Geladeira
- Botão "+ Adicionar" abre bottom sheet com:
  - Campo nome
  - Seletor de categoria (chips horizontais)
  - Campo data de validade (opcional — DatePicker)
- Lista agrupada por categoria com headers
- Card de cada item mostra:
  - Nome
  - Badge de validade (🟢 ok / 🟡 vence em X dias / 🔴 vencido)
- **Modo rápido**: linha horizontal de chips com itens mais usados (ex: "+ Leite", "+ Ovo")
- Banner de alerta no topo se houver itens vencendo

### Aba Compras
- Campo para adicionar item + categoria
- Lista com checkbox
- Botão "Adicionar à geladeira" (move itens marcados)

---

## 10. Alertas de validade

Sem push notification por enquanto. Apenas visual na tela:

```dart
// Banner no topo da aba Geladeira quando expiringItems.isNotEmpty
if (state.expiringItems.isNotEmpty)
  Container(
    // fundo amarelo/vermelho
    child: Text('⚠️ ${state.expiringItems.length} item(ns) vencendo em breve'),
  )
```

---

## 11. Ordem de implementação sugerida

```
1. [ ] Criar lib/model/fridge_item.dart  (com FridgeCategory)
2. [ ] Criar lib/model/shopping_item.dart
3. [ ] Refatorar lib/data/repository/fridge_repository.dart
4. [ ] Criar lib/viewmodel/fridge_state.dart
5. [ ] Refatorar lib/viewmodel/fridge_notifier.dart
6. [ ] Atualizar lib/providers.dart  (mudar tipo do provider)
7. [ ] Adaptar lib/viewmodel/home_notifier.dart  (corrigir uso de fridgeProvider)
8. [ ] Adicionar uuid ao pubspec.yaml
9. [ ] Refatorar lib/ui/screens/fridge/fridge_screen.dart  (nova UI)
10. [ ] Testar fluxo completo
```

---

## 12. Perguntas já respondidas

- Lista de compras fica **dentro da aba Geladeira** (não aba separada)
- Modo rápido **aprende dos itens mais usados** (não lista fixa)
- Sugestão de receitas já existe — só adaptar para novo model

---

## 13. O que NÃO mudar agora

- Fluxo de sugestão de receitas (home_notifier.dart) — só adaptar ponto de integração
- Navegação (app_router.dart) — rota `/fridge` continua igual
- Injeção de dependência (injection.dart) — FridgeRepository continua registrado igual
- Supabase/comunidade — não há integração com fridge nessa etapa

---

*Documento gerado pelo Claude Code — continuar no PC de casa*
