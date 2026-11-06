import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/formatters.dart';
import '../../categories/domain/category.dart';
import '../domain/expense.dart';
import 'expense_provider.dart';

class ExpenseFormScreen extends StatefulWidget {
  const ExpenseFormScreen({super.key, this.expense});
  final Expense? expense;

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _amount;
  late final TextEditingController _note;
  late DateTime _date;
  int? _categoryId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    _title = TextEditingController(text: expense?.title ?? '');
    _amount = TextEditingController(
      text: expense == null
          ? ''
          : formatSom(expense.amount).replaceAll(RegExp(r'[^0-9]'), ''),
    );
    _note = TextEditingController(text: expense?.note ?? '');
    _date = expense?.date ?? DateTime.now();
    _categoryId = expense?.categoryId;
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<ExpenseProvider>();
    if (provider.categories.isEmpty) {
      _message('Avval kategoriya qo‘shing.');
      return;
    }
    setState(() => _saving = true);
    try {
      await provider.save(
        Expense(
          id: widget.expense?.id,
          title: _title.text.trim(),
          amount: int.parse(_amount.text.replaceAll(RegExp(r'\D'), '')),
          categoryId: _categoryId ?? provider.categories.first.id!,
          date: _date,
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
          createdAt: widget.expense?.createdAt,
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) _message('Saqlashda xatolik: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<ExpenseProvider>().categories;
    if (_categoryId == null && categories.isNotEmpty) {
      _categoryId = categories.first.id;
    }
    final parsed =
        int.tryParse(_amount.text.replaceAll(RegExp(r'\D'), '')) ?? 0;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.expense == null ? 'Xarajat qo‘shish' : 'Xarajatni tahrirlash',
        ),
        actions: [
          IconButton(
            tooltip: 'Maydonlarni tozalash',
            onPressed: () {
              _formKey.currentState?.reset();
              _title.clear();
              _amount.clear();
              _note.clear();
              setState(() => _date = DateTime.now());
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(
              'Summa',
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amount,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: '0',
                suffixText: 'so‘m',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              validator: (v) =>
                  (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Summani kiriting' : null,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                formatSom(parsed),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Kategoriya',
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories
                  .map((category) => _categoryChip(category))
                  .toList(),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Xarajat nomi',
                hintText: 'Masalan, oziq-ovqat',
                prefixIcon: Icon(Icons.edit_outlined),
              ),
              validator: (v) => (v?.trim().isEmpty ?? true)
                  ? 'Xarajat nomini kiriting'
                  : null,
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(16),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Sana',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(formatDate(_date)),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _note,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Izoh (ixtiyoriy)',
                hintText: 'Qo‘shimcha ma’lumot yozing',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
            const SizedBox(height: 22),
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              child: ListTile(
                leading: Icon(
                  Icons.verified_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Mahalliy qurilmada saqlanadi'),
                subtitle: const Text(
                  'Ma’lumotlaringiz SQLite bazasida qoladi.',
                ),
                trailing: Text(
                  formatSom(parsed),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(_saving ? 'Saqlanmoqda…' : 'Xarajatni saqlash'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip(ExpenseCategory category) {
    final selected = _categoryId == category.id;
    return ChoiceChip(
      avatar: Icon(
        category.icon,
        size: 18,
        color: selected ? Colors.white : category.color,
      ),
      label: Text(category.name),
      selected: selected,
      onSelected: (_) => setState(() => _categoryId = category.id),
    );
  }
}
