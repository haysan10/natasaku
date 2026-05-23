import 'package:intl/intl.dart';

class CurrencyService {
  static final NumberFormat _rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  static String formatRupiah(num value) {
    final safeValue = value.isFinite ? value : 0;
    return _rupiah.format(safeValue);
  }
}
