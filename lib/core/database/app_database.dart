import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../../features/categories/domain/category.dart';

class AppDatabase {
  static const _databaseName = 'xarajatlar_hisobi.db';
  static const _version = 1;
  Database? _instance;

  Future<Database> get database async {
    if (_instance != null) return _instance!;
    final root = await getDatabasesPath();
    _instance = await openDatabase(
      path.join(root, _databaseName),
      version: _version,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          icon INTEGER NOT NULL,
          color INTEGER NOT NULL,
          is_default INTEGER NOT NULL DEFAULT 0 CHECK (is_default IN (0, 1))
        )''');
        await db.execute('''CREATE TABLE expenses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL CHECK (length(trim(title)) > 0),
          amount INTEGER NOT NULL CHECK (amount > 0),
          category_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          note TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT
        )''');
        await db.execute('''CREATE TABLE settings (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )''');
        final batch = db.batch();
        for (final category in defaultCategories) {
          batch.insert('categories', category.toMap()..remove('id'));
        }
        await batch.commit(noResult: true);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Add versioned migrations here as the local schema evolves.
      },
    );
    return _instance!;
  }
}
