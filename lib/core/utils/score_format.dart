import 'package:intl/intl.dart';

String formatScore(int value, {String? locale}) {
  return NumberFormat.decimalPattern(locale).format(value);
}