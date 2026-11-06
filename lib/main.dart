import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'core/database/app_database.dart';
import 'core/theme/theme_provider.dart';
import 'features/categories/data/category_repository.dart';
import 'features/expenses/data/expense_repository.dart';
import 'features/expenses/presentation/expense_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();
  await database.database;
  final expenseRepository = ExpenseRepository(database);
  final categoryRepository = CategoryRepository(database);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..load()),
        ChangeNotifierProvider(
          create: (_) =>
              ExpenseProvider(expenseRepository, categoryRepository)..load(),
        ),
      ],
      child: const ExpenseApp(),
    ),
  );
}
