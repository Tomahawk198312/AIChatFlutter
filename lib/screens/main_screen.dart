import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'statistics_screen.dart';
import 'expenses_chart_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ChatScreen(),
    StatisticsScreen(),
    ExpensesChartScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF262626),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Чат'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Статистика'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'График'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Настройки'),
        ],
      ),
    );
  }
}