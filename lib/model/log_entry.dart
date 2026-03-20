class LogEntry {
  final String id;
  final String action;
  final String? itemName;
  final String? displayName;
  final DateTime createdAt;

  LogEntry({
    required this.id,
    required this.action,
    this.itemName,
    this.displayName,
    required this.createdAt,
  });

  factory LogEntry.fromSupabase(Map<String, dynamic> json) => LogEntry(
    id: json['id'] as String,
    action: json['action'] as String,
    itemName: json['item_name'] as String?,
    displayName: json['display_name'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
  );

  String get description {
    final who = displayName ?? 'Alguém';
    switch (action) {
      case 'add_fridge':      return '$who adicionou "$itemName" à geladeira';
      case 'remove_fridge':   return '$who removeu "$itemName" da geladeira';
      case 'update_fridge':   return '$who editou "$itemName" na geladeira';
      case 'add_shopping':    return '$who adicionou "$itemName" à lista de compras';
      case 'remove_shopping': return '$who removeu "$itemName" da lista de compras';
      case 'check_shopping':  return '$who marcou "$itemName" como comprado';
      case 'uncheck_shopping':return '$who desmarcou "$itemName"';
      case 'move_to_fridge':
        return itemName != null
            ? '$who moveu "$itemName" da lista para a geladeira'
            : '$who moveu itens da lista para a geladeira';
      default: return action;
    }
  }

  String get emoji {
    switch (action) {
      case 'add_fridge':      return '➕';
      case 'remove_fridge':   return '🗑️';
      case 'update_fridge':   return '✏️';
      case 'add_shopping':    return '🛒';
      case 'remove_shopping': return '🗑️';
      case 'check_shopping':  return '✅';
      case 'uncheck_shopping':return '⬜';
      case 'move_to_fridge':  return '📦';
      default: return '📋';
    }
  }
}
