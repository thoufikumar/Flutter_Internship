import 'package:expense_tracker_app/auth/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroSplashScreen extends StatelessWidget {
  const IntroSplashScreen({super.key});

  void _goToAuth(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthGate()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F6),
      body: SafeArea(
        child: Column(
          children: [
            /// 🎞️ Animation
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                child: Lottie.asset(
                  'assets/images/second_splash_screen.json',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            /// 🧠 Text + buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  const Text(
                    "Manage Your Expenses Smarter",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F9792),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Track income, expenses and budgets\nall in one place.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// 🔐 Login
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _goToAuth(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F9792),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text("Login"),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// 🆕 Register
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => _goToAuth(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF4F9792)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        "Create Account",
                        style: TextStyle(color: Color(0xFF4F9792)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
