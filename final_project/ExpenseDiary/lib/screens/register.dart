import 'package:expense_tracker_app/provider/ExpenseProvider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/google_auth_service.dart';
import '../provider/currency_provider.dart';
import 'login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _incomeController = TextEditingController();

  String _selectedCurrency = "INR";
  bool _isPasswordVisible = false;
  bool _loading = false;

  // ---------------- VALIDATION ----------------

  bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    final passwordRegex =
        RegExp(r'^(?=.*[A-Z])(?=.*[!@#\$&*~]).{6,}$');
    return passwordRegex.hasMatch(password);
  }

  // ---------------- EMAIL REGISTER ----------------

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final income =
        double.tryParse(_incomeController.text.trim()) ?? 0;

    if (!_isValidEmail(email)) {
      _showError("Enter a valid email");
      return;
    }

    if (!_isValidPassword(password)) {
      _showError(
        "Password must contain 1 uppercase letter and 1 special character",
      );
      return;
    }

    if (income <= 0) {
      _showError("Please enter a valid monthly income");
      return;
    }

    setState(() => _loading = true);

    try {
      // 🔐 Create Firebase account
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final prefs = await SharedPreferences.getInstance();

      // 💾 Save currency
      await prefs.setString("currency", _selectedCurrency);

      // 🔥 RESET onboarding for new user (CRITICAL)
      await prefs.setBool('hasSeenOnboarding', false);

      if (!mounted) return;

      // 💰 Save income
      context
          .read<CurrencyProvider>()
          .setBaseCurrency(_selectedCurrency);

      await context
          .read<ExpenseProvider>()
          .setIncome(income);

      // 🔙 Remove RegisterScreen → AuthGate takes over
      if (mounted) {
        Navigator.of(context).pop();
      }

    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showError("Account already exists. Please login.");
      } else {
        _showError(e.message ?? "Registration failed");
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ---------------- UI HELPERS ----------------

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final currencies = CurrencyProvider.currencySymbols;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Create Account",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4F9792),
                ),
              ),
              const SizedBox(height: 30),

              _inputField("Email", _emailController),
              const SizedBox(height: 14),

              _passwordField(),
              const SizedBox(height: 14),

              _inputField(
                "Monthly Income",
                _incomeController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 18),

              DropdownButtonFormField<String>(
                value: _selectedCurrency,
                decoration: _inputDecoration("Preferred Currency"),
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

              // ---------------- EMAIL REGISTER ----------------

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
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
                      : const Text("Register"),
                ),
              ),

              const SizedBox(height: 16),

              // ---------------- GOOGLE REGISTER ----------------

              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          try {
                            setState(() => _loading = true);

                            await GoogleAuthService.signInWithGoogle(
                              isRegister: true,
                            );

                            final prefs =
                                await SharedPreferences.getInstance();

                            // 🔥 RESET onboarding for new Google user
                            await prefs.setBool(
                                'hasSeenOnboarding', false);

                            if (!mounted) return;

                            // 🔙 Remove RegisterScreen
                            Navigator.of(context).pop();

                          } catch (e) {
                            _showError(
                              "Account already exists. Please login.",
                            );
                          } finally {
                            if (mounted) {
                              setState(() => _loading = false);
                            }
                          }
                        },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    side: const BorderSide(
                      color: Color(0xFF4F9792),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/google.png",
                        height: 24,
                        width: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Register with Google",
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF4F9792),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ---------------- LOGIN LINK ----------------

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Color(0xFF4F9792),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- INPUT WIDGETS ----------------

  Widget _inputField(
    String hint,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _inputDecoration(hint),
    );
  }

  Widget _passwordField() {
    return TextField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: _inputDecoration("Password").copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible
                ? Icons.visibility
                : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      labelText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
  }
}
