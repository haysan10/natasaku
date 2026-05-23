import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/services/currency_service.dart';
import '../../../data/models/bill_model.dart';
import 'providers/bills_provider.dart';

class BillsPage extends ConsumerStatefulWidget {
  const BillsPage({super.key});

  @override
  ConsumerState<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends ConsumerState<BillsPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(billsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tagihan Bulanan',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const PhosphorIcon(PhosphorIconsRegular.arrowCounterClockwise, color: AppColors.primary),
            onPressed: () async {
              HapticFeedback.lightImpact();
              await ref.read(billsProvider.notifier).resetAllPaidStatus();
            },
            tooltip: 'Reset status bayar bulan ini',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddBillSheet(context, ref),
        icon: const PhosphorIcon(PhosphorIconsBold.plus, color: Colors.white, size: 20),
        label: const Text('Tambah Tagihan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ).animate().scale(curve: Curves.easeOutBack, delay: 300.ms),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : state.bills.isEmpty
                ? _buildEmptyState(context)
                : ListView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Header Card Summary
                      Container(
                        padding: const EdgeInsets.all(24),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const PhosphorIcon(PhosphorIconsRegular.receipt, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Sisa Tagihan Bulan Ini',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              CurrencyService.formatRupiah(state.totalUnpaid),
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Dari total ${CurrencyService.formatRupiah(state.totalBills)} anggaran tetap',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ).animate().fade().slideY(begin: 0.1),

                      Text(
                        'Daftar Tagihan',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ).animate().fade(delay: 100.ms),
                      const SizedBox(height: 16),

                      ...state.bills.map((bill) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceVariantDark : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: bill.isPaid ? AppColors.accent.withValues(alpha: 0.3) : (isDark ? AppColors.borderDark : AppColors.borderLight),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: bill.isPaid ? AppColors.accent.withValues(alpha: 0.1) : AppColors.alert.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: PhosphorIcon(
                                      bill.isPaid ? PhosphorIconsRegular.checkCircle : PhosphorIconsRegular.warningCircle,
                                      color: bill.isPaid ? AppColors.accent : AppColors.alert,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          bill.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            decoration: bill.isPaid ? TextDecoration.lineThrough : null,
                                            color: bill.isPaid ? Colors.grey : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              CurrencyService.formatRupiah(bill.amount),
                                              style: TextStyle(
                                                color: bill.isPaid ? Colors.grey : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (bill.isAutoPay) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary.withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: const Row(
                                                  children: [
                                                    Icon(Icons.bolt_rounded, size: 10, color: AppColors.primary),
                                                    SizedBox(width: 2),
                                                    Text('Auto', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        if (bill.dueDate != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            'Tenggat: Tanggal ${bill.dueDate}',
                                            style: TextStyle(color: AppColors.primary.withValues(alpha: 0.8), fontSize: 11),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (!bill.isPaid)
                                    FilledButton.tonal(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                                        foregroundColor: AppColors.accent,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      ),
                                      onPressed: () async {
                                        HapticFeedback.mediumImpact();
                                        await ref.read(billsProvider.notifier).markAsPaid(bill.id);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                            ..hideCurrentSnackBar()
                                            ..showSnackBar(SnackBar(
                                              content: Text('${bill.name} ditandai Lunas & otomatis dicatat di pengeluaran! 🎉'),
                                              backgroundColor: AppColors.accent,
                                            ));
                                        }
                                      },
                                      child: const Text('Bayar', style: TextStyle(fontWeight: FontWeight.bold)),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Lunas',
                                        style: TextStyle(
                                          color: AppColors.accent,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _showAddBillSheet(context, ref, bill),
                                    icon: const Icon(Icons.edit_rounded, size: 16, color: Colors.grey),
                                    label: const Text('Sunting', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  TextButton.icon(
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Hapus Tagihan?'),
                                          content: Text('Apakah Anda yakin ingin menghapus tagihan bulanan "${bill.name}"?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Batal'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              style: TextButton.styleFrom(foregroundColor: AppColors.alert),
                                              child: const Text('Hapus'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        HapticFeedback.lightImpact();
                                        await ref.read(billsProvider.notifier).removeBill(bill.id);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                            ..hideCurrentSnackBar()
                                            ..showSnackBar(const SnackBar(
                                              content: Text('Tagihan berhasil dihapus!'),
                                              backgroundColor: AppColors.primary,
                                            ));
                                        }
                                      }
                                    },
                                    icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.alert),
                                    label: const Text('Hapus', style: TextStyle(color: AppColors.alert, fontSize: 12)),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ).animate().fade(delay: 200.ms).slideY(begin: 0.1);
                      }).toList(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const PhosphorIcon(PhosphorIconsRegular.receipt, color: AppColors.primary, size: 64),
          ).animate().scale(delay: 100.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          Text(
            'Belum Ada Tagihan Tetap',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ).animate().fade(delay: 200.ms),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Tambahkan daftar pengeluaran pasti (Kos, Listrik, Netflix) agar NataSaku dapat menghitung Dana Fleksibel Anda lebih akurat.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ).animate().fade(delay: 300.ms),
        ],
      ),
    );
  }

  void _showAddBillSheet(BuildContext context, WidgetRef ref, [BillModel? existingBill]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddBillSheet(existingBill: existingBill),
    );
  }
}

class _AddBillSheet extends ConsumerStatefulWidget {
  final BillModel? existingBill;
  const _AddBillSheet({this.existingBill});

  @override
  ConsumerState<_AddBillSheet> createState() => _AddBillSheetState();
}

class _AddBillSheetState extends ConsumerState<_AddBillSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _dateController;
  bool _isAutoPay = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingBill?.name ?? '');
    _amountController = TextEditingController(
      text: widget.existingBill == null ? '' : widget.existingBill!.amount.toStringAsFixed(0),
    );
    _dateController = TextEditingController(
      text: widget.existingBill?.dueDate == null ? '' : widget.existingBill!.dueDate!.toString(),
    );
    _isAutoPay = widget.existingBill?.isAutoPay ?? false;
  }

  double _parseAmount(String raw) {
    final value = double.tryParse(raw.replaceAll('.', '').replaceAll(',', '.').trim()) ?? 0;
    return value.isFinite ? value : 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.existingBill != null;
    
    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isEdit ? 'Sunting Tagihan Tetap' : 'Tambah Tagihan Tetap',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Error Message Banner
            if (_errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.alert.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.alert.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.alert),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppColors.alert, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nama Tagihan (Contoh: Kos, Netflix)',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nominal Tagihan (Rp)',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dateController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tanggal Jatuh Tempo (1 - 31)',
                hintText: 'Opsional',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
              ),
            ),
            const SizedBox(height: 20),

            // Automated Payment Toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceVariantDark : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bayar Otomatis (Auto-pay)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(
                          'Bayar otomatis saat tanggal jatuh tempo tiba',
                          style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _isAutoPay,
                    activeColor: AppColors.primary,
                    onChanged: (value) => setState(() => _isAutoPay = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () async {
                  setState(() => _errorMessage = null);
                  final name = _nameController.text.trim();
                  final amount = _parseAmount(_amountController.text);
                  
                  // Validation guards
                  if (name.isEmpty) {
                    setState(() => _errorMessage = 'Nama tagihan tidak boleh kosong!');
                    HapticFeedback.heavyImpact();
                    return;
                  }
                  if (amount <= 0) {
                    setState(() => _errorMessage = 'Nominal tagihan harus lebih dari Rp 0!');
                    HapticFeedback.heavyImpact();
                    return;
                  }
                  if (amount > 9999999999999) {
                    setState(() => _errorMessage = 'Nominal tagihan terlalu besar!');
                    HapticFeedback.heavyImpact();
                    return;
                  }

                  int? date;
                  final dateText = _dateController.text.trim();
                  if (dateText.isNotEmpty) {
                    final parsedDate = int.tryParse(dateText);
                    if (parsedDate == null || parsedDate < 1 || parsedDate > 31) {
                      setState(() => _errorMessage = 'Tanggal jatuh tempo harus berupa angka 1 - 31!');
                      HapticFeedback.heavyImpact();
                      return;
                    }
                    date = parsedDate;
                  }
                  
                  HapticFeedback.lightImpact();
                  final bill = BillModel(
                    id: widget.existingBill?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
                    name: name,
                    amount: amount,
                    dueDate: date,
                    isAutoPay: _isAutoPay,
                    isPaid: widget.existingBill?.isPaid ?? false,
                    lastPaymentDate: widget.existingBill?.lastPaymentDate,
                    lastAutoPayDate: widget.existingBill?.lastAutoPayDate,
                  );
                  await ref.read(billsProvider.notifier).upsertBill(bill);
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(isEdit ? 'Simpan Perubahan' : 'Simpan Tagihan', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
