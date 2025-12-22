import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../rules_engine/suppression.dart';

class SuppressionStorage {
  static const _dismissedKey = 'suppressed_dismissed';
  static const _rejectedKey = 'suppressed_rejected';

  Future<void> save(SuppressionState state) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _dismissedKey,
      jsonEncode(state.dismissedSignals.toList()),
    );

    await prefs.setString(
      _rejectedKey,
      jsonEncode(state.rejectionCounts),
    );
  }

  Future<SuppressionState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final state = SuppressionState();

    final dismissedRaw = prefs.getString(_dismissedKey);
    if (dismissedRaw != null) {
      final List<dynamic> decoded = jsonDecode(dismissedRaw);
      state.dismissedSignals.addAll(decoded.cast<String>());
    }

    final rejectedRaw = prefs.getString(_rejectedKey);
    if (rejectedRaw != null) {
      final Map<String, dynamic> decoded =
          jsonDecode(rejectedRaw);
      decoded.forEach((key, value) {
        state.rejectionCounts[key] = value as int;
      });
    }

    return state;
  }
}
