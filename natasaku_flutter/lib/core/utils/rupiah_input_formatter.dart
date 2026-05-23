import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class RupiahInputFormatter extends TextInputFormatter {
  final _formatter = NumberFormat('#,###', 'id_ID');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Strip all non-digit characters
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Guard: max 12 digits (Rp 999.999.999.999 / 999 Miliar)
    if (digits.length > 12) {
      return oldValue;
    }

    final parsed = int.tryParse(digits) ?? 0;
    final formatted = _formatter.format(parsed);

    // Calculate new selection offset to prevent cursor jump
    var selectionOffset = newValue.selection.end;
    
    final oldDigitsOnly = oldValue.text.replaceAll('.', '');
    final newDigitsOnly = newValue.text.replaceAll('.', '');
    
    if (oldDigitsOnly == newDigitsOnly) {
      selectionOffset = formatted.length;
    } else {
      final textBeforeCursor = newValue.text.substring(
        0,
        selectionOffset.clamp(0, newValue.text.length),
      );
      final digitsBeforeCursor = textBeforeCursor.replaceAll('.', '');
      
      var digitsFound = 0;
      var newOffset = 0;
      
      for (var i = 0; i < formatted.length; i++) {
        if (formatted[i] != '.') {
          digitsFound++;
        }
        
        if (digitsFound == digitsBeforeCursor.length) {
          newOffset = i + 1;
          break;
        }
      }
      
      if (newOffset > 0) {
        selectionOffset = newOffset;
      } else {
        selectionOffset = formatted.length;
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: selectionOffset.clamp(0, formatted.length),
      ),
    );
  }
}
