import 'package:flutter/material.dart';
import '../services/storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _currencyCtrl = TextEditingController();
  final _apiKeyCtrl = TextEditingController();
  final _proxyUrlCtrl = TextEditingController();
  bool _loading = true;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final currency = await Storage.getCurrency();
    final apiKey = await Storage.getApiKey();
    final proxyUrl = await Storage.getProxyUrl();
    setState(() {
      _currencyCtrl.text = currency;
      _apiKeyCtrl.text = apiKey ?? '';
      _proxyUrlCtrl.text = proxyUrl ?? '';
      _loading = false;
    });
  }

  Future<void> _save() async {
    await Storage.setCurrency(_currencyCtrl.text);
    await Storage.setApiKey(_apiKeyCtrl.text);
    await Storage.setProxyUrl(_proxyUrlCtrl.text);
    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  @override
  void dispose() {
    _currencyCtrl.dispose();
    _apiKeyCtrl.dispose();
    _proxyUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Currency symbol',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
            controller: _currencyCtrl,
            decoration: const InputDecoration(
                labelText: 'Currency symbol', hintText: 'R'),
          ),
          const SizedBox(height: 24),
          const Text('AI coach API access',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            'Use a proxy URL for production so your API key is never shipped '
            'inside the app. An API key here is only intended for testing.',
            style: TextStyle(fontSize: 13, color: Colors.black.withOpacity(0.6)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _proxyUrlCtrl,
            decoration: const InputDecoration(
                labelText: 'Proxy URL (production)',
                hintText: 'https://your-proxy.example.com/api/claude'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _apiKeyCtrl,
            obscureText: true,
            decoration: const InputDecoration(
                labelText: 'Anthropic API key (testing only)'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _save,
            child: Text(_saved ? 'Saved' : 'Save settings'),
          ),
        ],
      ),
    );
  }
}
