import 'package:flutter/material.dart';
import 'services/stock_service.dart';
import 'models/stock_valuation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valor Intrísenco',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  final StockService _stockService = StockService();
  StockValuation? _valuation;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _fetchValuation() async {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    final ticker = _controller.text.trim().toUpperCase();
    if (ticker.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _valuation = null;
    });

    try {
      final valuation = await _stockService.getValuation(ticker);
      setState(() {
        _valuation = valuation;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao buscar dados. Verifique o ticker.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Valor Intrínseco',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'ex: BBAS3',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        onSubmitted: (_) => _fetchValuation(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _fetchValuation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Calcular'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null)
                  Card(
                    color: Colors.red.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                if (_valuation != null) ...[
                  if (_valuation!.error != null)
                    Card(
                      color: Colors.orange.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Erro: ${_valuation!.error}',
                          style: const TextStyle(color: Colors.orange),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else ...[
                    _buildGrahamCard(_valuation!),
                    const SizedBox(height: 16),
                    _buildBazinCard(_valuation!),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrahamCard(StockValuation valuation) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Método Graham',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LPA: R\$ ${valuation.lpa?.toStringAsFixed(2) ?? "N/A"}'),
                  const SizedBox(height: 4),
                  Text('VPA: R\$ ${valuation.vpa?.toStringAsFixed(2) ?? "N/A"}'),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Valor Intrínseco:'),
                  Text(
                    'R\$ ${valuation.grahamValue?.toStringAsFixed(2) ?? "N/A"}',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBazinCard(StockValuation valuation) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Método Bazin',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Dividendos médios anuais (3 anos):'),
              const SizedBox(height: 4),
              Text(
                'R\$ ${valuation.dividends?.toStringAsFixed(2) ?? "N/A"}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text('Faixa de Valuation:'),
              Text(
                'R\$ ${valuation.bazinMin?.toStringAsFixed(2) ?? "N/A"} - R\$ ${valuation.bazinMax?.toStringAsFixed(2) ?? "N/A"}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 4),
              const Text(
                '(Yield de 6% a 10%)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
