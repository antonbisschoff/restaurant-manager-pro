import 'package:flutter/material.dart';
import '../services/storage.dart';

class FoodCostScreen extends StatefulWidget {
  const FoodCostScreen({super.key});

  @override
  State<FoodCostScreen> createState() => _FoodCostScreenState();
}

class _FoodCostScreenState extends State<FoodCostScreen> {
  final _salesCtrl = TextEditingController();
  final _targetCtrl = TextEditingController(text: '30');
  final _openingCtrl = TextEditingController();
  final _purchasesCtrl = TextEditingController();
  final _closingCtrl = TextEditingController();
  String _currency = 'R';

  @override
  void initState() {
    super.initState();
    Storage.getCurrency().then((c) => setState(() => _currency = c));
  }

  double get _opening => double.tryParse(_openingCtrl.text) ?? 0;
  double get _purchases => double.tryParse(_purchasesCtrl.text) ?? 0;
  double get _closing => double.tryParse(_closingCtrl.text) ?? 0;
  double get _cogs => _opening + _purchases - _closing;
  double get _sales => double.tryParse(_salesCtrl.text) ?? 0;
  double get _foodPct => _sales > 0 ? 100 * _cogs / _sales : 0;
  double get _target => double.tryParse(_targetCtrl.text) ?? 0;

  @override
  void dispose() {
    _salesCtrl.dispose();
    _targetCtrl.dispose();
    _openingCtrl.dispose();
    _purchasesCtrl.dispose();
    _closingCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overTarget = _sales > 0 && _foodPct > _target;
    return Scaffold(
      appBar: AppBar(title: const Text('Food cost calculator')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _salesCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                      labelText: 'Sales ($_currency)', hintText: 'e.g. 42500'),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 110,
                child: TextField(
                  controller: _targetCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(labelText: 'Target %'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Cost of goods sold',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
            controller: _openingCtrl,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
                labelText: 'Opening stock ($_currency)'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _purchasesCtrl,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(labelText: 'Purchases ($_currency)'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _closingCtrl,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration:
                InputDecoration(labelText: 'Closing stock ($_currency)'),
          ),
          const SizedBox(height: 16),
          Card(
            color:
                overTarget ? const Color(0xFFFDECEC) : const Color(0xFFE3F2E8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'COGS: $_currency${_cogs.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _sales > 0
                        ? 'Food cost: ${_foodPct.toStringAsFixed(1)}% of sales '
                            '(target ${_target.toStringAsFixed(1)}%)'
                        : 'Enter sales to calculate food cost %',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: overTarget
                          ? const Color(0xFF8C2F39)
                          : const Color(0xFF1B6B50),
                    ),
                  ),
                  if (_sales > 0 && overTarget)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Over target by $_currency${(_cogs - _sales * _target / 100).toStringAsFixed(2)}. '
                        'Review purchasing and portioning to bring cost back in line.',
                        style: const TextStyle(color: Color(0xFF8C2F39)),
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
