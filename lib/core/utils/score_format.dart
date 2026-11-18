/// Formats a score with thousands separators (e.g. `4500` → `4,500`).
String formatScore(int value) {
  final negative = value < 0;
  final digits = (negative ? -value : value).toString();
  final buffer = StringBuffer();
  if (negative) {
    buffer.write('-');
  }
  for (var i = 0; i < digits.length; i++) {
    final fromEnd = digits.length - i;
    if (i > 0 && fromEnd % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[i]);
  }
  return buffer.toString();
}
