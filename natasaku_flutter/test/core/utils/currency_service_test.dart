import 'package:flutter_test/flutter_test.dart';
import 'package:natasaku/core/services/currency_service.dart';

void main() {
  test('formatRupiah formats idr currency', () {
    final formatted = CurrencyService.formatRupiah(125000);
    expect(formatted.contains('Rp'), true);
  });

  test('formatRupiah handles invalid numbers', () {
    final formatted = CurrencyService.formatRupiah(double.nan);
    expect(formatted.contains('Rp'), true);
  });
}
