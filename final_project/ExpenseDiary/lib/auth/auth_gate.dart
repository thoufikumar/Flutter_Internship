import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/ExpenseProvider.dart';
import '../screens/login.dart';
import '../screens/main_navigation.dart';
import '../screens/google_setup_screen.dart';
import '../screens/onboarding_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  // 🔁 Check onboarding status
  Future<bool> _hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasSeenOnboarding') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 🔄 Firebase auth loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ USER LOGGED OUT
        if (!snapshot.hasData) {
          // 🔥 Reset provider state safely
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<ExpenseProvider>().clear();
          });

          return const LoginScreen();
        }

        // ✅ USER LOGGED IN
        final expenseProvider = context.watch<ExpenseProvider>();

        // 🛑 ANTI-FLICKER GUARD
        // Prevents double loading & rebuild loops
        if (expenseProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 📦 Load user income ONLY once
        if (!expenseProvider.isLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            expenseProvider.loadUserIncome();
          });

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 💰 Income not set yet
        if (!expenseProvider.hasIncome) {
          return const GoogleSetupScreen();
        }

        // 🚀 Onboarding flow
        return FutureBuilder<bool>(
          future: _hasSeenOnboarding(),
          builder: (context, onboardingSnapshot) {
            if (onboardingSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (onboardingSnapshot.data == false) {
              return const OnboardingScreen();
            }

            // 🏠 Main app
            return const MainNavigation();
          },
        );
      },
    );
  }
}
