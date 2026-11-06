import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/expense_tile.dart';
import '../../../core/widgets/section_title.dart';
import '../../expenses/presentation/expense_provider.dart';
import '../../expenses/presentation/expense_form_screen.dart';
import '../../expenses/presentation/expense_history_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExpenseProvider>();
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayItems = state.items
        .where((e) => dateOnly(e.date) == todayStart)
        .toList();
    final todaySum = todayItems.fold<int>(0, (sum, item) => sum + item.amount);
    final monthItems = state.items
        .where(
          (e) => !e.date.isBefore(monthStart) && e.date.isBefore(nextMonth),
        )
        .toList();
    final monthSum = monthItems.fold<int>(0, (sum, item) => sum + item.amount);
    final previousMonthStart = DateTime(now.year, now.month - 1);
    final previousMonthSum = state.items
        .where(
          (e) =>
              !e.date.isBefore(previousMonthStart) &&
              e.date.isBefore(monthStart),
        )
        .fold<int>(0, (sum, item) => sum + item.amount);
    final week = List.generate(
      7,
      (index) => DateTime(now.year, now.month, now.day - 6 + index),
    );
    final weekValues = week
        .map(
          (day) => state.items
              .where((e) => dateOnly(e.date) == day)
              .fold<int>(0, (s, e) => s + e.amount),
        )
        .toList();
    final maxValue = weekValues
        .fold<int>(0, (m, v) => v > m ? v : m)
        .toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xarajatlar Hisobi',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            Text('Bosh sahifa', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(state.error!, textAlign: TextAlign.center),
              ),
            )
          : RefreshIndicator(
              onRefresh: state.load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primaryContainer,
                        child: const Icon(Icons.person_outline),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assalomu alaykum 👋',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Moliya nazorati sizning qo‘lingizda',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${_monthName(now.month)}, ${now.year}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Card(
                    color: Theme.of(context).colorScheme.primary,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OYLIK JAMI XARAJATLAR',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary
                                  .withValues(alpha: .75),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            formatSom(monthSum),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 29,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            previousMonthSum == 0
                                ? 'O‘tgan oy bilan solishtirish uchun ma’lumot yo‘q'
                                : _monthComparison(monthSum, previousMonthSum),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary
                                  .withValues(alpha: .82),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _miniStat(
                                  context,
                                  'Bugungi xarajat',
                                  formatSom(todaySum),
                                ),
                                _miniStat(
                                  context,
                                  'Shu oy yozuvlari',
                                  '${monthItems.length} ta',
                                  alignEnd: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: _quickAction(
                          context,
                          Icons.add_circle_outline,
                          'Xarajat qo‘shish',
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ExpenseFormScreen(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _quickAction(
                          context,
                          Icons.receipt_long_outlined,
                          'Tarixni ko‘rish',
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ExpenseHistoryScreen(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const SectionTitle('Haftalik xarajatlar'),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 20, 18, 8),
                      child: SizedBox(
                        height: 170,
                        child: BarChart(
                          BarChartData(
                            maxY: maxValue == 0 ? 1 : maxValue * 1.2,
                            borderData: FlBorderData(show: false),
                            gridData: const FlGridData(show: false),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 28,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index < 0 || index >= week.length) {
                                      return const SizedBox.shrink();
                                    }
                                    const names = [
                                      'Du',
                                      'Se',
                                      'Cho',
                                      'Pa',
                                      'Ju',
                                      'Sha',
                                      'Ya',
                                    ];
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        names[week[index].weekday - 1],
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            barGroups: List.generate(
                              7,
                              (index) => BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: weekValues[index].toDouble(),
                                    width: 18,
                                    color: index == 6
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.primary
                                              .withValues(alpha: .3),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SectionTitle(
                    'So‘nggi xarajatlar',
                    action: 'Barchasi',
                    onAction: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ExpenseHistoryScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (state.items.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(22),
                        child: Center(
                          child: Text(
                            'Hozircha xarajatlar yo‘q. Birinchi xarajatingizni qo‘shing.',
                          ),
                        ),
                      ),
                    )
                  else
                    ...state.items
                        .take(5)
                        .map(
                          (expense) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ExpenseTile(
                              expense: expense,
                              category: state.categoryById(expense.categoryId),
                            ),
                          ),
                        ),
                ],
              ),
            ),
    );
  }

  static Widget _miniStat(
    BuildContext context,
    String title,
    String value, {
    bool alignEnd = false,
  }) => Column(
    crossAxisAlignment: alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: .7),
          fontSize: 11,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    ],
  );

  static Widget _quickAction(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) => Material(
    color: Theme.of(context).colorScheme.surfaceContainerLow,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  static String _monthName(int month) => const [
    'Yanvar',
    'Fevral',
    'Mart',
    'Aprel',
    'May',
    'Iyun',
    'Iyul',
    'Avgust',
    'Sentabr',
    'Oktabr',
    'Noyabr',
    'Dekabr',
  ][month - 1];

  static String _monthComparison(int current, int previous) {
    final percent = ((current - previous) * 100 / previous).round().abs();
    return current <= previous
        ? 'O‘tgan oyga nisbatan $percent% kamroq'
        : 'O‘tgan oyga nisbatan $percent% ko‘proq';
  }
}
