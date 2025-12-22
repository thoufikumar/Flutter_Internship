import 'package:expense_tracker_app/eve_memory/models/eve_context_state.dart';

class EveContextStore {
  static final EveContextStore instance = EveContextStore._();
  EveContextStore._();

  EveContextState? _cache;

  Future<void> save(EveContextState state) async {
    _cache = state;
    // TODO: persist with Hive / Isar
  }

  Future<EveContextState?> load() async {
    return _cache;
  }

  Future<void> clear() async {
    _cache = null;
  }
}
