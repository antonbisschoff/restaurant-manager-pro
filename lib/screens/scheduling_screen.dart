import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/storage.dart';

class SchedulingScreen extends StatefulWidget {
  const SchedulingScreen({super.key});

  @override
  State<SchedulingScreen> createState() => _SchedulingScreenState();
}

class _SchedulingScreenState extends State<SchedulingScreen> {
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  List<Shift> _shifts = [];
  int _selectedDay = DateTime.now().weekday; // 1..7
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final shifts = await Storage.getShifts();
    setState(() {
      _shifts = shifts;
      _loading = false;
    });
  }

  Future<void> _save() async {
    await Storage.saveShifts(_shifts);
  }

  List<Shift> get _dayShifts =>
      _shifts.where((s) => s.weekday == _selectedDay).toList()
        ..sort((a, b) => a.start.compareTo(b.start));

  double get _dayTotalHours =>
      _dayShifts.fold(0.0, (sum, s) => sum + s.hours);

  Map<String, double> get _weeklyHoursByEmployee {
    final map = <String, double>{};
    for (final s in _shifts) {
      map[s.employee] = (map[s.employee] ?? 0) + s.hours;
    }
    return map;
  }

  Future<void> _addShift() async {
    final employeeCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    TimeOfDay start = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay end = const TimeOfDay(hour: 16, minute: 0);

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add shift'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: employeeCtrl,
                  decoration: const InputDecoration(labelText: 'Employee'),
                ),
                TextField(
                  controller: roleCtrl,
                  decoration: const InputDecoration(labelText: 'Role'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final picked = await showTimePicker(
                              context: ctx, initialTime: start);
                          if (picked != null) {
                            setDialogState(() => start = picked);
                          }
                        },
                        child: Text('Start: ${start.format(ctx)}'),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final picked = await showTimePicker(
                              context: ctx, initialTime: end);
                          if (picked != null) {
                            setDialogState(() => end = picked);
                          }
                        },
                        child: Text('End: ${end.format(ctx)}'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (result == true && employeeCtrl.text.trim().isNotEmpty) {
      setState(() {
        _shifts.add(Shift(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          employee: employeeCtrl.text.trim(),
          role: roleCtrl.text.trim(),
          weekday: _selectedDay,
          start:
              '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}',
          end:
              '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}',
        ));
      });
      await _save();
    }
  }

  Future<void> _removeShift(Shift s) async {
    setState(() => _shifts.removeWhere((x) => x.id == s.id));
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Staff scheduling')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addShift,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                for (var d = 1; d <= 7; d++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: ChoiceChip(
                        label: Text(_days[d - 1]),
                        selected: _selectedDay == d,
                        onSelected: (_) => setState(() => _selectedDay = d),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Total hours today: ${_dayTotalHours.toStringAsFixed(1)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _dayShifts.isEmpty
                ? const Center(child: Text('No shifts scheduled for this day'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _dayShifts.length,
                    itemBuilder: (context, i) {
                      final s = _dayShifts[i];
                      final weeklyHours =
                          _weeklyHoursByEmployee[s.employee] ?? 0;
                      final overtime = weeklyHours > 45;
                      return Card(
                        child: ListTile(
                          title: Text('${s.employee} — ${s.role}'),
                          subtitle: Text(
                              '${s.start} - ${s.end} (${s.hours.toStringAsFixed(1)}h) '
                              '• week total: ${weeklyHours.toStringAsFixed(1)}h'),
                          subtitleTextStyle: TextStyle(
                            color: overtime ? const Color(0xFF8C2F39) : null,
                            fontWeight:
                                overtime ? FontWeight.w700 : FontWeight.normal,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _removeShift(s),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
