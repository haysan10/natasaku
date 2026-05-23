import 'package:flutter/services.dart';
import 'nominal_input_validator.dart';

class NominalFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Extract only digits (Rule N8 / N9)
    final parsed = NominalInputValidator.parseNominal(newValue.text);
    if (parsed == 0) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Format with dots
    final formatted = _formatWithDots(parsed.toString());

    // Calculate new selection offset to prevent cursor jump
    var selectionOffset = newValue.selection.end;
    
    // Count how many dots were added or removed
    final oldDigitsOnly = oldValue.text.replaceAll('.', '');
    final newDigitsOnly = newValue.text.replaceAll('.', '');
    
    if (oldDigitsOnly == newDigitsOnly) {
      // Just formatting dots changed
      selectionOffset = formatted.length;
    } else {
      // Count dots before selection end in the formatted string
      final textBeforeCursor = newValue.text.substring(0, selectionOffset.clamp(0, newValue.text.length));
      final digitsBeforeCursor = textBeforeCursor.replaceAll('.', '');
      
      var digitsFound = 0;
      var newOffset = 0;
      
      for (var i = 0; i < formatted.length; i++) {
        if (formatted[i] == '.') {
        } else {
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

  static String _formatWithDots(String text) {
    final reversed = text.split('').reversed.toList();
    final result = <String>[];
    for (var i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        result.add('.');
      }
      result.add(reversed[i]);
    }
    return result.reversed.join('');
  }
}
