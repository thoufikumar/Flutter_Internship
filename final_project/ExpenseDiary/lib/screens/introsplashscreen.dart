import 'dart:async';
import 'package:expense_tracker_app/screens/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';
import 'home.dart';
import '../main.dart';
import '../screens/currency_onboarding.dart'; // Make sure this file exists

class IntroSplashScreen extends StatefulWidget {
  const IntroSplashScreen({super.key});

  @override
  State<IntroSplashScreen> createState() => _IntroSplashScreenState();
}

class _IntroSplashScreenState extends State<IntroSplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkNavigation();
  }

  Future<void> _checkNavigation() async {
  await Future.delayed(const Duration(seconds: 3));

  final prefs = await SharedPreferences.getInstance();
  final selectedCurrency = prefs.getString("currency");

  final user = FirebaseAuth.instance.currentUser;

  if (!mounted) return;

  // 🔥 1. Not logged in → Login/Register
  if (user == null) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SplashScreen()),
    );
    return;
  }

  // 🔥 2. Logged in but currency not selected → Onboarding
  if (selectedCurrency == null) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CurrencyOnboardingScreen()),
    );
    return;
  }

  // 🔥 3. Logged in + currency selected → Home with bottom nav
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const MainNavigation()),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/Splash Screen.png',
              fit: BoxFit.cover,
            ),

            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
