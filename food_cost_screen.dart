import 'package:flutter/material.dart';
import '../services/storage.dart';

class LaborCostScreen extends StatefulWidget {
  const LaborCostScreen({super.key});

  @override
  State<LaborCostScreen> createState() => _LaborCostScreenState();
}

class _LaborRow {
  final TextEditingController label = TextEditingController();
  final TextEditingController hours = TextEditingController();
  final TextEditingController rate = TextEditingController();

  double get cost =>
      (double.tryParse(hours.text) ?? 0) * (double.tryParse(rate.text) ?? 0);

  void dispose() {
    label.dispose();
    hours.dispose();
    rate.dispose();
  }
}

class _LaborCostScreenState extends State<LaborCostScreen> {
  final _salesCtrl = TextEditingController();
  final _targetCtrl = TextEditingController(text: '25');
  final List<_LaborRow> _rows = [_LaborRow()];
  String _currency = 'R';

  @override
  void initState() {
    super.initState();
    Storage.getCurrency().then((c) => setState(() => _currency = c));
  }

  double get _totalCost => _rows.fold(0, (sum, r) => sum + r.cost);
  double get _sales => double.tryParse(_salesCtrl.text) ?? 0;
  double get _laborPct => _sales > 0 ? 100 * _totalCost / _sales : 0;
  double get _target => double.tryParse(_targetCtrl.text) ?? 0;

  @override
  void dispose() {
    _salesCtrl.dispose();
    _targetCtrl.dispose();
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overTarget = _sales > 0 && _laborPct > _target;
    return Scaffold(
      appBar: AppBar(title: const Text('Labor cost calculator')),
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
          const Text('Staff hours',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          for (var i = 0; i < _rows.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _rows[i].label,
                      decoration: const InputDecoration(
                          labelText: 'Role / name', hintText: 'Cashier'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _rows[i].hours,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(labelText: 'Hours'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _rows[i].rate,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(labelText: '$_currency/hr'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: _rows.length == 1
                        ? null
                        : () => setState(() => _rows.removeAt(i).dispose()),
                  ),
                ],
              ),
            ),
          TextButton.icon(
            onPressed: () => setState(() => _rows.add(_LaborRow())),
            icon: const Icon(Icons.add),
            label: const Text('Add row'),
          ),
          const SizedBox(height: 8),
          Card(
            color: overTarget ? const Color(0xFFFDECEC) : const Color(0xFFE3F2E8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Total labor cost: $_currency${_totalCost.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    _sales > 0
                        ? 'Labor: ${_laborPct.toStringAsFixed(1)}% of sales '
                            '(target ${_target.toStringAsFixed(1)}%)'
                        : 'Enter sales to calculate labor %',
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
                        'Over target by $_currency${(_totalCost - _sales * _target / 100).toStringAsFixed(2)}. '
                        'Consider cutting ${((_totalCost - _sales * _target / 100) / _avgRate()).toStringAsFixed(1)} hours at the average rate.',
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

  double _avgRate() {
    final totalHours =
        _rows.fold<double>(0, (s, r) => s + (double.tryParse(r.hours.text) ?? 0));
    return totalHours > 0 ? _totalCost / totalHours : 1;
  }
}
