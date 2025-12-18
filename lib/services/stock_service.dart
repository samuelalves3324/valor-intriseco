import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock_valuation.dart';

class StockService {
  static const String _baseUrl = 'https://stock-valuation-api.samucahhh.workers.dev/api/stock';

  Future<StockValuation> getValuation(String ticker) async {
    final response = await http.get(Uri.parse('$_baseUrl/$ticker'));

    if (response.statusCode == 200) {
      return StockValuation.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load stock data');
    }
  }
}
