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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _shifts = await Storage.getShifts();
    setState(() {});
  }

  Future<void> _save() async => Storage.saveShifts(_shifts);

  Map<String, double> get _weeklyHoursByEmployee {
    final map = <String, double>{};
    for (final s in _shifts) {
      map[s.employee] = (map[s.employee] ?? 0) + s.hours;
    }
    return map;
  }

  Future<void> _addOrEdit({Shift? existing}) async {
    final employee = TextEditingController(text: existing?.employee ?? '');
    final role = TextEditingController(text: existing?.role ?? '');
    var start = existing != null ? _parse(existing.start) : const TimeOfDay(hour: 8, minute: 0);
    var end = existing != null ? _parse(existing.end) : const TimeOfDay(hour: 16, minute: 0);

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Text(existing == null ? 'Add shift' : 'Edit shift'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: employee,
                  decoration: const InputDecoration(labelText: 'Employee')),
              const SizedBox(height: 8),
              TextField(
                  controller: role,
                  decoration: const InputDecoration(
                      labelText: 'Role', hintText: 'Cashier / Cook / Shift lead')),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final t = await showTimePicker(
                            context: ctx, initialTime: start);
                        if (t != null) setDialog(() => start = t);
                      },
                      child: Text('Start ${_fmt(start)}'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final t =
                            await showTimePicker(context: ctx, initialTime: end);
                        if (t != null) setDialog(() => end = t);
                      },
                      child: Text('End ${_fmt(end)}'),
                    ),
                  ),
                ],
              ),
            ],
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
      ),
    );

    if (saved != true || employee.text.trim().isEmpty) return;

    final shift = Shift(
      id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      employee: employee.text.trim(),
      role: role.text.trim(),
      weekday: _selectedDay,
      start: _fmt(start),
      end: _fmt(end),
    );

    setState(() {
      if (existing != null) {
        final i = _shifts.indexWhere((s) => s.id == existing.id);
        _shifts[i] = shift;
      } else {
        _shifts.add(shift);
      }
    });
    await _save();
  }

  TimeOfDay _parse(String t) {
    final p = t.split(':');
    return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final dayShifts = _shifts.where((s) => s.weekday == _selectedDay).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    final dayHours = dayShifts.fold<double>(0, (s, sh) => s + sh.hours);
    final weekly = _weeklyHoursByEmployee;

    return Scaffold(
      appBar: AppBar(title: const Text('Staff scheduling')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF152238),
        foregroundColor: Colors.white,
        onPressed: () => _addOrEdit(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: 7,
              itemBuilder: (_, i) {
                final day = i + 1;
                final selected = day == _selectedDay;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_days[i]),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedDay = day),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('${dayShifts.length} shifts · ${dayHours.toStringAsFixed(1)} hours rostered',
                    style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          Expanded(
            child: dayShifts.isEmpty
                ? const Center(
                    child: Text('No shifts for this day yet. Tap + to add one.',
                        style: TextStyle(color: Colors.black45)))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      for (final s in dayShifts)
                        Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text(s.employee,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(
                                '${s.role.isEmpty ? 'No role' : s.role} · ${s.start}–${s.end} (${s.hours.toStringAsFixed(1)}h) · ${ (weekly[s.employee] ?? 0).toStringAsFixed(1)}h this week'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                setState(() =>
                                    _shifts.removeWhere((x) => x.id == s.id));
                                await _save();
                              },
                            ),
                            onTap: () => _addOrEdit(existing: s),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
