import 'package:supabase_flutter/supabase_flutter.dart';
import '../../model/log_entry.dart';

class LogRepository {
  final SupabaseClient _client;

  LogRepository(this._client);

  String get _userId => _client.auth.currentUser?.id ?? '';

  Future<void> log(
      String houseId,
      String action, {
        String? itemName,
        String? displayName,
      }) async {
    try {
      await _client.from('house_logs').insert({
        'house_id': houseId,
        'user_id': _userId,
        'action': action,
        'item_name': itemName,
        'display_name': displayName,
      });
    } catch (_) {}
  }

  Stream<List<LogEntry>> watchLogs(String houseId) {
    return _client
        .from('house_logs')
        .stream(primaryKey: ['id'])
        .eq('house_id', houseId)
        .order('created_at', ascending: false)
        .map((data) => data.map((e) => LogEntry.fromSupabase(e)).toList());
  }
}
