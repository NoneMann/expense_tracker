import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/theme_provider.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/expenses/presentation/expense_form_screen.dart';
import '../features/expenses/presentation/expense_history_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/statistics/presentation/statistics_screen.dart';

class ExpenseApp extends StatelessWidget {
  const ExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().themeMode;
    return MaterialApp(
      title: 'Xarajatlar Hisobi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: const Locale('uz'),
      supportedLocales: const [Locale('uz'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  final _screens = const [
    DashboardScreen(),
    ExpenseHistoryScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  Future<void> _addExpense() async {
    await Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (_) => const ExpenseFormScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpense,
        tooltip: 'Xarajat qo‘shish',
        child: const Icon(Icons.add_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Bosh sahifa',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Tarix',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Tahlil',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Sozlamalar',
          ),
        ],
      ),
    );
  }
}
