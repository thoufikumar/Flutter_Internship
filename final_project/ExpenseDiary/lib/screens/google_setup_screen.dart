import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/ExpenseProvider.dart';
import '../provider/currency_provider.dart';

class GoogleSetupScreen extends StatefulWidget {
  const GoogleSetupScreen({super.key});

  @override
  State<GoogleSetupScreen> createState() => _GoogleSetupScreenState();
}

class _GoogleSetupScreenState extends State<GoogleSetupScreen> {
  final _incomeController = TextEditingController();
  String _selectedCurrency = "INR";
  bool _loading = false;

  Future<void> _saveSetup() async {
    final income = double.tryParse(_incomeController.text.trim()) ?? 0;

    if (income <= 0) {
      _showError("Enter a valid monthly income");
      return;
    }

    setState(() => _loading = true);

    try {
      // 💾 Save currency locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("currency", _selectedCurrency);

      // 🔄 Update currency provider
      context
          .read<CurrencyProvider>()
          .setBaseCurrency(_selectedCurrency);

      // 🔥 Save income to Firestore + Provider
      await context.read<ExpenseProvider>().setIncome(income);

      // 🚦 DO NOT NAVIGATE
      // AuthGate will auto-route to MainNavigation
    } catch (e) {
      _showError("Setup failed. Please try again.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final currencies = CurrencyProvider.currencySymbols;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F6),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Setup Your Account",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4F9792),
                ),
              ),
              const SizedBox(height: 24),

              TextField(
                controller: _incomeController,
                keyboardType: TextInputType.number,
                decoration: _decoration("Monthly Income"),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedCurrency,
                decoration: _decoration("Preferred Currency"),
                items: currencies.keys.map((code) {
                  return DropdownMenuItem(
                    value: code,
                    child: Text("${currencies[code]}  $code"),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedCurrency = val);
                  }
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _saveSetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F9792),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Text("Continue"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }
}
