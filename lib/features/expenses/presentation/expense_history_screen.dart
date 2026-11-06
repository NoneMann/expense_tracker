import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/expense_tile.dart';
import '../domain/expense.dart';
import 'expense_form_screen.dart';
import 'expense_provider.dart';

class ExpenseHistoryScreen extends StatefulWidget {
  const ExpenseHistoryScreen({super.key});
  @override
  State<ExpenseHistoryScreen> createState() => _ExpenseHistoryScreenState();
}

class _ExpenseHistoryScreenState extends State<ExpenseHistoryScreen> {
  final _search = TextEditingController();
  int? _category;
  DateTime? _from;
  DateTime? _to;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _pickRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _from == null || _to == null
          ? null
          : DateTimeRange(
              start: _from!,
              end: _to!.subtract(const Duration(days: 1)),
            ),
    );
    if (range != null) {
      setState(() {
        _from = dateOnly(range.start);
        _to = dateOnly(range.end).add(const Duration(days: 1));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExpenseProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Xarajatlar tarixi')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Xarajat nomidan qidirish',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _search.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    avatar: const Icon(Icons.date_range, size: 18),
                    label: Text(
                      _from == null
                          ? 'Sana'
                          : '${formatDate(_from!)} – ${formatDate(_to!.subtract(const Duration(days: 1)))}',
                    ),
                    onPressed: _pickRange,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('Barchasi'),
                    selected: _category == null,
                    onSelected: (_) => setState(() => _category = null),
                  ),
                ),
                ...state.categories.map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category.name),
                      selected: _category == category.id,
                      onSelected: (_) => setState(
                        () => _category = _category == category.id
                            ? null
                            : category.id,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<Expense>>(
              key: ValueKey('${_search.text}|$_category|$_from|$_to'),
              future: state.search(
                query: _search.text,
                categoryId: _category,
                from: _from,
                to: _to,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Xatolik: ${snapshot.error}'));
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return const Center(child: Text('Mos xarajat topilmadi.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final expense = items[index];
                    return ExpenseTile(
                      expense: expense,
                      category: state.categoryById(expense.categoryId),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExpenseFormScreen(expense: expense),
                        ),
                      ),
                      onDelete: () => _confirmDelete(expense),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xarajatni o‘chirish'),
        content: Text('“${expense.title}” xarajati o‘chirilsinmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Bekor qilish'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('O‘chirish'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<ExpenseProvider>().delete(expense.id!);
    }
  }
}
