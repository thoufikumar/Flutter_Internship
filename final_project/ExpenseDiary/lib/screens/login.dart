import 'package:expense_tracker_app/services/google_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final pwdController = TextEditingController();

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

  // ---------------- EMAIL LOGIN ----------------

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = pwdController.text.trim();

    if (!_isValidEmail(email)) {
      _showError("Enter a valid email");
      return;
    }

    if (!_isValidPassword(password)) {
      _showError(
        "Password must contain 1 uppercase letter & 1 special character",
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // 🚦 NO NAVIGATION — AuthGate handles it
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Login failed");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ---------------- FORGOT PASSWORD ----------------

  Future<void> _forgotPassword() async {
    final email = emailController.text.trim();

    if (!_isValidEmail(email)) {
      _showError("Enter your registered email first");
      return;
    }

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email);
      _showSuccess("Password reset link sent to your email");
    } catch (e) {
      _showError("Failed to send reset email");
    }
  }

  // ---------------- UI HELPERS ----------------

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F6),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Lottie.asset(
                'assets/images/login_lottie.json',
                height: 160,
              ),
              const SizedBox(height: 20),

              const Text(
                "Welcome Back",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4F9792),
                ),
              ),
              const SizedBox(height: 30),

              _inputField("Email", emailController),
              const SizedBox(height: 16),

              _passwordField(),
              const SizedBox(height: 8),

              // 🔐 Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _forgotPassword,
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Color(0xFF4F9792)),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ---------------- GOOGLE LOGIN ----------------

              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          try {
                            await GoogleAuthService
                                .signInWithGoogle(
                              isRegister: false, // 🔥 LOGIN MODE
                            );
                            // 🚦 AuthGate decides screen
                          } catch (e) {
                            _showError(
                              "User not registered. Please register first.",
                            );
                          }
                        },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    side: const BorderSide(
                      color: Color(0xFF4F9792),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 4),
                      Image.asset(
                        "assets/images/google.png",
                        height: 24,
                        width: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Continue with Google",
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF4F9792),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ---------------- REGISTER LINK ----------------

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Register",
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
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      decoration: _decoration(hint),
    );
  }

  Widget _passwordField() {
    return TextField(
      controller: pwdController,
      obscureText: !_isPasswordVisible,
      decoration: _decoration("Password").copyWith(
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

  InputDecoration _decoration(String hint) {
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
