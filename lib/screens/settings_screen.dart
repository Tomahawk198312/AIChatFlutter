import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  String _selectedProvider = 'openrouter';

  final Map<String, String> _providerUrls = {
    'openrouter': 'https://openrouter.ai/api/v1',
    'vsegpt': 'https://api.vsegpt.ru/v1',
  };

  @override
  void initState() {
    super.initState();
    final chatProvider = context.read<ChatProvider>();
    _apiKeyController.text = chatProvider.apiKey ?? '';
    _baseUrlController.text = chatProvider.baseUrl ?? '';
    if (chatProvider.baseUrl?.contains('vsegpt.ru') == true) {
      _selectedProvider = 'vsegpt';
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки провайдера')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedProvider,
              dropdownColor: const Color(0xFF333333),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Провайдер',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
              ),
              items: const [
                DropdownMenuItem(value: 'openrouter', child: Text('OpenRouter.ai')),
                DropdownMenuItem(value: 'vsegpt', child: Text('VseGPT.ru')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedProvider = value!;
                  _baseUrlController.text = _providerUrls[value]!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apiKeyController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'API ключ',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _baseUrlController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Базовый URL',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final chatProvider = context.read<ChatProvider>();
                chatProvider.updateApiSettings(
                  apiKey: _apiKeyController.text.trim(),
                  baseUrl: _baseUrlController.text.trim(),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Настройки сохранены'), backgroundColor: Colors.green),
                );
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}