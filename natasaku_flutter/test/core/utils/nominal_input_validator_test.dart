import 'package:flutter_test/flutter_test.dart';
import 'package:natasaku/core/utils/nominal_input_validator.dart';

void main() {
  group('NominalInputValidator - Kategori 1: Validasi Nominal', () {
    test('Rule N1 & N2: Nominal 0 & Nominal Kosong -> BLOCK', () {
      expect(NominalInputValidator.validateAmount(''), 'Nominal tidak boleh kosong');
      expect(NominalInputValidator.validateAmount('   '), 'Nominal tidak boleh kosong');
      expect(NominalInputValidator.validateAmount('0'), 'Nominal harus lebih dari Rp 0');
      expect(NominalInputValidator.validateAmount('0000'), 'Nominal harus lebih dari Rp 0');
    });

    test('Rule N4, N5, N8: Dots, Commas, Leading Zeros strip', () {
      expect(NominalInputValidator.parseNominal('4.000.000'), 4000000);
      expect(NominalInputValidator.parseNominal('4,000,000'), 4000000);
      expect(NominalInputValidator.parseNominal('007000'), 7000);
      expect(NominalInputValidator.parseNominal('0000150'), 150);
    });

    test('Rule N7: Nominal > 999B limit', () {
      expect(
        NominalInputValidator.validateAmount('1.000.000.000.000'),
        'Nominal terlalu besar. Maksimum Rp 999.999.999.999',
      );
      expect(
        NominalInputValidator.validateAmount('999.999.999.999'),
        isNull,
      );
    });
  });

  group('NominalInputValidator - Kategori 2: Validasi Setup Budget', () {
    test('Rule S1: Total penghasilan WAJIB > 0', () {
      final res = NominalInputValidator.validateSetup(
        totalIncome: 0,
        totalFixedExpense: 0,
        savingAllocation: 0,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
      );
      expect(res['status'], 'error');
      expect(res['message'], 'Total penghasilan wajib lebih dari Rp 0');
    });

    test('Rule S2: Income < Expenses + Savings -> WARNING (not block)', () {
      final res = NominalInputValidator.validateSetup(
        totalIncome: 1000000,
        totalFixedExpense: 800000,
        savingAllocation: 300000,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
      );
      expect(res['status'], 'warning');
      expect(res['message'], contains('Dana fleksibel kamu negatif'));
    });

    test('Rule S3: Start date in the past -> ERROR', () {
      final res = NominalInputValidator.validateSetup(
        totalIncome: 1000000,
        totalFixedExpense: 0,
        savingAllocation: 0,
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 30)),
      );
      expect(res['status'], 'error');
      expect(res['message'], 'Tanggal mulai periode tidak boleh di masa lalu');
    });

    test('Rule S4: Start date = End date -> Period minimal 1 hari', () {
      final today = DateTime.now();
      final res = NominalInputValidator.validateSetup(
        totalIncome: 1000000,
        totalFixedExpense: 0,
        savingAllocation: 0,
        startDate: today,
        endDate: today,
      );
      expect(res['status'], 'error');
      expect(res['message'], 'Periode minimal 1 hari');
    });
  });

  group('NominalInputValidator - Kategori 3: Validasi Transaksi', () {
    test('Rule T1: Date after today -> ERROR', () {
      final err = NominalInputValidator.validateTransaction(
        amount: 50000,
        category: 'Makan',
        transactionDate: DateTime.now().add(const Duration(days: 1)),
        periodStartDate: DateTime.now(),
        note: '',
      );
      expect(err, 'Tanggal transaksi tidak boleh setelah hari ini');
    });

    test('Rule T2: Date before period start -> ERROR', () {
      final err = NominalInputValidator.validateTransaction(
        amount: 50000,
        category: 'Makan',
        transactionDate: DateTime.now().subtract(const Duration(days: 2)),
        periodStartDate: DateTime.now(),
        note: '',
      );
      expect(err, 'Tanggal transaksi tidak boleh sebelum tanggal mulai periode aktif');
    });

    test('Rule T3: Category empty or Uncategorized -> ERROR', () {
      final err = NominalInputValidator.validateTransaction(
        amount: 50000,
        category: 'Uncategorized',
        transactionDate: DateTime.now(),
        periodStartDate: DateTime.now(),
        note: '',
      );
      expect(err, 'Kategori wajib dipilih');
    });

    test('Rule T6: Note > 200 chars -> ERROR', () {
      final longNote = List.generate(201, (_) => 'a').join();
      final err = NominalInputValidator.validateTransaction(
        amount: 50000,
        category: 'Makan',
        transactionDate: DateTime.now(),
        periodStartDate: DateTime.now(),
        note: longNote,
      );
      expect(err, 'Catatan maksimal 200 karakter');
    });
  });

  group('NominalInputValidator - Kategori 4: Validasi Tabungan', () {
    test('Rule SV2: Target tabungan > Income -> WARNING', () {
      final err = NominalInputValidator.validateSavingGoal(
        targetAmount: 2000000,
        totalIncome: 1500000,
      );
      expect(err, 'Target tabungan melebihi penghasilan. Pastikan ini sesuai rencanamu.');
    });
  });

  group('NominalInputValidator - Kategori 5: Validasi Backup/Restore', () {
    test('Rule BR1: Restore non-json suffix -> ERROR', () {
      final res = NominalInputValidator.validateRestore('{}', 'backup.txt');
      expect(res['status'], 'error');
      expect(res['message'], 'File tidak dikenali. Pilih file backup NataSaku (.json)');
    });

    test('Rule BR2: Invalid JSON parse -> ERROR', () {
      final res = NominalInputValidator.validateRestore('{"invalid": ', 'backup.json');
      expect(res['status'], 'error');
      expect(res['message'], 'File backup rusak atau bukan dari NataSaku');
    });

    test('Rule BR3: Wrong schemaVersion -> ERROR', () {
      const raw = '{"app": "NataSaku", "schemaVersion": 5, "raw": {}}';
      final res = NominalInputValidator.validateRestore(raw, 'backup.json');
      expect(res['status'], 'error');
      expect(res['message'], 'Versi backup tidak kompatibel. Backup ini dibuat di versi lama NataSaku.');
    });
  });
}
