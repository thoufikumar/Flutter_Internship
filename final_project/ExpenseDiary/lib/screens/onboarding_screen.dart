import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main_navigation.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _finishOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const MainNavigation()),
  );
    }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF4F9792);
    const darkGreen = Color(0xFF3E7C78);

    return IntroductionScreen(
      globalBackgroundColor: Colors.white,

      pages: [
        _page(
          "Add Expenses",
          "Use the + button to quickly add your daily expenses.",
          Icons.add_circle_outline,
          primaryGreen,
          darkGreen,
        ),
        _page(
          "Manage Balance",
          "Edit income and change currency from the balance card.",
          Icons.account_balance_wallet_outlined,
          primaryGreen,
          darkGreen,
        ),
        _page(
          "View Stats",
          "Analyze your expenses and budgets visually.",
          Icons.bar_chart_outlined,
          primaryGreen,
          darkGreen,
        ),
        _page(
          "Budget Planning",
          "Create budget plans to control monthly spending.",
          Icons.savings_outlined,
          primaryGreen,
          darkGreen,
        ),
        _page(
          "Your Profile",
          "Update username and manage your account.",
          Icons.person_outline,
          primaryGreen,
          darkGreen,
        ),
      ],

      showSkipButton: true,
      skip: const Text(
        "Skip",
        style: TextStyle(color: darkGreen, fontWeight: FontWeight.w600),
      ),
      next: const Icon(Icons.arrow_forward, color: primaryGreen),
      done: const Text(
        "Get Started",
        style: TextStyle(
          color: primaryGreen,
          fontWeight: FontWeight.bold,
        ),
      ),

      onDone: () => _finishOnboarding(context),
      onSkip: () => _finishOnboarding(context),

 dotsDecorator: DotsDecorator(
  color: primaryGreen.withOpacity(0.3),
  activeColor: primaryGreen,
  size: const Size(6, 6),
  activeSize: const Size(14, 6),
  spacing: const EdgeInsets.symmetric(horizontal: 4),
  activeShape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
),

    );
  }

  PageViewModel _page(
    String title,
    String body,
    IconData icon,
    Color primaryGreen,
    Color darkGreen,
  ) {
    return PageViewModel(
      title: title,
      body: body,
      image: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryGreen.withOpacity(0.1),
          ),
          child: Icon(
            icon,
            size: 120,
            color: primaryGreen,
          ),
        ),
      ),
      decoration: PageDecoration(
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: darkGreen,
        ),
        bodyTextStyle: TextStyle(
          fontSize: 16,
          color: primaryGreen,
        ),
        imagePadding: const EdgeInsets.only(top: 40),
        contentMargin: const EdgeInsets.symmetric(horizontal: 24),
      ),
    );
  }
}
