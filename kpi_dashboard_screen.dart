class Shift {
  final String id;
  final String employee;
  final String role;
  final int weekday; // 1 = Mon … 7 = Sun
  final String start; // "08:00"
  final String end; // "16:00"

  Shift({
    required this.id,
    required this.employee,
    required this.role,
    required this.weekday,
    required this.start,
    required this.end,
  });

  double get hours {
    final s = _toMinutes(start);
    var e = _toMinutes(end);
    if (e < s) e += 24 * 60; // overnight shift
    return (e - s) / 60.0;
  }

  static int _toMinutes(String t) {
    final parts = t.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  factory Shift.fromJson(Map<String, dynamic> j) => Shift(
        id: j['id'] as String,
        employee: j['employee'] as String? ?? '',
        role: j['role'] as String? ?? '',
        weekday: (j['weekday'] as num?)?.toInt() ?? 1,
        start: j['start'] as String? ?? '08:00',
        end: j['end'] as String? ?? '16:00',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'employee': employee,
        'role': role,
        'weekday': weekday,
        'start': start,
        'end': end,
      };
}

class ChecklistItem {
  final String id;
  final String text;
  bool done;

  ChecklistItem({required this.id, required this.text, this.done = false});

  factory ChecklistItem.fromJson(Map<String, dynamic> j) => ChecklistItem(
        id: j['id'] as String,
        text: j['text'] as String? ?? '',
        done: j['done'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {'id': id, 'text': text, 'done': done};
}

class KpiEntry {
  final String date; // yyyy-MM-dd
  final double sales;
  final double laborCost;
  final double foodCost;
  final int transactions;

  KpiEntry({
    required this.date,
    required this.sales,
    required this.laborCost,
    required this.foodCost,
    required this.transactions,
  });

  double get laborPct => sales > 0 ? 100 * laborCost / sales : 0;
  double get foodPct => sales > 0 ? 100 * foodCost / sales : 0;
  double get avgSpend => transactions > 0 ? sales / transactions : 0;

  factory KpiEntry.fromJson(Map<String, dynamic> j) => KpiEntry(
        date: j['date'] as String,
        sales: (j['sales'] as num?)?.toDouble() ?? 0,
        laborCost: (j['laborCost'] as num?)?.toDouble() ?? 0,
        foodCost: (j['foodCost'] as num?)?.toDouble() ?? 0,
        transactions: (j['transactions'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'sales': sales,
        'laborCost': laborCost,
        'foodCost': foodCost,
        'transactions': transactions,
      };
}

class ChatMessage {
  final String role; // 'user' | 'assistant'
  final String text;

  ChatMessage({required this.role, required this.text});

  factory ChatMessage.fromJson(Map<String, dynamic> j) =>
      ChatMessage(role: j['role'] as String, text: j['text'] as String);

  Map<String, dynamic> toJson() => {'role': role, 'text': text};
}
