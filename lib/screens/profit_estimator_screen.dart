import 'package:flutter/material.dart';
import '../services/storage.dart';

class ProfitEstimatorScreen extends StatefulWidget {
  const ProfitEstimatorScreen({super.key});

  @override
  State<ProfitEstimatorScreen> createState() => _ProfitEstimatorScreenState();
}

class _ProfitEstimatorScreenState extends State<ProfitEstimatorScreen> {
  final _salesCtrl = TextEditingController();
  final _foodPctCtrl = TextEditingController(text: '30');
  final _laborPctCtrl = TextEditingController(text: '25');
  final _royaltiesPctCtrl = TextEditingController(text: '6');
  final _marketingPctCtrl = TextEditingController(text: '3');
  final _fixedCostsCtrl = TextEditingController();
  String _currency = 'R';

  @override
  void initState() {
    super.initState();
    Storage.getCurrency().then((c) => setState(() => _currency = c));
  }

  double get _sales => double.tryParse(_salesCtrl.text) ?? 0;
  double get _foodPct => double.tryParse(_foodPctCtrl.text) ?? 0;
  double get _laborPct => double.tryParse(_laborPctCtrl.text) ?? 0;
  double get _royaltiesPct => double.tryParse(_royaltiesPctCtrl.text) ?? 0;
  double get _marketingPct => double.tryParse(_marketingPctCtrl.text) ?? 0;
  double get _fixedCosts => double.tryParse(_fixedCostsCtrl.text) ?? 0;

  double get _totalVariablePct =>
      _foodPct + _laborPct + _royaltiesPct + _marketingPct;
  double get _variableCosts => _sales * _totalVariablePct / 100;
  double get _profit => _sales - _variableCosts - _fixedCosts;
  double get _marginPct => _sales > 0 ? 100 * _profit / _sales : 0;

  @override
  void dispose() {
    _salesCtrl.dispose();
    _foodPctCtrl.dispose();
    _laborPctCtrl.dispose();
    _royaltiesPctCtrl.dispose();
    _marketingPctCtrl.dispose();
    _fixedCostsCtrl.dispose();
    super.dispose();
  }

  Widget _pctField(String label, TextEditingController ctrl) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(labelText: label),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final healthy = _marginPct >= 10;
    return Scaffold(
      appBar: AppBar(title: const Text('Profit estimator')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _salesCtrl,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
                labelText: 'Projected monthly sales ($_currency)'),
          ),
          const SizedBox(height: 16),
          const Text('Variable costs (% of sales)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _pctField('Food cost %', _foodPctCtrl),
          _pctField('Labor %', _laborPctCtrl),
          _pctField('Royalties %', _royaltiesPctCtrl),
          _pctField('Marketing %', _marketingPctCtrl),
          const SizedBox(height: 8),
          TextField(
            controller: _fixedCostsCtrl,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
                labelText: 'Fixed costs ($_currency, rent, insurance, etc.)'),
          ),
          const SizedBox(height: 16),
          Card(
            color: healthy ? const Color(0xFFE3F2E8) : const Color(0xFFFDECEC),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Variable costs: $_currency${_variableCosts.toStringAsFixed(2)}'),
                  const SizedBox(height: 4),
                  Text('Fixed costs: $_currency${_fixedCosts.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  Text(
                    'Estimated profit: $_currency${_profit.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Margin: ${_marginPct.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: healthy
                          ? const Color(0xFF1B6B50)
                          : const Color(0xFF8C2F39),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
