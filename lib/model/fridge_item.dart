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
      case FridgeCategory.meats:      return 'Carnes';
      case FridgeCategory.vegetables: return 'Verduras';
      case FridgeCategory.drinks:     return 'Bebidas';
      case FridgeCategory.dairy:      return 'Laticínios';
      case FridgeCategory.fruits:     return 'Frutas';
      case FridgeCategory.grains:     return 'Grãos';
      case FridgeCategory.frozen:     return 'Congelados';
      case FridgeCategory.condiments: return 'Temperos';
      case FridgeCategory.other:      return 'Outros';
    }
  }

  String get emoji {
    switch (this) {
      case FridgeCategory.meats:      return '🥩';
      case FridgeCategory.vegetables: return '🥬';
      case FridgeCategory.drinks:     return '🥤';
      case FridgeCategory.dairy:      return '🧀';
      case FridgeCategory.fruits:     return '🍎';
      case FridgeCategory.grains:     return '🌾';
      case FridgeCategory.frozen:     return '🧊';
      case FridgeCategory.condiments: return '🧂';
      case FridgeCategory.other:      return '📦';
    }
  }

  /// Unidades sugeridas para a categoria (primeiro = padrão)
  List<FridgeUnit> get suggestedUnits {
    switch (this) {
      case FridgeCategory.drinks:     return [FridgeUnit.ml, FridgeUnit.l];
      case FridgeCategory.dairy:      return [FridgeUnit.ml, FridgeUnit.l, FridgeUnit.g, FridgeUnit.kg];
      case FridgeCategory.meats:      return [FridgeUnit.g, FridgeUnit.kg];
      case FridgeCategory.vegetables: return [FridgeUnit.g, FridgeUnit.kg, FridgeUnit.un];
      case FridgeCategory.fruits:     return [FridgeUnit.un, FridgeUnit.g, FridgeUnit.kg];
      case FridgeCategory.grains:     return [FridgeUnit.g, FridgeUnit.kg];
      case FridgeCategory.frozen:     return [FridgeUnit.g, FridgeUnit.kg];
      case FridgeCategory.condiments: return [FridgeUnit.g, FridgeUnit.ml];
      case FridgeCategory.other:      return [FridgeUnit.un, FridgeUnit.g, FridgeUnit.kg];
    }
  }

  FridgeUnit get defaultUnit => suggestedUnits.first;
}

// ── Unidade de medida ────────────────────────────────────────────────────────

enum FridgeUnit { ml, l, g, kg, un }

extension FridgeUnitExtension on FridgeUnit {
  String get label {
    switch (this) {
      case FridgeUnit.ml: return 'ml';
      case FridgeUnit.l:  return 'L';
      case FridgeUnit.g:  return 'g';
      case FridgeUnit.kg: return 'kg';
      case FridgeUnit.un: return 'un';
    }
  }
}

// ── FridgeItem ───────────────────────────────────────────────────────────────

class FridgeItem {
  final String id;
  final String name;
  final FridgeCategory category;
  final DateTime addedAt;
  final DateTime? expiresAt;
  final double? quantity;
  final FridgeUnit? unit;

  FridgeItem({
    required this.id,
    required this.name,
    required this.category,
    required this.addedAt,
    this.expiresAt,
    this.quantity,
    this.unit,
  });

  /// Texto formatado da quantidade, ex: "500 ml", "1,5 kg", "3 un"
  String? get quantityLabel {
    if (quantity == null || unit == null) return null;
    final formatted = quantity! % 1 == 0
        ? quantity!.toInt().toString()
        : quantity!.toStringAsFixed(1).replaceAll('.', ',');
    return '$formatted ${unit!.label}';
  }

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
    'quantity': quantity,
    'unit': unit?.name,
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
      quantity: (json['quantity'] as num?)?.toDouble(),
      unit: json['unit'] != null
          ? FridgeUnit.values.firstWhere(
              (e) => e.name == json['unit'],
              orElse: () => FridgeUnit.un,
            )
          : null,
    );
  }

  factory FridgeItem.fromSupabase(Map<String, dynamic> json) {
    return FridgeItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: FridgeCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => FridgeCategory.other,
      ),
      addedAt: DateTime.parse(json['added_at'] as String),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      quantity: (json['quantity'] as num?)?.toDouble(),
      unit: json['unit'] != null
          ? FridgeUnit.values.firstWhere(
              (e) => e.name == json['unit'],
              orElse: () => FridgeUnit.un,
            )
          : null,
    );
  }

  Map<String, dynamic> toSupabase(String houseId, String addedBy) => {
    'id': id,
    'house_id': houseId,
    'name': name,
    'category': category.name,
    'quantity': quantity,
    'unit': unit?.name,
    'added_at': addedAt.toIso8601String(),
    'expires_at': expiresAt?.toIso8601String(),
    'added_by': addedBy,
  };

  FridgeItem copyWith({
    String? name,
    FridgeCategory? category,
    DateTime? expiresAt,
    bool clearExpiry = false,
    double? quantity,
    FridgeUnit? unit,
    bool clearQuantity = false,
  }) {
    return FridgeItem(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      addedAt: addedAt,
      expiresAt: clearExpiry ? null : (expiresAt ?? this.expiresAt),
      quantity: clearQuantity ? null : (quantity ?? this.quantity),
      unit: clearQuantity ? null : (unit ?? this.unit),
    );
  }
}
