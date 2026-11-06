import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/section_title.dart';
import '../../expenses/presentation/expense_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});
  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _period = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExpenseProvider>();
    final now = DateTime.now();
    final from = switch (_period) {
      0 => DateTime(now.year, now.month, now.day - 6),
      1 => DateTime(now.year, now.month, now.day - 29),
      _ => DateTime(now.year, now.month),
    };
    final start = dateOnly(from);
    final end = DateTime(now.year, now.month, now.day + 1);
    final totals = state.items
        .where((e) => !e.date.isBefore(start) && e.date.isBefore(end))
        .fold<int>(0, (sum, e) => sum + e.amount);
    final chartDays = List.generate(
      end.difference(start).inDays,
      (index) => start.add(Duration(days: index)),
    );
    final dailyValues = chartDays
        .map(
          (day) => state.items
              .where((e) => dateOnly(e.date) == day)
              .fold<int>(0, (sum, e) => sum + e.amount),
        )
        .toList();
    final maxDaily = dailyValues.fold<int>(
      0,
      (maxValue, value) => value > maxValue ? value : maxValue,
    );
    final monthStart = DateTime(now.year, now.month);
    final previousMonthStart = DateTime(now.year, now.month - 1);
    final thisMonth = state.items
        .where(
          (e) =>
              !e.date.isBefore(monthStart) &&
              e.date.isBefore(DateTime(now.year, now.month + 1)),
        )
        .fold<int>(0, (sum, e) => sum + e.amount);
    final previousMonth = state.items
        .where(
          (e) =>
              !e.date.isBefore(previousMonthStart) &&
              e.date.isBefore(monthStart),
        )
        .fold<int>(0, (sum, e) => sum + e.amount);
    final byCategory = <int, int>{};
    for (final expense in state.items.where(
      (e) => !e.date.isBefore(start) && e.date.isBefore(end),
    )) {
      byCategory.update(
        expense.categoryId,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    final ordered = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final colors = state.categories.map((c) => c.color).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Xarajatlar tahlili')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('7 kun')),
              ButtonSegment(value: 1, label: Text('30 kun')),
              ButtonSegment(value: 2, label: Text('Oy')),
            ],
            selected: {_period},
            onSelectionChanged: (value) =>
                setState(() => _period = value.first),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'JAMI XARAJAT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatSom(totals),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${ordered.length} ta faol kategoriya',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const SectionTitle('Kunlik xarajatlar'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
              child: SizedBox(
                height: 165,
                child: BarChart(
                  BarChartData(
                    maxY: maxDaily == 0 ? 1 : maxDaily * 1.2,
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
                            if (index < 0 ||
                                index >= chartDays.length ||
                                (chartDays.length > 10 && index % 5 != 0)) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 7),
                              child: Text(
                                '${chartDays[index].day}',
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(
                      chartDays.length,
                      (index) => BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: dailyValues[index].toDouble(),
                            width: chartDays.length > 10 ? 5 : 14,
                            color: Theme.of(context).colorScheme.primary
                                .withValues(alpha: .78),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
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
          const SizedBox(height: 18),
          const SectionTitle('Oylar taqqoslanishi'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Joriy oy'),
                  trailing: Text(
                    formatSom(thisMonth),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('O‘tgan oy'),
                  trailing: Text(
                    formatSom(previousMonth),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const SectionTitle('Kategoriyalar bo‘yicha'),
          const SizedBox(height: 8),
          if (ordered.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(22),
                child: Center(child: Text('Tanlangan davrda xarajat yo‘q.')),
              ),
            )
          else ...[
            SizedBox(
              height: 230,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 48,
                      sectionsSpace: 3,
                      sections: [
                        for (var i = 0; i < ordered.length; i++)
                          PieChartSectionData(
                            value: ordered[i].value.toDouble(),
                            color: colors.isEmpty
                                ? Theme.of(context).colorScheme.primary
                                : colors[i % colors.length],
                            radius: 24,
                            title: totals == 0
                                ? ''
                                : '${(ordered[i].value * 100 / totals).round()}%',
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ...ordered.map((entry) {
              final category = state.categoryById(entry.key);
              final percent = totals == 0 ? 0.0 : entry.value / totals;
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: (category?.color ?? Colors.green)
                        .withValues(alpha: .12),
                    child: Icon(
                      category?.icon ?? Icons.category,
                      color: category?.color ?? Colors.green,
                    ),
                  ),
                  title: Text(category?.name ?? 'Boshqa'),
                  subtitle: LinearProgressIndicator(
                    value: percent,
                    minHeight: 5,
                  ),
                  trailing: Text(
                    formatSom(entry.value),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              );
            }),
            if (ordered.isNotEmpty)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.emoji_events_outlined),
                  title: const Text('Eng ko‘p xarajat qilingan'),
                  subtitle: Text(
                    state.categoryById(ordered.first.key)?.name ?? 'Boshqa',
                  ),
                  trailing: Text(
                    formatSom(ordered.first.value),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
