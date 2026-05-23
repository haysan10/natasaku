import 'dart:convert';

class NominalInputValidator {
  /// Parse a currency input string by removing formatting dots, commas, leading zeros,
  /// negative signs, and non-digit characters. Returns the parsed integer amount.
  /// Rule N4: Dots strip, Rule N5: Commas strip, Rule N6: Negatives strip, Rule N8: Leading zeros strip.
  static int parseNominal(String input) {
    var cleaned = input.replaceAll(RegExp(r'[^\d]'), '');
    
    // Strip leading zeros (Rule N8)
    cleaned = cleaned.replaceFirst(RegExp(r'^0+'), '');
    if (cleaned.isEmpty) return 0;
    
    return int.tryParse(cleaned) ?? 0;
  }

  /// Rule N1, N2, N7: General validation for amount inputs.
  /// Returns null if valid, or an error string if invalid.
  static String? validateAmount(String input) {
    if (input.trim().isEmpty) {
      return 'Nominal tidak boleh kosong'; // Rule N2
    }
    
    final parsed = parseNominal(input);
    if (parsed == 0) {
      return 'Nominal harus lebih dari Rp 0'; // Rule N1
    }
    
    if (parsed > 999999999999) {
      return 'Nominal terlalu besar. Maksimum Rp 999.999.999.999'; // Rule N7
    }
    
    return null;
  }

  /// Rule S1-S6: Validate setup budget constraints.
  /// Returns a result status map containing error, warning, or success.
  static Map<String, dynamic> validateSetup({
    required int totalIncome,
    required int totalFixedExpense,
    required int savingAllocation,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    // Rule S1: Total income must be > 0
    if (totalIncome <= 0) {
      return {'status': 'error', 'message': 'Total penghasilan wajib lebih dari Rp 0'};
    }

    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    // Rule S3: Start date cannot be in the past
    if (start.isBefore(today)) {
      return {'status': 'error', 'message': 'Tanggal mulai periode tidak boleh di masa lalu'};
    }

    // Rule S4: Start date = End date -> "Periode minimal 1 hari"
    if (start == end) {
      return {'status': 'error', 'message': 'Periode minimal 1 hari'};
    }

    // Rule S5: End date < Start date
    if (end.isBefore(start)) {
      return {'status': 'error', 'message': 'Tanggal akhir tidak valid'};
    }

    final durationDays = end.difference(start).inDays + 1;
    // Rule S6: Duration > 365 days warning
    if (durationDays > 365) {
      return {
        'status': 'warning',
        'message': 'Periode sangat panjang. Yakin lanjutkan?',
        'allowContinue': true
      };
    }

    // Rule S2: Income < Fixed Expense + Savings
    if (totalIncome < (totalFixedExpense + savingAllocation)) {
      return {
        'status': 'warning',
        'message': 'Dana fleksibel kamu negatif. Kamu bisa melanjutkan dan menyesuaikan nanti, atau kurangi pengeluaran tetap.',
        'allowContinue': true
      };
    }

    return {'status': 'success'};
  }

  /// Rule T1-T3, T6: Validate transaction inputs.
  static String? validateTransaction({
    required int amount,
    required String? category,
    required DateTime transactionDate,
    required DateTime periodStartDate,
    required String? note,
  }) {
    if (amount <= 0) return 'Nominal harus lebih dari Rp 0';
    if (amount > 999999999999) return 'Nominal terlalu besar. Maksimum Rp 999.999.999.999';
    
    // Rule T3: Category must be selected
    if (category == null || category.trim().isEmpty || category.toLowerCase() == 'uncategorized') {
      return 'Kategori wajib dipilih';
    }

    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final txDate = DateTime(transactionDate.year, transactionDate.month, transactionDate.day);
    final pStart = DateTime(periodStartDate.year, periodStartDate.month, periodStartDate.day);

    // Rule T1: Date <= today
    if (txDate.isAfter(today)) {
      return 'Tanggal transaksi tidak boleh setelah hari ini';
    }

    // Rule T2: Date >= period start date
    if (txDate.isBefore(pStart)) {
      return 'Tanggal transaksi tidak boleh sebelum tanggal mulai periode aktif';
    }

    // Rule T6: Note counter & block > 200 chars
    if (note != null && note.length > 200) {
      return 'Catatan maksimal 200 karakter';
    }

    return null;
  }

  /// Rule SV2: Validate savings goal target amount.
  static String? validateSavingGoal({
    required int targetAmount,
    required int totalIncome,
  }) {
    if (targetAmount < 0) return 'Target tabungan tidak boleh negatif';
    if (targetAmount > 999999999999) return 'Nominal target terlalu besar. Maksimum Rp 999.999.999.999';
    
    // Rule SV2: Warning if target > income
    if (targetAmount > totalIncome) {
      return 'Target tabungan melebihi penghasilan. Pastikan ini sesuai rencanamu.';
    }
    return null;
  }

  /// Rule BR1-BR3: Validate backup integrity on restore.
  static Map<String, dynamic> validateRestore(String rawJson, String fileSuffix) {
    // Rule BR1: suffix check
    if (!fileSuffix.endsWith('.json')) {
      return {
        'status': 'error',
        'message': 'File tidak dikenali. Pilih file backup NataSaku (.json)'
      };
    }

    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(rawJson) as Map<String, dynamic>;
    } catch (_) {
      // Rule BR2: json parse check
      return {
        'status': 'error',
        'message': 'File backup rusak atau bukan dari NataSaku'
      };
    }

    if (decoded['app'] != 'NataSaku') {
      return {
        'status': 'error',
        'message': 'File backup rusak atau bukan dari NataSaku'
      };
    }

    // Rule BR3: schemaVersion compatibility check
    final schemaVersion = decoded['schemaVersion'] as int? ?? decoded['version'] as int? ?? 1;
    if (schemaVersion < 1 || schemaVersion > 3) {
      return {
        'status': 'error',
        'message': 'Versi backup tidak kompatibel. Backup ini dibuat di versi lama NataSaku.'
      };
    }

    return {
      'status': 'success',
      'data': decoded['raw'] ?? decoded['data'] ?? decoded
    };
  }
}
