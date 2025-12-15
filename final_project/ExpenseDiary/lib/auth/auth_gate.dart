import 'package:expense_tracker_app/screens/introsplashscreen.dart';
import 'package:expense_tracker_app/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/ExpenseProvider.dart';
import '../screens/login.dart';
import '../screens/main_navigation.dart';
import '../screens/google_setup_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<bool> _hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasSeenOnboarding') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const IntroSplashScreen();
        }

        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        final expenseProvider = context.watch<ExpenseProvider>();

        if (!expenseProvider.isLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            expenseProvider.loadUserIncome();
          });
          return const IntroSplashScreen();
        }

        if (!expenseProvider.hasIncome) {
          return const GoogleSetupScreen();
        }

        return FutureBuilder<bool>(
          future: _hasSeenOnboarding(),
          builder: (context, onboardingSnapshot) {
            if (!onboardingSnapshot.hasData) {
              return const IntroSplashScreen();
            }

            if (onboardingSnapshot.data == false) {
              return const OnboardingScreen();
            }

            return const MainNavigation();
          },
        );
      },
    );
  }
}

