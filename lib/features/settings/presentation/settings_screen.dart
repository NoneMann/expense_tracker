import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/formatters.dart';
import '../../expenses/presentation/expense_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final state = context.watch<ExpenseProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Sozlamalar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Mavzu'),
                  subtitle: const Text('Yorug‘, qorong‘i yoki tizim'),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<ThemeMode>(
                      value: theme.themeMode,
                      items: const [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text('Tizim'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text('Yorug‘'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text('Qorong‘i'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          context.read<ThemeProvider>().setTheme(value);
                        }
                      },
                    ),
                  ),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.currency_exchange),
                  title: Text('Valyuta'),
                  subtitle: Text('O‘zbekiston so‘mi (UZS)'),
                  trailing: Icon(Icons.lock_outline, size: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Kategoriyalar',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              IconButton(
                tooltip: 'Kategoriya qo‘shish',
                onPressed: () => _addCategory(context),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          ...state.categories.map(
            (category) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: category.color.withValues(alpha: .12),
                  child: Icon(category.icon, color: category.color),
                ),
                title: Text(category.name),
                subtitle: Text(
                  category.isDefault
                      ? 'Standart kategoriya'
                      : 'Shaxsiy kategoriya',
                ),
                trailing: category.isDefault
                    ? null
                    : IconButton(
                        tooltip: 'Kategoriyani o‘chirish',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          try {
                            await context
                                .read<ExpenseProvider>()
                                .deleteCategory(category);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString().replaceFirst(
                                      'Bad state: ',
                                      '',
                                    ),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.ios_share_outlined),
                  title: const Text('Ma’lumotlarni eksport qilish'),
                  subtitle: const Text('Xarajatlarni CSV faylga chiqarish'),
                  onTap: () => _export(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.delete_sweep_outlined,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: const Text('Barcha xarajatlarni o‘chirish'),
                  subtitle: const Text('Kategoriyalar saqlanib qoladi'),
                  onTap: () => _clear(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Ilova haqida'),
                  subtitle: const Text('Xarajatlar Hisobi · 1.0.0'),
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'Xarajatlar Hisobi',
                    applicationVersion: '1.0.0',
                    applicationLegalese:
                        'Shaxsiy xarajatlarni oflayn boshqarish.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Ma’lumotlar ushbu qurilmada saqlanadi',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addCategory(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yangi kategoriya'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Kategoriya nomi'),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Qo‘shish'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty || !context.mounted) return;
    try {
      await context.read<ExpenseProvider>().addCategory(name);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Kategoriya qo‘shilmadi: $e')));
      }
    }
  }

  Future<void> _clear(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Barcha xarajatlar o‘chirilsinmi?'),
        content: const Text(
          'Bu amalni ortga qaytarib bo‘lmaydi. Kategoriyalar saqlanadi.',
        ),
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
    if (yes == true && context.mounted) {
      await context.read<ExpenseProvider>().clearData();
    }
  }

  Future<void> _export(BuildContext context) async {
    try {
      final state = context.read<ExpenseProvider>();
      final rows = ['Sana,Xarajat,Kategoriya,Summa (UZS),Izoh'];
      for (final expense in state.items) {
        final title = _csv(expense.title);
        final category = _csv(
          state.categoryById(expense.categoryId)?.name ?? 'Boshqa',
        );
        final note = _csv(expense.note ?? '');
        rows.add(
          '${formatDate(expense.date)},$title,$category,${expense.amount},$note',
        );
      }
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}${Platform.pathSeparator}xarajatlar.csv',
      );
      await file.writeAsString('\uFEFF${rows.join('\r\n')}');
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Xarajatlar Hisobi — CSV eksport',
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Eksportda xatolik: $e')));
      }
    }
  }

  String _csv(String value) => '"${value.replaceAll('"', '""')}"';
}
