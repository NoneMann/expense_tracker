String formatSom(int amount) {
  final digits = amount.abs().toString();
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(' ');
    out.write(digits[i]);
  }
  return '${amount < 0 ? '−' : ''}$out so‘m';
}

String formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
