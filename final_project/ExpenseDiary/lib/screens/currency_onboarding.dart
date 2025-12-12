import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/currency_provider.dart';
import 'login.dart';

class CurrencyOnboardingScreen extends StatelessWidget {
  const CurrencyOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context, listen: false);

final currencies = CurrencyProvider.currencySymbols;

    return Scaffold(
      backgroundColor: const Color(0xFF4F9792),
      body: Column(
        children: [
          const SizedBox(height: 80),
          const Text(
            "Choose Your Preferred Currency",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 30),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: GridView.builder(
                itemCount: currencies.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (_, index) {
                  final code = currencies.keys.elementAt(index);
                  final symbol = currencies.values.elementAt(index);

                  return GestureDetector(
                    onTap: () async {
                      currencyProvider.setViewCurrency(code);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.teal.shade200),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(symbol, style: const TextStyle(fontSize: 30)),
                          const SizedBox(height: 6),
                          Text(code,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
