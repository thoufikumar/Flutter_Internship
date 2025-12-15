import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/firebase_collection.dart';
import '../provider/currency_provider.dart';

class BudgetPlannerScreen extends StatefulWidget {
  const BudgetPlannerScreen({super.key});

  @override
  State<BudgetPlannerScreen> createState() => _BudgetPlannerScreenState();
}

class _BudgetPlannerScreenState extends State<BudgetPlannerScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  double _monthlyIncome = 0;
  double _totalAllocated = 0;
  double _remaining = 0;
  bool _calculated = false;
  bool _saving = false;

  final Map<String, TextEditingController> _categoryControllers = {
    'Food': TextEditingController(),
    'Rent': TextEditingController(),
    'Transport': TextEditingController(),
    'Entertainment': TextEditingController(),
    'Savings': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _loadIncome();
  }

  Future<void> _loadIncome() async {
    final income = await _firebaseService.getIncome();
    if (!mounted) return;

    setState(() {
      _monthlyIncome = income;
    });
  }

  Map<String, double> _getCategories() {
    final Map<String, double> categories = {};
    _totalAllocated = 0;

    for (var entry in _categoryControllers.entries) {
      final value = double.tryParse(entry.value.text) ?? 0;
      categories[entry.key] = value;
      _totalAllocated += value;
    }

    return categories;
  }

  void _calculate(String symbol) {
    setState(() {
      _totalAllocated = 0;

      for (var controller in _categoryControllers.values) {
        _totalAllocated += double.tryParse(controller.text) ?? 0;
      }

      _remaining = _monthlyIncome - _totalAllocated;
      _calculated = true;
    });

    _showDialog(
      "Calculation Done",
      _remaining >= 0
          ? "Remaining: $symbol${_remaining.toStringAsFixed(2)}"
          : "Over Budget by: $symbol${_remaining.abs().toStringAsFixed(2)}",
    );
  }

 Future<void> _submitPlan(String symbol) async {
  if (_monthlyIncome <= 0) {
    await _showDialog(
      "Income Missing",
      "Please set your monthly income in Home Screen first.",
    );
    return;
  }

  if (_saving) return;
  _saving = true;

  try {
    final categories = _getCategories();

    // 🚫 VALIDATION: no empty budget allowed
    if (_totalAllocated <= 0) {
      await _showDialog(
        "Invalid Budget",
        "Please allocate at least one category amount before saving.",
      );
      return;
    }

    await _firebaseService.saveBudget(
      title: 'Monthly Budget',
      amount: _totalAllocated,
      income: _monthlyIncome,
      date: DateTime.now().toIso8601String(),
      categories: categories,
    );

    if (!mounted) return;

    // ✅ Success dialog only
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Success"),
          content: const Text("Budget plan saved successfully!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );

  } catch (e) {
    if (!mounted) return;
    await _showDialog("Error", "Failed to save budget.");
  } finally {
    _saving = false;
  }
}


  Future<void> _showDialog(String title, String message) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    for (var controller in _categoryControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final symbol = context.watch<CurrencyProvider>().symbol;

    return Scaffold(
      backgroundColor: const Color(0xFFEDF4F3),
      appBar: AppBar(
        title: const Text('Budget Planner'),
        backgroundColor: const Color(0xFF4F9792),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: ListTile(
              title: const Text("Monthly Income"),
              trailing: Text(
                "$symbol${_monthlyIncome.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Text("Allocate Budget",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

          ..._categoryControllers.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: TextField(
                controller: entry.value,
                keyboardType: TextInputType.number,
                decoration: _inputStyle("${entry.key} Budget ($symbol)"),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
  children: [
    /// 🧮 Calculate Button (Outlined – secondary)
    Expanded(
      child: SizedBox(
        height: 50,
        child: OutlinedButton.icon(
          onPressed: () => _calculate(symbol),
          icon: const Icon(Icons.calculate, size: 20),
          label: const Text(
            "Calculate",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF4F9792),
            side: const BorderSide(color: Color(0xFF4F9792), width: 1.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
        ),
      ),
    ),

    const SizedBox(width: 14),

    /// 💾 Save Plan Button (Primary – filled)
    Expanded(
      child: SizedBox(
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _saving ? null : () => _submitPlan(symbol),
          icon: _saving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save, size: 20),
          label: Text(
            _saving ? "Saving..." : "Save Plan",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F9792),
            disabledBackgroundColor:
                const Color(0xFF4F9792).withOpacity(0.6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
        ),
      ),
    ),
  ],
),


          if (_calculated)
            Card(
              margin: const EdgeInsets.only(top: 20),
              color: _remaining >= 0 ? Colors.green[50] : Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _remaining >= 0
                      ? "Remaining: $symbol${_remaining.toStringAsFixed(2)}"
                      : "Over Budget by: $symbol${_remaining.abs().toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
