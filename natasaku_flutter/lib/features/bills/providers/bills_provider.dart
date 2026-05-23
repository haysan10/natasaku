import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/datasources/local/local_storage.dart';
import '../../../../data/models/bill_model.dart';
import '../../../../data/models/transaction_model.dart';
import '../../dashboard/providers/dashboard_provider.dart';

class BillsState {
  final List<BillModel> bills;
  final bool isLoading;

  const BillsState({
    this.bills = const [],
    this.isLoading = false,
  });

  BillsState copyWith({
    List<BillModel>? bills,
    bool? isLoading,
  }) {
    return BillsState(
      bills: bills ?? this.bills,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  int get totalUnpaid => bills.where((b) => !b.isPaid).fold(0, (sum, b) => sum + b.amount);
  int get totalBills => bills.fold(0, (sum, b) => sum + b.amount);
}

class BillsNotifier extends StateNotifier<BillsState> {
  final LocalStorage _storage;
  final Ref _ref;

  BillsNotifier(this._storage, this._ref) : super(const BillsState(isLoading: true)) {
    loadBills();
  }

  Future<void> loadBills() async {
    state = state.copyWith(isLoading: true);
    final raw = await _storage.getBills();
    var bills = raw.map((e) => BillModel.fromJson(e)).toList();
    
    final today = DateTime.now();
    final currentMonthStart = DateTime(today.year, today.month, 1);
    bool changed = false;
    
    for (int i = 0; i < bills.length; i++) {
      final bill = bills[i];
      final lastPayDate = bill.lastPaymentDate != null 
          ? DateTime.tryParse(bill.lastPaymentDate!) 
          : (bill.lastAutoPayDate != null ? DateTime.tryParse(bill.lastAutoPayDate!) : null);
          
      if (bill.isPaid && lastPayDate != null && lastPayDate.isBefore(currentMonthStart)) {
        bills[i] = bill.copyWith(isPaid: false);
        changed = true;
      }
    }
    
    if (changed) {
      await _storage.saveBills(bills.map((e) => e.toJson()).toList());
    }

    // Sort unpaid first, then by due date
    bills.sort((a, b) {
      if (a.isPaid != b.isPaid) return a.isPaid ? 1 : -1;
      return (a.dueDate ?? 32).compareTo(b.dueDate ?? 32);
    });

    state = state.copyWith(bills: bills, isLoading: false);
  }

  Future<void> addBill(BillModel bill) async {
    final newList = [...state.bills, bill];
    await _storage.saveBills(newList.map((e) => e.toJson()).toList());
    await loadBills();
    await _ref.read(dashboardProvider.notifier).loadData();
  }

  Future<void> upsertBill(BillModel bill) async {
    final exists = state.bills.any((b) => b.id == bill.id);
    List<BillModel> newList;
    if (exists) {
      newList = state.bills.map((b) => b.id == bill.id ? bill : b).toList();
    } else {
      newList = [...state.bills, bill];
    }
    await _storage.saveBills(newList.map((e) => e.toJson()).toList());
    await loadBills();
    await _ref.read(dashboardProvider.notifier).loadData();
  }

  Future<void> removeBill(String id) async {
    final newList = state.bills.where((b) => b.id != id).toList();
    await _storage.saveBills(newList.map((e) => e.toJson()).toList());
    await loadBills();
    await _ref.read(dashboardProvider.notifier).loadData();
  }

  Future<void> markAsPaid(String id) async {
    final today = DateTime.now();
    final bill = state.bills.firstWhere((b) => b.id == id);
    final newList = state.bills.map((b) => b.id == id ? b.copyWith(
      isPaid: true,
      lastPaymentDate: today.toIso8601String(),
    ) : b).toList();
    await _storage.saveBills(newList.map((e) => e.toJson()).toList());
    
    // Also automatically create a transaction for it!
    final tx = TransactionModel(
      id: today.microsecondsSinceEpoch.toString(),
      date: today,
      amount: bill.amount,
      isExpense: true,
      category: 'Tagihan',
      note: 'Pembayaran tagihan: ${bill.name}',
    );
    await _ref.read(dashboardProvider.notifier).addTransaction(tx);
    
    await loadBills();
  }

  Future<void> resetAllPaidStatus() async {
    final newList = state.bills.map((b) => b.copyWith(
      isPaid: false,
      lastPaymentDate: null,
      lastAutoPayDate: null,
    )).toList();
    await _storage.saveBills(newList.map((e) => e.toJson()).toList());
    await loadBills();
  }
}

final billsProvider = StateNotifierProvider<BillsNotifier, BillsState>((ref) {
  return BillsNotifier(LocalStorage(), ref);
});
