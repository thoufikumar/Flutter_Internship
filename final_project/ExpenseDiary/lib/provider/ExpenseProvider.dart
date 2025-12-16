import 'package:flutter/material.dart';
import '../controllers/firebase_collection.dart';

class ExpenseProvider extends ChangeNotifier {
  final FirebaseService _service = FirebaseService();

  // ─────────────── STATE ───────────────

  List<Map<String, dynamic>> _expenses = [];
  List<Map<String, dynamic>> _budgets = [];

  double _monthlyIncome = 0;

  bool _loading = false;
  bool _loaded = false;

  // 🔥 SESSION FLAG (MUST BE INSIDE CLASS)
  bool _sessionInitialized = false;

  // ─────────────── GETTERS ───────────────

  List<Map<String, dynamic>> get expenses => _expenses;
  List<Map<String, dynamic>> get budgets => _budgets;

  bool get isLoading => _loading;
  bool get isLoaded => _loaded;

  bool get sessionInitialized => _sessionInitialized;

  double get totalIncome => _monthlyIncome;

  bool get hasIncome => _monthlyIncome > 0;

  double get totalExpenses =>
      _expenses.fold(0, (sum, item) => sum + (item['amount'] ?? 0));

  double get balance => totalIncome - totalExpenses;

  List<Map<String, dynamic>> get topExpenses {
    final list = [..._expenses];
    list.sort(
      (a, b) =>
          (b['amount'] as double).compareTo(a['amount'] as double),
    );
    return list.take(3).toList();
  }

  // ─────────────── CORE METHODS ───────────────

  /// 🔥 Used by AuthGate
  Future<void> loadUserIncome() async {
    _loaded = false;
    notifyListeners();

    _monthlyIncome = await _service.getIncome();

    _loaded = true;
    notifyListeners();
  }

  /// 🔥 Load app data ONCE per login
  Future<void> loadAll() async {
    if (_sessionInitialized) return;

    _sessionInitialized = true;
    _loading = true;
    notifyListeners();

    _monthlyIncome = await _service.getIncome();
    _expenses = await _service.getExpenses();
    _budgets = await _service.getBudgets();

    _loading = false;
    notifyListeners();
  }

  /// 🔥 Save income
  Future<void> setIncome(double income) async {
    _monthlyIncome = income;
    notifyListeners();

    await _service.saveIncome(income);
  }

  /// 🔥 Add expense locally
  void addExpense(Map<String, dynamic> expense) {
    _expenses.insert(0, expense);
    notifyListeners();
  }

  /// 🔥 Logout reset (ONLY place this should happen)
  void clear() {
    _expenses = [];
    _budgets = [];
    _monthlyIncome = 0;

    _loading = false;
    _loaded = false;
    _sessionInitialized = false;

    notifyListeners();
  }
}
