import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import 'storage.dart';

class ClaudeService {
  static const String _anthropicUrl = 'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-sonnet-4-6';

  static const String _coachSystemPrompt =
      'You are an experienced multi-unit restaurant operations coach advising a store manager. '
      'You know QSR economics: labor % targets, food cost variance, speed of service, '
      'shift management, rostering to sales forecasts, cash controls, and people leadership. '
      'Give practical, specific advice a manager can act on during today\'s shift. '
      'Ask one clarifying question when the situation is ambiguous. '
      'Keep answers under 200 words unless asked for detail. Use plain text, no markdown symbols.';

  /// Sends the full chat history and returns the coach's reply.
  Future<String> coach(List<ChatMessage> history) async {
    final apiKey = await Storage.getApiKey();
    final proxyUrl = await Storage.getProxyUrl();

    final body = <String, dynamic>{
      'model': _model,
      'max_tokens': 1000,
      'system': _coachSystemPrompt,
      'messages': history
          .map((m) => {'role': m.role, 'content': m.text})
          .toList(),
    };

    final Uri uri;
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (proxyUrl != null && proxyUrl.isNotEmpty) {
      uri = Uri.parse(proxyUrl);
    } else if (apiKey != null && apiKey.isNotEmpty) {
      uri = Uri.parse(_anthropicUrl);
      headers['x-api-key'] = apiKey;
      headers['anthropic-version'] = '2023-06-01';
    } else {
      throw Exception(
          'No API access configured. Open Settings and add a proxy URL or API key.');
    }

    final res = await http
        .post(uri, headers: headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 60));

    if (res.statusCode != 200) {
      throw Exception('API error ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final blocks = data['content'] as List<dynamic>? ?? [];
    return blocks
        .where((b) => b['type'] == 'text')
        .map((b) => b['text'] as String)
        .join('\n')
        .trim();
  }
}
