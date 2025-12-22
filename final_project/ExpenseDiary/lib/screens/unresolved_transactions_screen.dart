import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/unresolved_store.dart';
import '../widgets/unresolved_transaction_card.dart';
import '../theme/app_colors.dart';

class UnresolvedTransactionsScreen extends StatelessWidget {
  const UnresolvedTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<UnresolvedStore>();
    final items = store.pendingItems;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: Text(
          'Unresolved Transactions',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.primary),
      ),
      body: items.isEmpty
          ? const Center(
              child: Text(
                'No unreviewed transactions right now.',
                style: TextStyle(color: AppColors.textMuted),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return UnresolvedTransactionCard(
                  transaction: items[index],
                );
              },
            ),
    );
  }
}
