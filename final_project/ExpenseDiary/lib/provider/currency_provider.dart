import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker_app/services/currency_service.dart';

class CurrencyProvider extends ChangeNotifier {
  String _baseCurrency = "INR";   // currency user selected
  String _viewCurrency = "INR";   // currency currently shown (toggle)
  Map<String, double> _rates = {}; // exchange rates relative to USD
  bool _isReady = false;
  bool get isReady => _isReady;


  String get baseCurrency => _baseCurrency;
  String get viewCurrency => _viewCurrency;
  Map<String, double> get rates => _rates;

  static const Map<String, String> currencySymbols = {
    "INR": "₹", "USD": "\$", "EUR": "€", "GBP": "£", "JPY": "¥",
    "AED": "د.إ", "SAR": "ر.س", "AUD": "A\$", "CAD": "C\$",
    "SGD": "S\$", "ZAR": "R", "CHF": "CHF", "KRW": "₩",
    "THB": "฿", "RUB": "₽",
  };

  String get symbol => currencySymbols[_viewCurrency] ?? "₹";

  /// Load saved currency + rates
 Future<void> loadCurrency() async {
  final prefs = await SharedPreferences.getInstance();

  _baseCurrency = prefs.getString("currency") ?? "INR";
  _viewCurrency = _baseCurrency;

  _rates = await CurrencyService().fetchRates() ?? {};

  _isReady = true;
  notifyListeners();
}


  /// Save user's selected base currency (onboarding)
  Future<void> setBaseCurrency(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("currency", code);

    _baseCurrency = code;
    _viewCurrency = code; // reset view to base
    notifyListeners();
  }

  /// For switching display currency only
  void setViewCurrency(String code) {
    _viewCurrency = code;
    notifyListeners();
  }

  /// Load exchange rate table from API
Future<void> loadRates() async {
  _rates = await CurrencyService().fetchRates() ?? {};
}


  /// Actual correct conversion formula
 double convert(double amount) {
  if (!_isReady || _rates.isEmpty) return amount;

  if (_baseCurrency == _viewCurrency) return amount;

  final baseRate = _rates[_baseCurrency] ?? 1.0;
  final viewRate = _rates[_viewCurrency] ?? 1.0;

  return (amount / baseRate) * viewRate;
}
}
