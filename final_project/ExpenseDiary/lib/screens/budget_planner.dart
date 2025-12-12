import 'package:flutter/material.dart';
import '../controllers/firebase_collection.dart';
import 'package:provider/provider.dart';
import '../provider/currency_provider.dart';

final firebaseService = FirebaseService();

class BudgetPlannerScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddToStats;

  const BudgetPlannerScreen({super.key, required this.onAddToStats});

  @override
  State<BudgetPlannerScreen> createState() => _BudgetPlannerScreenState();
}

class _BudgetPlannerScreenState extends State<BudgetPlannerScreen> {
  final _incomeController = TextEditingController();
  final Map<String, TextEditingController> _categoryControllers = {
    'Food': TextEditingController(),
    'Rent': TextEditingController(),
    'Transport': TextEditingController(),
    'Entertainment': TextEditingController(),
    'Savings': TextEditingController(),
  };

  double _income = 0;
  double _totalAllocated = 0;
  double _remaining = 0;
  bool _calculated = false;

  void _calculate(String symbol) {
    setState(() {
      _income = double.tryParse(_incomeController.text.trim()) ?? 0;
      _totalAllocated = 0;

      for (var controller in _categoryControllers.values) {
        _totalAllocated += double.tryParse(controller.text) ?? 0;
      }

      _remaining = _income - _totalAllocated;
      _calculated = true;
    });

    _showPopupDialog(
      "Calculation Done",
      _remaining >= 0
          ? "You have $symbol${_remaining.toStringAsFixed(2)} remaining."
          : "You're over budget by $symbol${_remaining.abs().toStringAsFixed(2)}.",
    );
  }

  Future<void> _submitPlan(String symbol) async {
    _income = double.tryParse(_incomeController.text.trim()) ?? 0;
    if (_income <= 0) {
      _showPopupDialog("Invalid Input", "Please enter a valid income amount.");
      return;
    }

    final Map<String, double> categories = {};
    _totalAllocated = 0;

    _categoryControllers.forEach((key, controller) {
      final value = double.tryParse(controller.text) ?? 0;
      _totalAllocated += value;
      categories[key] = value;
    });

    final budgetPlan = {
      'title': 'Monthly Budget',
      'amount': _totalAllocated,
      'income': _income,
      'date': DateTime.now().toString(),
      'categories': categories,
    };

    try {
      await firebaseService.saveBudget(
        title: 'Monthly Budget',
        amount: _totalAllocated,
        income: _income,
        date: DateTime.now().toString(),
        categories: categories,
      );

      widget.onAddToStats(budgetPlan);
      Navigator.pop(context);
      _showPopupDialog("Success", "Budget plan saved successfully!");
    } catch (e) {
      _showPopupDialog("Error", "Error saving budget: $e");
    }
  }

  void _showPopupDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _categoryControllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black87),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  @override
  Widget build(BuildContext context) {
    final symbol = Provider.of<CurrencyProvider>(context).symbol;

    return Scaffold(
      backgroundColor: const Color(0xFFEDF4F3),
      appBar: AppBar(
        title: const Text('Budget Planner', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF4F9792),
        elevation: 4,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 3))],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _incomeController,
                keyboardType: TextInputType.number,
                decoration: _inputStyle('Monthly Income ($symbol)'),
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Text('Allocate Budget:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          ..._categoryControllers.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 3))],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: entry.value,
                    keyboardType: TextInputType.number,
                    decoration: _inputStyle('${entry.key} Budget ($symbol)'),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => _calculate(symbol),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F9792),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: const Icon(Icons.calculate, color: Colors.white),
                label: const Text('Calculate', style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton.icon(
                onPressed: () => _submitPlan(symbol),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[700],
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: const Icon(Icons.add_chart, color: Colors.white),
                label: const Text('Add to Stats', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (_calculated)
            Card(
              color: _remaining >= 0 ? Colors.green[50] : Colors.red[50],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Allocated: $symbol${_totalAllocated.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _remaining >= 0
                          ? 'Remaining Budget: $symbol${_remaining.toStringAsFixed(2)}'
                          : 'Over Budget by $symbol${_remaining.abs().toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _remaining >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
