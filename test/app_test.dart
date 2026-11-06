import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/utils/formatters.dart';
import 'package:expense_tracker/features/categories/domain/category.dart';
import 'package:expense_tracker/features/expenses/domain/expense.dart';

void main() {
  group('formatSom', () {
    test('groups integer UZS amounts with spaces', () {
      expect(formatSom(4850000), '4 850 000 so‘m');
      expect(formatSom(0), '0 so‘m');
      expect(formatSom(-12500), '−12 500 so‘m');
    });
  });

  group('database models', () {
    test('category round-trips through its SQLite map', () {
      final original = defaultCategories.first;
      final decoded = ExpenseCategory.fromMap(original.toMap());

      expect(decoded.name, original.name);
      expect(decoded.iconCode, original.iconCode);
      expect(decoded.colorValue, original.colorValue);
      expect(decoded.isDefault, isTrue);
    });

    test('expense writes integer amount and ISO date', () {
      final date = DateTime(2026, 11, 6);
      final expense = Expense(
        id: 3,
        title: 'Bozor',
        amount: 125000,
        categoryId: 1,
        date: date,
        note: 'Haftalik xarid',
      );
      final row = expense.toMap();

      expect(row['id'], 3);
      expect(row['amount'], 125000);
      expect(row['date'], date.toIso8601String());
      expect(row['note'], 'Haftalik xarid');
    });
  });
}
