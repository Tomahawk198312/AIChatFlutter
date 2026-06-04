import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Статистика использования моделей')),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          final modelStats = _aggregateModelStats(chatProvider);
          if (modelStats.isEmpty) {
            return const Center(child: Text('Нет данных', style: TextStyle(color: Colors.white70)));
          }
          return ListView.builder(
            itemCount: modelStats.length,
            itemBuilder: (context, index) {
              final stat = modelStats[index];
              return ListTile(
                title: Text(stat['modelId']!, style: const TextStyle(color: Colors.white)),
                subtitle: Text(
                  'Сообщений: ${stat['count']}, Токенов: ${stat['tokens']}, Стоимость: ${stat['cost']}',
                  style: const TextStyle(color: Colors.white70),
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _aggregateModelStats(ChatProvider provider) {
    final Map<String, Map<String, dynamic>> stats = {};
    for (final msg in provider.messages) {
      if (msg.modelId != null) {
        stats.putIfAbsent(msg.modelId!, () => {'modelId': msg.modelId, 'count': 0, 'tokens': 0, 'cost': 0.0});
        stats[msg.modelId!]!['count'] += 1;
        stats[msg.modelId!]!['tokens'] += (msg.tokens ?? 0);
        stats[msg.modelId!]!['cost'] += (msg.cost ?? 0.0);
      }
    }
    return stats.values.toList();
  }
}