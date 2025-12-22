import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/firebase_collection.dart';
import '../provider/ExpenseProvider.dart';

final firebaseService = FirebaseService();

void showAddExpenseSheet(
  BuildContext context, {
  String source = 'manual', // 'manual' | 'auto'
  String? prefillTitle,
  double? prefillAmount,
  String? prefillCategory,
  bool isOneTime = true,
}) {
  final titleController =
      TextEditingController(text: prefillTitle ?? '');
  final amountController = TextEditingController(
    text: prefillAmount != null
        ? prefillAmount.toStringAsFixed(0)
        : '',
  );

  String? selectedCategory = prefillCategory;
  bool oneTime = isOneTime;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFFF3F7F6),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "Add Expense",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4F9792),
              ),
            ),

            const SizedBox(height: 20),

            // 📝 Title
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Expense name",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // 💰 Amount
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Amount",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // 🏷 Category (optional for all)
            DropdownButtonFormField<String>(
              value: selectedCategory,
              hint: const Text("Category (optional)"),
              items: const [
                DropdownMenuItem(value: 'Food', child: Text('Food')),
                DropdownMenuItem(value: 'Transport', child: Text('Transport')),
                DropdownMenuItem(value: 'Shopping', child: Text('Shopping')),
                DropdownMenuItem(value: 'Bills', child: Text('Bills')),
                DropdownMenuItem(value: 'Entertainment', child: Text('Entertainment')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (v) => selectedCategory = v,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 🔁 One-time toggle
            SwitchListTile(
              value: oneTime,
              onChanged: (v) => oneTime = v,
              title: const Text("One-time expense"),
              subtitle: const Text("Excluded from recurring insights"),
              activeColor: const Color(0xFF4F9792),
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 24),

            // ✅ Save
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F9792),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () async {
                  final title = titleController.text.trim();
                  final amount =
                      double.tryParse(amountController.text.trim());

                  if (title.isEmpty || amount == null || amount <= 0) return;

                  final date = DateTime.now().toIso8601String();

                  await firebaseService.saveExpense(
                    title: title,
                    amount: amount,
                    date: date,
                    source: source,
                    category: selectedCategory,
                    isOneTime: oneTime,
                  );

                  context.read<ExpenseProvider>().addExpense({
                    'title': title,
                    'amount': amount,
                    'date': date,
                    'source': source,
                    'category': selectedCategory,
                    'isOneTime': oneTime,
                  });

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Expense added")),
                  );
                },
                child: const Text(
                  "Add Expense",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
