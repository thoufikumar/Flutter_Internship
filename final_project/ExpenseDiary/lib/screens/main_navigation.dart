import 'package:expense_tracker_app/screens/addExpenses.dart';
import 'package:flutter/material.dart';
import 'home.dart';
import 'stats_screen.dart';
import 'budget_planner.dart';
import 'profile_screen.dart';
import 'addExpenses.dart'; // 👈 import your add expense screen

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    StatsScreen(),
    BudgetPlannerScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screens[_currentIndex],

      /// ➕ CENTER FAB (like reference image)
      floatingActionButton: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F9792).withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          elevation: 0,
          backgroundColor: const Color(0xFF4F9792),
          onPressed: () {
            showAddExpenseSheet(context);
          },
          child: const Icon(Icons.add, size: 30),
        ),
      ),

      /// 🔥 THIS IS THE FIX YOU WERE MISSING
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,

      /// 🌿 CUSTOM CURVED NAV BAR
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_rounded, 0),
              _navItem(Icons.bar_chart_rounded, 1),

              /// 👇 space for FAB dip
              const SizedBox(width: 48),

              _navItem(Icons.receipt_long_rounded, 2),
              _navItem(Icons.person_rounded, 3),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔘 Bottom Nav Item
  Widget _navItem(IconData icon, int index) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF4F9792).withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          size: 26,
          color:
              isActive ? const Color(0xFF4F9792) : Colors.black54,
        ),
      ),
    );
  }
}
