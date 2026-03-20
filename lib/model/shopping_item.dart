import 'fridge_item.dart';

class ShoppingItem {
  final String id;
  final String name;
  final FridgeCategory category;
  final bool isChecked;
  final DateTime addedAt;
  final String? store; // onde comprar (opcional)

  ShoppingItem({
    required this.id,
    required this.name,
    required this.category,
    this.isChecked = false,
    required this.addedAt,
    this.store,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category.name,
    'isChecked': isChecked,
    'addedAt': addedAt.toIso8601String(),
    'store': store,
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
    store: json['store'] as String?,
  );

  factory ShoppingItem.fromSupabase(Map<String, dynamic> json) => ShoppingItem(
    id: json['id'] as String,
    name: json['name'] as String,
    category: FridgeCategory.values.firstWhere(
      (e) => e.name == json['category'],
      orElse: () => FridgeCategory.other,
    ),
    isChecked: json['is_checked'] as bool? ?? false,
    addedAt: DateTime.parse(json['added_at'] as String),
    store: json['store'] as String?,
  );

  Map<String, dynamic> toSupabase(String houseId, String addedBy) => {
    'id': id,
    'house_id': houseId,
    'name': name,
    'category': category.name,
    'is_checked': isChecked,
    'added_at': addedAt.toIso8601String(),
    'store': store,
    'added_by': addedBy,
  };

  ShoppingItem copyWith({bool? isChecked}) => ShoppingItem(
    id: id,
    name: name,
    category: category,
    isChecked: isChecked ?? this.isChecked,
    addedAt: addedAt,
    store: store,
  );
}
