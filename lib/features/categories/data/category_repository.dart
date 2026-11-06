import '../../../core/database/app_database.dart';

import 'package:sqflite/sqflite.dart';

import '../domain/category.dart';

class CategoryRepository {
  CategoryRepository(this._database);
  final AppDatabase _database;

  Future<List<ExpenseCategory>> getAll() async {
    final db = await _database.database;
    final rows = await db.query(
      'categories',
      orderBy: 'is_default DESC, name COLLATE NOCASE',
    );
    return rows.map(ExpenseCategory.fromMap).toList();
  }

  Future<int> add(String name) async {
    final db = await _database.database;
    return db.insert('categories', {
      'name': name.trim(),
      'icon': 0xe402,
      'color': 0xFF65746B,
      'is_default': 0,
    });
  }

  Future<void> delete(ExpenseCategory category) async {
    if (category.isDefault || category.id == null) {
      throw StateError('Standart kategoriyani o‘chirib bo‘lmaydi.');
    }
    final db = await _database.database;
    final used =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM expenses WHERE category_id = ?',
            [category.id],
          ),
        ) ??
        0;
    if (used > 0) {
      throw StateError(
        'Bu kategoriyada xarajatlar bor. Avval ularni boshqa kategoriyaga ko‘chiring.',
      );
    }
    await db.delete('categories', where: 'id = ?', whereArgs: [category.id]);
  }
}
