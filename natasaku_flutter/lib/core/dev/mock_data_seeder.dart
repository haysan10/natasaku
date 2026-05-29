import 'dart:math';
import '../../data/datasources/local/local_storage.dart';
import '../../data/models/budget_mode.dart';

/// Inject realistic UMR-level mock data for testing.
/// Run once from a dev screen or setup page.
class MockDataSeeder {
  static final _rng = Random();

  static Future<void> seed() async {
    final storage = LocalStorage();

    // ── Period: current month UMR Jakarta ~Rp5.000.000 ─────────────────────
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);

    await storage.saveBudgetPeriod({
      'id': 'active_period',
      'startDate': start.toIso8601String(),
      'endDate': end.toIso8601String(),
      'flexibleFund': 5000000.0,
      'mode': BudgetMode.normal.name,
    });

    // ── Saving Goal ─────────────────────────────────────────────────────────
    await storage.saveSavingGoal({
      'id': 'active_saving_goal',
      'name': 'Dana Darurat 🛡️',
      'targetAmount': 15000000.0,
      'currentAmount': 2500000.0,
      'targetDate': DateTime(now.year + 1).toIso8601String(),
    });

    // ── Transactions: realistic 18 days ────────────────────────────────────
    final notes = {
      'Makan': ['Makan siang Warteg', 'Sarapan bubur', 'Makan malam nasi padang', 'Bakso'],
      'Minum': ['Kopi kekinian', 'Jus buah', 'Es teh', 'Boba'],
      'Transport': ['Gojek ke kantor', 'KRL commuter', 'Grab pulang', 'Parkir motor'],
      'Belanja': ['Indomaret', 'Alfamart snack', 'Shopee bulanan', 'Kebutuhan dapur'],
      'Hiburan': ['Netflix', 'Bioskop', 'Game top up', 'Spotify'],
      'Kesehatan': ['Vitamin C', 'Obat flu', 'Masker', 'Klinik'],
      'Tagihan': ['Token listrik', 'Internet WiFi', 'Pulsa'],
      'Lainnya': ['Transfer', 'Kado teman', 'Print dokumen'],
    };

    final txList = <Map<String, dynamic>>[];
    int idCounter = 1;

    // Pemasukan tambahan (gaji sudah tercermin di flexibleFund periode)
    txList.add({
      'id': 'tx_${idCounter++}',
      'date': DateTime(now.year, now.month, min(8, now.day)).toIso8601String(),
      'amount': 300000,
      'isExpense': false,
      'category': 'Pemasukan',
      'note': 'Freelance desain',
    });

    // Pengeluaran harian otomatis dari tanggal 1 sampai hari ini
    for (int day = 1; day <= now.day; day++) {
      // 1 sampai 3 transaksi per hari untuk variasi visual
      final txCount = 1 + _rng.nextInt(3);
      for (int i = 0; i < txCount; i++) {
        final categories = notes.keys.toList();
        final cat = categories[_rng.nextInt(categories.length)];
        final noteList = notes[cat]!;
        
        // Nominal belanja bervariasi Rp10.000 - Rp80.000
        final amt = 10000 + _rng.nextInt(70) * 1000;

        txList.add({
          'id': 'tx_${idCounter++}',
          'date': DateTime(now.year, now.month, day,
            8 + _rng.nextInt(12), _rng.nextInt(59)).toIso8601String(),
          'amount': amt,
          'isExpense': true,
          'category': cat,
          'note': noteList[_rng.nextInt(noteList.length)],
        });
      }
    }

    await storage.saveTransactions(txList);
  }

  /// Hapus semua data (reset ke kondisi fresh install)
  static Future<void> clear() async {
    final storage = LocalStorage();
    await storage.saveTransactions([]);
    await storage.saveBudgetPeriod({'id': '', 'startDate': '', 'endDate': '', 'flexibleFund': 0.0, 'mode': 'normal'});
  }
}
