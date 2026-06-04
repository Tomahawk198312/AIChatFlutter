import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class ExpensesChartScreen extends StatelessWidget {
  const ExpensesChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('График расходов по дням')),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          final dailyExpenses = chatProvider.dailyExpenses;
          if (dailyExpenses.isEmpty) {
            return const Center(child: Text('Нет данных о расходах', style: TextStyle(color: Colors.white70)));
          }

          final spots = <FlSpot>[];
          double maxY = 0;
          for (int i = 0; i < dailyExpenses.length; i++) {
            final cost = dailyExpenses[i]['totalCost'] as double;
            spots.add(FlSpot(i.toDouble(), cost));
            if (cost > maxY) maxY = cost;
          }
          // Добавим небольшой отступ сверху
          maxY = maxY * 1.1;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        chatProvider.baseUrl?.contains('vsegpt.ru') == true
                            ? '${value.toStringAsFixed(2)}₽'
                            : '\$${value.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < dailyExpenses.length) {
                          final date = dailyExpenses[index]['date'] as String;
                          // Показываем только месяц-день
                          return Text(date.substring(5), style: const TextStyle(color: Colors.white, fontSize: 10));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}