import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class Storage {
  static const _kApiKey = 'api_key';
  static const _kProxyUrl = 'proxy_url';
  static const _kCurrency = 'currency';
  static const _kShifts = 'shifts';
  static const _kChecklists = 'checklists'; // keyed by date+name
  static const _kKpis = 'kpi_entries';
  static const _kChat = 'coach_chat';

  static Future<SharedPreferences> get _p async =>
      SharedPreferences.getInstance();

  // ---- API config ----
  static Future<String?> getApiKey() async => (await _p).getString(_kApiKey);
  static Future<void> setApiKey(String v) async =>
      (await _p).setString(_kApiKey, v.trim());
  static Future<String?> getProxyUrl() async =>
      (await _p).getString(_kProxyUrl);
  static Future<void> setProxyUrl(String v) async =>
      (await _p).setString(_kProxyUrl, v.trim());

  // ---- Currency symbol (default Rand) ----
  static Future<String> getCurrency() async =>
      (await _p).getString(_kCurrency) ?? 'R';
  static Future<void> setCurrency(String v) async =>
      (await _p).setString(_kCurrency, v.trim().isEmpty ? 'R' : v.trim());

  // ---- Shifts ----
  static Future<List<Shift>> getShifts() async {
    final raw = (await _p).getString(_kShifts);
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>)
        .map((s) => Shift.fromJson(s as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveShifts(List<Shift> shifts) async {
    (await _p).setString(
        _kShifts, jsonEncode(shifts.map((s) => s.toJson()).toList()));
  }

  // ---- Checklists (state per checklist name per day) ----
  static Future<List<ChecklistItem>?> getChecklist(
      String date, String name) async {
    final raw = (await _p).getString('$_kChecklists:$date:$name');
    if (raw == null) return null;
    return (jsonDecode(raw) as List<dynamic>)
        .map((i) => ChecklistItem.fromJson(i as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveChecklist(
      String date, String name, List<ChecklistItem> items) async {
    (await _p).setString('$_kChecklists:$date:$name',
        jsonEncode(items.map((i) => i.toJson()).toList()));
  }

  // ---- KPI entries ----
  static Future<List<KpiEntry>> getKpis() async {
    final raw = (await _p).getString(_kKpis);
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List<dynamic>)
        .map((e) => KpiEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  static Future<void> saveKpis(List<KpiEntry> entries) async {
    (await _p).setString(
        _kKpis, jsonEncode(entries.map((e) => e.toJson()).toList()));
  }

  // ---- Coach chat history ----
  static Future<List<ChatMessage>> getChat() async {
    final raw = (await _p).getString(_kChat);
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>)
        .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveChat(List<ChatMessage> messages) async {
    (await _p).setString(
        _kChat, jsonEncode(messages.map((m) => m.toJson()).toList()));
  }
}
