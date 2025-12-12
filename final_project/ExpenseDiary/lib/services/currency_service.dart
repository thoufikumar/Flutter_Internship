import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  final String apiUrl = "https://open.er-api.com/v6/latest/USD";

  Future<Map<String, double>?> fetchRates() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Map<String, dynamic> rates = data["rates"];

        return rates.map((key, value) => MapEntry(key, value.toDouble()));
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
