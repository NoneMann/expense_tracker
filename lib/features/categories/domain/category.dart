import 'package:flutter/material.dart';

class ExpenseCategory {
  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    this.isDefault = false,
  });
  final int? id;
  final String name;
  final int iconCode;
  final int colorValue;
  final bool isDefault;
  IconData get icon => switch (iconCode) {
    0xe59c => Icons.shopping_cart,
    0xe1d7 => Icons.directions_car,
    0xe318 => Icons.home,
    0xe40d => Icons.movie,
    0xe3d8 => Icons.medical_services,
    0xe402 => Icons.more_horiz,
    _ => Icons.category,
  };
  Color get color => Color(colorValue);

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'icon': iconCode,
    'color': colorValue,
    'is_default': isDefault ? 1 : 0,
  };
  factory ExpenseCategory.fromMap(Map<String, Object?> map) => ExpenseCategory(
    id: map['id'] as int?,
    name: map['name'] as String,
    iconCode: map['icon'] as int,
    colorValue: map['color'] as int,
    isDefault: (map['is_default'] as int) == 1,
  );
}

final defaultCategories = <ExpenseCategory>[
  ExpenseCategory(
    id: null,
    name: 'Oziq-ovqat',
    iconCode: 0xe59c,
    colorValue: 0xFF187B55,
    isDefault: true,
  ),
  ExpenseCategory(
    id: null,
    name: 'Transport',
    iconCode: 0xe1d7,
    colorValue: 0xFF3976A8,
    isDefault: true,
  ),
  ExpenseCategory(
    id: null,
    name: 'Uy-ro‘zg‘or',
    iconCode: 0xe318,
    colorValue: 0xFFB27A25,
    isDefault: true,
  ),
  ExpenseCategory(
    id: null,
    name: 'Ko‘ngilochar',
    iconCode: 0xe40d,
    colorValue: 0xFF9061A8,
    isDefault: true,
  ),
  ExpenseCategory(
    id: null,
    name: 'Sog‘liq',
    iconCode: 0xe3d8,
    colorValue: 0xFFCF5F68,
    isDefault: true,
  ),
  ExpenseCategory(
    id: null,
    name: 'Boshqa',
    iconCode: 0xe402,
    colorValue: 0xFF65746B,
    isDefault: true,
  ),
];
