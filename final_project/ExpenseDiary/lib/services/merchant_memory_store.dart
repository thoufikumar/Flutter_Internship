import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MerchantMemoryStore {
  static const _key = 'merchant_memory';

  Future<Map<String, dynamic>> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return {};
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> _save(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data));
  }

  /// Called when user confirms or edits an expense
  Future<void> recordAcceptance({
    required String merchantKey,
    required String title,
  }) async {
    final data = await _load();

    final entry = data[merchantKey] as Map<String, dynamic>? ?? {
      'title': title,
      'count': 0,
    };

    entry['title'] = title;
    entry['count'] = (entry['count'] as int) + 1;

    data[merchantKey] = entry;
    await _save(data);
  }

  /// Used during normalization
  Future<String?> getTitle(String merchantKey) async {
    final data = await _load();
    final entry = data[merchantKey];
    if (entry == null) return null;
    return (entry as Map<String, dynamic>)['title'] as String?;
  }
}
