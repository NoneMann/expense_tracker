class Expense {
  const Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.note,
    this.createdAt,
    this.updatedAt,
  });
  final int? id;
  final String title;
  final int amount;
  final int categoryId;
  final DateTime date;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'amount': amount,
    'category_id': categoryId,
    'date': date.toIso8601String(),
    'note': note,
    'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  };
  factory Expense.fromMap(Map<String, Object?> map) => Expense(
    id: map['id'] as int?,
    title: map['title'] as String,
    amount: map['amount'] as int,
    categoryId: map['category_id'] as int,
    date: DateTime.parse(map['date'] as String),
    note: map['note'] as String?,
    createdAt: DateTime.tryParse(map['created_at'] as String? ?? ''),
    updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? ''),
  );
}
