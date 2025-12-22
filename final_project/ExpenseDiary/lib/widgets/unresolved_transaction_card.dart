import 'package:expense_tracker_app/services/expense_normalizer.dart';
import 'package:expense_tracker_app/services/suppression_service.dart';
import 'package:expense_tracker_app/services/suppression_storage.dart';
import 'package:expense_tracker_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/unresolved_transaction.dart';
import '../state/unresolved_store.dart';
import '../provider/ExpenseProvider.dart';
import '../screens/addExpenses.dart'; // for showAddExpenseSheet

class UnresolvedTransactionCard extends StatelessWidget {
  final UnresolvedTransaction transaction;

  const UnresolvedTransactionCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final unresolvedStore = context.read<UnresolvedStore>();
    final expenseProvider = context.read<ExpenseProvider>();

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primarySoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Merchant
            Text(
              transaction.merchantRaw.isEmpty
                  ? 'Unknown merchant'
                  : transaction.merchantRaw,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 6),

            /// Amount
            Text(
              '₹${transaction.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            /// Date
            Text(
              transaction.dateTime.toString(),
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 12),

            /// Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                /// ❌ Reject
                TextButton(
                  onPressed: () async {
                    final suppressionService =
                        SuppressionService(SuppressionStorage());

                    await suppressionService.recordRejection(transaction);

                    unresolvedStore.reject(transaction.id);
                  },
                  child: const Text(
                    'Reject',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),

                /// ✏️ Edit → OPEN BOTTOM SHEET (FIX)
                TextButton(
                  onPressed: () {
                    showAddExpenseSheet(
                      context,
                      prefillTitle: transaction.merchantRaw.isEmpty
                          ? 'Unknown expense'
                          : transaction.merchantRaw,
                      prefillAmount: transaction.amount,
                      source: 'auto',
                    );
                  },
                  child: Text(
                    'Edit',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),

                /// ✅ Accept
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primarySoft,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final normalizer = ExpenseNormalizer();

                    // 1️⃣ Normalize expense
                    final expense =
                        await normalizer.normalizeFromUnresolved(transaction);

                    // 2️⃣ Save to Firestore
                    await firebaseService.saveExpense(
                      title: expense['title'],
                      amount: expense['amount'],
                      date: expense['date'],
                    );

                    // 3️⃣ Update provider
                    expenseProvider.addExpense(expense);

                    // 4️⃣ Learn merchant behavior
                    await normalizer.learnFromExpense(expense);

                    // 5️⃣ Remove unresolved
                    unresolvedStore.accept(transaction.id);
                  },
                  child: Text(
                    'Accept',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
