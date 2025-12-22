import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/awareness_provider.dart';
import '../mappers/awareness_ui_mapper.dart';
import '../rules_engine/models.dart';

class AwarenessBanner extends StatelessWidget {
  const AwarenessBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final awareness =
        context.watch<AwarenessProvider>().currentAwareness;

    if (awareness == null ||
        awareness.level == AwarenessLevel.none) {
      return const SizedBox.shrink();
    }

    final uiModel =
        AwarenessUIMapper.fromAwareness(awareness);

    if (uiModel == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            uiModel.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            uiModel.message,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (uiModel.showDismiss)
  Align(
    alignment: Alignment.centerRight,
    child: TextButton(
      onPressed: () {
        context
            .read<AwarenessProvider>()
            .rejectCurrent();
      },
      child: const Text('Dismiss'),
    ),
  ),
        ],
      ),
    );
  }
}
