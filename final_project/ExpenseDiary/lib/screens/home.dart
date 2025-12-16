import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../provider/currency_provider.dart';
import '../provider/ExpenseProvider.dart';
import 'addExpenses.dart';

String getUserNameFromAuth(User? user) {
  if (user == null) return "User";

  // 1️⃣ Highest priority: user-set display name
  final displayName = user.displayName;
  if (displayName != null && displayName.trim().isNotEmpty) {
    return displayName.trim();
  }

  // 2️⃣ Fallback: derive from email
  final email = user.email;
  if (email != null && email.contains('@')) {
    final namePart = email.split('@').first;

    // Clean common separators and capitalize
    final cleaned = namePart.replaceAll(RegExp(r'[._]'), ' ');
    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }

  // 3️⃣ Absolute fallback
  return "User";
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
@override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final provider = context.read<ExpenseProvider>();
    if (!provider.sessionInitialized) {
      provider.loadAll();
    }
  });
}


  Widget _buildAmountInfoWhite(String label, double amount, String symbol) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.white70)),
        const SizedBox(height: 4),
        Text(
          '$symbol${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();

final user = FirebaseAuth.instance.currentUser;
final displayName = getUserNameFromAuth(user);

    if (!currencyProvider.isReady || expenseProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final symbol = currencyProvider.symbol;

    return Scaffold(
      backgroundColor: const Color(0xFF4F9792),

      body: Column(
        children: [
          const SizedBox(height: 50),
          

          /// ⭐ Welcome Header
          Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: Row(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: user?.photoURL != null
            ? Image.network(
                user!.photoURL!,
                width: 55,
                height: 55,
                fit: BoxFit.cover,
              )
            : Image.asset(
                'assets/images/profile.jpg',
                width: 55,
                height: 55,
                fit: BoxFit.cover,
              ),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Text(
          "Welcome back, $displayName!",
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  ),
),

const SizedBox(height: 20),

  /// ⭐ Balance Card
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 24),
  child: Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF3E7C78),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Your Balance",
          style: TextStyle(fontSize: 15, color: Colors.white70),
        ),
        const SizedBox(height: 8),

        /// 💰 BALANCE ROW
        Row(
          children: [
            Expanded(
              child: Text(
                "$symbol${currencyProvider.convert(expenseProvider.balance).toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            /// 🔁 Currency Switch
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) {
                    return ListView(
                      children: CurrencyProvider.currencySymbols.entries.map((entry) {
                        return ListTile(
                          leading: Text(entry.value, style: const TextStyle(fontSize: 22)),
                          title: Text(entry.key),
                          onTap: () {
                            currencyProvider.setViewCurrency(entry.key);
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    );
                  },
                );
              },
              child: const Icon(Icons.swap_horiz, color: Colors.white),
            ),
          ],
        ),

        const SizedBox(height: 16),

        /// 📊 INCOME + EXPENSES
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// 🟢 INCOME (editable)
            _buildIncomeEditable(
              context,
              currencyProvider,
              expenseProvider,
              symbol,
            ),

            /// 🔴 EXPENSES
            _buildAmountInfoWhite(
              "Expenses",
              currencyProvider.convert(expenseProvider.totalExpenses),
              symbol,
            ),
          ],
        ),
      ],
    ),
  ),
),


          /// ⭐ White Panel
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.only(top: 20),
                children: [
                  const Text(
                    "Top Expenses",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),

                  if (expenseProvider.topExpenses.isEmpty)
                    const Text("No expenses added yet."),

                  ...expenseProvider.topExpenses.map((expense) {
                    final amount = currencyProvider.convert(expense['amount']);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.trending_down, color: Colors.redAccent),
                        title: Text(expense['title']),
                        subtitle: Text(expense['date']),
                        trailing: Text(
                          "$symbol${amount.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
Widget _buildIncomeEditable(
  BuildContext context,
  CurrencyProvider currencyProvider,
  ExpenseProvider expenseProvider,
  String symbol,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Text(
            "Income",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),

          /// ✏️ Subtle edit icon (on-theme)
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _showEditIncomeSheet(context, expenseProvider),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      Text(
        "$symbol${currencyProvider.convert(expenseProvider.totalIncome).toStringAsFixed(2)}",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ],
  );
}

void _showEditIncomeSheet(
  BuildContext context,
  ExpenseProvider expenseProvider,
) {
  final controller = TextEditingController(
    text: expenseProvider.totalIncome.toStringAsFixed(0),
  );

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
            /// Handle bar
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
              "Edit Monthly Income",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4F9792),
              ),
            ),

            const SizedBox(height: 20),

            /// 💰 Input field
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                labelText: "Monthly Income",
                labelStyle: const TextStyle(color: Color(0xFF4F9792)),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(
                  Icons.currency_rupee,
                  color: Color(0xFF4F9792),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),

            const SizedBox(height: 24),

            /// ✅ Save button (on-brand)
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
                  final income =
                      double.tryParse(controller.text.trim()) ?? 0;

                  if (income <= 0) return;

                  await expenseProvider.setIncome(income);
                  Navigator.pop(context);
                },
                child: const Text(
                  "Update Income",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}