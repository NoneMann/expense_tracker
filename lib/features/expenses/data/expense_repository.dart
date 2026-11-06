import '../../../core/database/app_database.dart';
import '../domain/expense.dart';

class ExpenseRepository {
  ExpenseRepository(this._database);
  final AppDatabase _database;

  Future<int> save(Expense expense) async {
    final db = await _database.database;
    final values = expense.toMap()..remove('id');
    if (expense.id == null) return db.insert('expenses', values);
    return db.update(
      'expenses',
      values,
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _database.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Expense>> getAll({
    String query = '',
    int? categoryId,
    DateTime? from,
    DateTime? to,
  }) async {
    final db = await _database.database;
    final where = <String>[];
    final args = <Object?>[];
    if (query.trim().isNotEmpty) {
      where.add('title LIKE ?');
      args.add('%${query.trim()}%');
    }
    if (categoryId != null) {
      where.add('category_id = ?');
      args.add(categoryId);
    }
    if (from != null) {
      where.add('date >= ?');
      args.add(from.toIso8601String());
    }
    if (to != null) {
      where.add('date < ?');
      args.add(to.toIso8601String());
    }
    final rows = await db.query(
      'expenses',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(Expense.fromMap).toList();
  }

  Future<int> sumBetween(DateTime from, DateTime to) async {
    final db = await _database.database;
    final rows = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM expenses WHERE date >= ? AND date < ?',
      [from.toIso8601String(), to.toIso8601String()],
    );
    return (rows.first['total'] as num).toInt();
  }

  Future<Map<int, int>> totalsByCategory(DateTime from, DateTime to) async {
    final db = await _database.database;
    final rows = await db.rawQuery(
      'SELECT category_id, SUM(amount) AS total FROM expenses WHERE date >= ? AND date < ? GROUP BY category_id ORDER BY total DESC',
      [from.toIso8601String(), to.toIso8601String()],
    );
    return {
      for (final row in rows)
        row['category_id'] as int: (row['total'] as num).toInt(),
    };
  }

  Future<void> clearAll() async {
    final db = await _database.database;
    await db.delete('expenses');
  }
}
