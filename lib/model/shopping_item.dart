import 'fridge_item.dart';

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
