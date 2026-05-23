import 'package:flutter_test/flutter_test.dart';
import 'package:natasaku/core/utils/rupiah_numpad_input.dart';

void main() {
  group('RupiahNumpadInput', () {
    test('formats appended digits as Indonesian Rupiah groups', () {
      var value = '';

      for (final key in ['1', '2', '3', '4', '5']) {
        value = RupiahNumpadInput.applyKey(value, key);
      }

      expect(value, '12.345');
    });

    test('appends triple zero only after a non-empty value', () {
      expect(RupiahNumpadInput.applyKey('', '000'), '');
      expect(RupiahNumpadInput.applyKey('25', '000'), '25.000');
    });

    test('removes the last digit and clears the value', () {
      expect(RupiahNumpadInput.applyKey('12.345', 'backspace'), '1.234');
      expect(RupiahNumpadInput.applyKey('1', 'backspace'), '');
      expect(RupiahNumpadInput.applyKey('99.000', 'clear'), '');
    });

    test('caps input at twelve digits', () {
      final value = RupiahNumpadInput.applyKey('999.999.999.999', '9');

      expect(value, '999.999.999.999');
    });

    test('supports formatted values with Rp prefix', () {
      var value = '';

      for (final key in ['1', '0', '000']) {
        value = RupiahNumpadInput.applyKey(value, key, withPrefix: true);
      }

      expect(value, 'Rp 10.000');
      expect(
        RupiahNumpadInput.applyKey(value, 'backspace', withPrefix: true),
        'Rp 1.000',
      );
    });
  });
}
