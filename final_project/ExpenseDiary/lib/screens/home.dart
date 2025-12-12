import 'dart:ui';
import 'package:flutter/material.dart';
import '../controllers/firebase_collection.dart';
import 'addExpenses.dart';
import 'package:provider/provider.dart';
import '../provider/currency_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final firebaseService = FirebaseService();
  List<Map<String, dynamic>> _expenses = [];
  List<Map<String, dynamic>> _budgetPlan = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    Provider.of<CurrencyProvider>(context, listen: false).loadCurrency();
  }

  Future<void> _loadUserData() async {
    final expenses = await firebaseService.getExpenses();
    final budgets = await firebaseService.getBudgets();
    setState(() {
      _expenses = expenses;
      _budgetPlan = budgets;
    });
  }

  void _navigateToAddExpense() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() => _expenses.add(result));
    }
  }

  double get totalIncome =>
      _budgetPlan.fold(0, (sum, item) => sum + (item['income'] ?? 0));

  double get totalExpenses =>
      _expenses.fold(0, (sum, item) => sum + (item['amount'] ?? 0));

  double get currentBalance => totalIncome - totalExpenses;

  List<Map<String, dynamic>> get topExpenses {
    final list = [..._expenses];
    list.sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));
    return list.take(3).toList();
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
    final provider = Provider.of<CurrencyProvider>(context);
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? "User";

    return Scaffold(
      backgroundColor: const Color(0xFF4F9792),

      body: Column(
        children: [
          const SizedBox(height: 50),

          // ⭐ Welcome Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
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

          // ⭐ Balance Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
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
              padding: const EdgeInsets.all(20),

              child: Consumer<CurrencyProvider>(
                builder: (context, provider, _) {
                  final symbol = CurrencyProvider.currencySymbols[provider.viewCurrency]!;
                  final convertedBalance = provider.convert(currentBalance);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Your Balance",
                          style: TextStyle(fontSize: 15, color: Colors.white70)),
                      const SizedBox(height: 8),

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
                                    title: Text(entry.key, style: const TextStyle(fontSize: 18)),
                                    onTap: () {
                                      provider.setViewCurrency(entry.key);
                                      Navigator.pop(context);
                                    },
                                  );
                                }).toList(),
                              );
                            },
                          );
                        },
                        child: Text(
                          "$symbol${convertedBalance.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Showing in ${provider.viewCurrency}",
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),

                      const SizedBox(height: 14),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildAmountInfoWhite("Income", provider.convert(totalIncome), symbol),
                          _buildAmountInfoWhite("Expenses", provider.convert(totalExpenses), symbol),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // ⭐ White Panel
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),

              child: Consumer<CurrencyProvider>(
                builder: (context, provider, _) {
                  final symbol = provider.symbol;

                  return ListView(
                    padding: const EdgeInsets.only(top: 20),

                    children: [
                      const Text(
                        "Top Expenses",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 14),

                      if (topExpenses.isEmpty)
                        const Text("No expenses added yet."),

                      ...topExpenses.map((expense) {
                        final convertedAmount = provider.convert(expense['amount']);

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
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.trending_down, color: Colors.redAccent),
                            ),
                            title: Text(expense['title'],
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(expense['date']),
                            trailing: Text(
                              "$symbol${convertedAmount.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddExpense,
        backgroundColor: const Color(0xFF4F9792),
        child: const Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
