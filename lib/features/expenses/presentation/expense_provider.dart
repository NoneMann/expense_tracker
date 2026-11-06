import 'package:flutter/foundation.dart';

import '../../categories/data/category_repository.dart';
import '../../categories/domain/category.dart';
import '../data/expense_repository.dart';
import '../domain/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  ExpenseProvider(this._expenses, this._categories);
  final ExpenseRepository _expenses;
  final CategoryRepository _categories;

  List<Expense> items = [];
  List<ExpenseCategory> categories = [];
  bool loading = true;
  String? error;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      categories = await _categories.getAll();
      items = await _expenses.getAll();
    } catch (e) {
      error = 'Ma’lumotlarni yuklab bo‘lmadi: $e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> save(Expense expense) async {
    await _expenses.save(expense);
    await load();
  }

  Future<void> delete(int id) async {
    await _expenses.delete(id);
    await load();
  }

  Future<List<Expense>> search({
    String query = '',
    int? categoryId,
    DateTime? from,
    DateTime? to,
  }) => _expenses.getAll(
    query: query,
    categoryId: categoryId,
    from: from,
    to: to,
  );

  Future<int> total(DateTime from, DateTime to) =>
      _expenses.sumBetween(from, to);
  Future<Map<int, int>> categoryTotals(DateTime from, DateTime to) =>
      _expenses.totalsByCategory(from, to);
  Future<int> addCategory(String name) async {
    final id = await _categories.add(name);
    await load();
    return id;
  }

  Future<void> deleteCategory(ExpenseCategory category) async {
    await _categories.delete(category);
    await load();
  }

  Future<void> clearData() async {
    await _expenses.clearAll();
    await load();
  }

  ExpenseCategory? categoryById(int id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }
}
