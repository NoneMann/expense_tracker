import 'package:flutter/material.dart';

import '../../features/categories/domain/category.dart';
import '../../features/expenses/domain/expense.dart';
import '../utils/formatters.dart';

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({
    super.key,
    required this.expense,
    required this.category,
    this.onTap,
    this.onDelete,
  });
  final Expense expense;
  final ExpenseCategory? category;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final color = category?.color ?? Theme.of(context).colorScheme.primary;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: .12),
          foregroundColor: color,
          child: Icon(category?.icon ?? Icons.receipt_long),
        ),
        title: Text(
          expense.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${category?.name ?? 'Kategoriya'} · ${formatDate(expense.date)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatSom(expense.amount),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            if (onDelete != null)
              IconButton(
                tooltip: 'O‘chirish',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
