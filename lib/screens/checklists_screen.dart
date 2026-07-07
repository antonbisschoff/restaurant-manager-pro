import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/storage.dart';

class ChecklistsScreen extends StatefulWidget {
  const ChecklistsScreen({super.key});

  @override
  State<ChecklistsScreen> createState() => _ChecklistsScreenState();
}

class _ChecklistsScreenState extends State<ChecklistsScreen>
    with SingleTickerProviderStateMixin {
  static const _templates = {
    'Opening': [
      'Unlock and disarm alarm',
      'Turn on equipment and check temperatures',
      'Count and record opening float',
      'Check deliveries against orders',
      'Prep stations stocked and ready',
      'Front of house clean and set up',
    ], 
    'Shift change': [
      'Cash count handover completed',
      'Outstanding orders briefed to next shift',
        "Stock levels and sold-out items communicated",
      'Cleaning tasks up to date',
      'Any incidents or complaints logged',
    ],
    'Closing': [
      'All equipment cleaned and turned off',
      'Final cash count and safe drop',
      'Waste and stock logged',
      'Rubbish removed, bins cleaned',
      'Doors, windows and safe locked',
      'Alarm armed',
    ],
  };

  late TabController _tabController;
  final Map<String, List<ChecklistItem>> _items = {};
  bool _loading = true;
  late String _today;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _templates.length, vsync: this);
    final now = DateTime.now();
    _today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    _load();
  }

  Future<void> _load() async {
    for (final name in _templates.keys) {
      final saved = await Storage.getChecklist(_today, name);
      if (saved != null) {
        _items[name] = saved;
      } else {
        _items[name] = _templates[name]!
            .asMap()
            .entries
            .map((e) => ChecklistItem(id: '$name-${e.key}', text: e.value))
            .toList();
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _toggle(String name, ChecklistItem item, bool value) async {
    setState(() => item.done = value);
    await Storage.saveChecklist(_today, name, _items[name]!);
  }

  Future<void> _addCustomItem(String name) async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add checklist item'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Item description'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        _items[name]!.add(ChecklistItem(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          text: result,
        ));
      });
      await Storage.saveChecklist(_today, name, _items[name]!);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shift checklists'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _templates.keys.map((k) => Tab(text: k)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _templates.keys.map((name) {
          final items = _items[name]!;
          final done = items.where((i) => i.done).length;
          final progress = items.isEmpty ? 0.0 : done / items.length;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(value: progress, minHeight: 8),
                    const SizedBox(height: 6),
                    Text('$done of ${items.length} complete'),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return CheckboxListTile(
                      value: item.done,
                      title: Text(item.text,
                          style: item.done
                              ? const TextStyle(
                                  decoration: TextDecoration.lineThrough)
                              : null),
                      onChanged: (v) => _toggle(name, item, v ?? false),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton.icon(
                  onPressed: () => _addCustomItem(name),
                  icon: const Icon(Icons.add),
                  label: const Text('Add item for today'),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
