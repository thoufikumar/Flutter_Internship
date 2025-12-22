import 'package:expense_tracker_app/eve_memory/models/eve_context_state.dart';
import 'package:expense_tracker_app/rules_engine/models.dart';

import '../eve/eve_context.dart';
import '../eve/eve_observation_mapper.dart';

EveContext toEveContext(
  EveContextState state, {
  Velocity? velocity,
  Frequency? frequency,
  Rhythm? rhythm,
}) {
  return EveObservationMapper.map(
    level: state.level,
    reason: state.reason,
    category: state.category,
    velocity: velocity,
    frequency: frequency,
    rhythm: rhythm,
  );
}
