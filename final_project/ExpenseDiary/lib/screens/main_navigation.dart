import 'package:flutter/material.dart';
import 'home.dart';
import 'stats_screen.dart';
import 'budget_planner.dart';
import 'addExpenses.dart';
import 'unresolved_transactions_screen.dart';
import 'eve_chat_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),                    // 0
    UnresolvedTransactionsScreen(),  // 1
    SizedBox(),                      // 2 ➕ handled via sheet
    StatsScreen(),                   // 3
    BudgetPlannerScreen(),           // 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  extendBody: true,
  body: _screens[_currentIndex],

 floatingActionButton: Padding(
  padding: const EdgeInsets.only(
    right: 8,
    bottom: 15, // ✅ just ~30px above nav bar
  ),
  child: Container(
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const EveChatScreen(),
          ),
        );
      },
      child: const Icon(
        Icons.chat_bubble_outline,
        size: 28,
      ),
    ),
  ),
),

floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,


      /// 🌿 CUSTOM NAV BAR (NO PROFILE ICON)
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
              _navItem(Icons.inbox_rounded, 1),

              /// ➕ Add Expense
              _navAction(Icons.add_circle_outline),

              _navItem(Icons.bar_chart_rounded, 3),
              _navItem(Icons.receipt_long_rounded, 4),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔘 Normal Nav Item
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
          color: isActive
              ? const Color(0xFF4F9792)
              : Colors.black54,
        ),
      ),
    );
  }

  /// ➕ Add Expense Sheet
  Widget _navAction(IconData icon) {
    return GestureDetector(
      onTap: () {
        showAddExpenseSheet(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(
          icon,
          size: 30,
          color: const Color(0xFF4F9792),
        ),
      ),
    );
  }
}