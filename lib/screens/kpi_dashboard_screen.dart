import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/models.dart';
import '../services/storage.dart';

class KpiDashboardScreen extends StatefulWidget {
  const KpiDashboardScreen({super.key});

  @override
  State<KpiDashboardScreen> createState() => _KpiDashboardScreenState();
}

class _KpiDashboardScreenState extends State<KpiDashboardScreen> {
  List<KpiEntry> _entries = [];
  String _currency = 'R';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await Storage.getKpis();
    final currency = await Storage.getCurrency();
    setState(() {
      _entries = entries;
      _currency = currency;
      _loading = false;
    });
  }

  List<KpiEntry> get _last14 =>
      _entries.length > 14 ? _entries.sublist(_entries.length - 14) : _entries;

  double _avg(Iterable<double> values) {
    final list = values.toList();
    if (list.isEmpty) return 0;
    return list.reduce((a, b) => a + b) / list.length;
  }

  Future<void> _addEntry() async {
    final dateCtrl = TextEditingController(
        text: DateTime.now().toIso8601String().substring(0, 10));
    final salesCtrl = TextEditingController();
    final laborCtrl = TextEditingController();
    final foodCtrl = TextEditingController();
    final txCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log daily KPIs'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: dateCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Date (yyyy-MM-dd)')),
              TextField(
                  controller: salesCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Sales')),
              TextField(
                  controller: laborCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Labor cost')),
              TextField(
                  controller: foodCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Food cost')),
              TextField(
                  controller: txCtrl,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Transactions')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save')),
        ],
      ),
    );

    if (result == true && dateCtrl.text.trim().isNotEmpty) {
      final entry = KpiEntry(
        date: dateCtrl.text.trim(),
        sales: double.tryParse(salesCtrl.text) ?? 0,
        laborCost: double.tryParse(laborCtrl.text) ?? 0,
        foodCost: double.tryParse(foodCtrl.text) ?? 0,
        transactions: int.tryParse(txCtrl.text) ?? 0,
      );
      setState(() {
        _entries.removeWhere((e) => e.date == entry.date);
        _entries.add(entry);
        _entries.sort((a, b) => a.date.compareTo(b.date));
      });
      await Storage.saveKpis(_entries);
    }
  }

  Widget _summaryTile(String label, String value) => Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 12, color: Colors.black.withOpacity(0.6))),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      );

  Widget _trendChart(String title, List<double> values, Color color) {
    if (values.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    for (var i = 0; i < values.length; i++)
                      FlSpot(i.toDouble(), values[i]),
                  ],
                  isCurved: true,
                  color: color,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final last14 = _last14;
    final avgSales = _avg(last14.map((e) => e.sales));
    final avgLaborPct = _avg(last14.map((e) => e.laborPct));
    final avgFoodPct = _avg(last14.map((e) => e.foodPct));

    return Scaffold(
      appBar: AppBar(title: const Text('KPI dashboard')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEntry,
        child: const Icon(Icons.add),
      ),
      body: _entries.isEmpty
          ? const Center(child: Text('No KPI entries logged yet'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    _summaryTile('Avg sales (14d)',
                        '$_currency${avgSales.toStringAsFixed(0)}'),
                    const SizedBox(width: 8),
                    _summaryTile('Avg labor %', '${avgLaborPct.toStringAsFixed(1)}%'),
                    const SizedBox(width: 8),
                    _summaryTile('Avg food %', '${avgFoodPct.toStringAsFixed(1)}%'),
                  ],
                ),
                const SizedBox(height: 24),
                _trendChart('Sales trend', last14.map((e) => e.sales).toList(),
                    const Color(0xFF152238)),
                _trendChart('Labor % trend',
                    last14.map((e) => e.laborPct).toList(),
                    const Color(0xFF8C2F39)),
                _trendChart('Food % trend',
                    last14.map((e) => e.foodPct).toList(),
                    const Color(0xFF1B6B50)),
                const Text('Recent entries',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                for (final e in _entries.reversed.take(14))
                  Card(
                    child: ListTile(
                      title: Text(e.date),
                      subtitle: Text(
                          'Sales $_currency${e.sales.toStringAsFixed(0)} • '
                          'Labor ${e.laborPct.toStringAsFixed(1)}% • '
                          'Food ${e.foodPct.toStringAsFixed(1)}% • '
                          '${e.transactions} txns'),
                    ),
                  ),
              ],
            ),
    );
  }
}
