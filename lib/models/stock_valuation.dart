class StockValuation {
  final String ticker;
  final double? grahamValue;
  final double? bazinMin;
  final double? bazinMax;
  final double? lpa;
  final double? vpa;
  final double? dividends;
  final String? error;

  StockValuation({
    required this.ticker,
    this.grahamValue,
    this.bazinMin,
    this.bazinMax,
    this.lpa,
    this.vpa,
    this.dividends,
    this.error,
  });

  factory StockValuation.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    if (data == null) {
       return StockValuation(ticker: json['ticker'] ?? 'Unknown', error: 'No data found');
    }
    
    if (data['error'] != null) {
        return StockValuation(ticker: json['ticker'], error: data['error']);
    }
    return StockValuation(
      ticker: json['ticker'],
      grahamValue: data['graham']?['value']?.toDouble(),
      bazinMin: data['bazin']?['low']?.toDouble(),
      bazinMax: data['bazin']?['high']?.toDouble(),
      lpa: data['graham']?['lpa']?.toDouble(),
      vpa: data['graham']?['vpa']?.toDouble(),
      dividends: data['bazin']?['average']?.toDouble(),
    );
  }
}
