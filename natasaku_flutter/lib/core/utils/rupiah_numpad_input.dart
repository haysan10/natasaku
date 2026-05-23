import 'package:intl/intl.dart';

class RupiahNumpadInput {
  static final NumberFormat _formatter = NumberFormat('#,###', 'id_ID');

  static String applyKey(
    String currentText,
    String key, {
    bool withPrefix = false,
    int maxDigits = 12,
  }) {
    final currentDigits = digitsOnly(currentText);
    var nextDigits = currentDigits;

    switch (key) {
      case 'backspace':
      case '⌫':
        nextDigits = currentDigits.isEmpty
            ? ''
            : currentDigits.substring(0, currentDigits.length - 1);
        break;
      case 'clear':
      case 'C':
        nextDigits = '';
        break;
      case '000':
        if (currentDigits.isNotEmpty) {
          nextDigits = '${currentDigits}000';
        }
        break;
      default:
        if (!RegExp(r'^\d+$').hasMatch(key)) {
          return formatDigits(
            currentDigits,
            withPrefix: withPrefix,
          );
        }
        nextDigits = currentDigits == '0' ? key : '$currentDigits$key';
    }

    if (nextDigits.length > maxDigits) {
      nextDigits = nextDigits.substring(0, maxDigits);
    }

    return formatDigits(nextDigits, withPrefix: withPrefix);
  }

  static String formatRaw(String raw, {bool withPrefix = false}) {
    return formatDigits(digitsOnly(raw), withPrefix: withPrefix);
  }

  static String formatDigits(String digits, {bool withPrefix = false}) {
    if (digits.isEmpty) return '';

    final amount = int.tryParse(digits) ?? 0;
    final formatted = _formatter.format(amount);
    return withPrefix ? 'Rp $formatted' : formatted;
  }

  static String digitsOnly(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }
}
