import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/services/currency_service.dart';
import '../../data/datasources/local/local_storage.dart';
import '../../data/models/debt_model.dart';
import '../../data/repositories/budget_repository.dart';

class DebtsPage extends StatefulWidget {
  const DebtsPage({super.key});

  @override
  State<DebtsPage> createState() => _DebtsPageState();
}

class _DebtsPageState extends State<DebtsPage> with SingleTickerProviderStateMixin {
  final BudgetRepository _repo = BudgetRepository(LocalStorage());
  late TabController _tabController;

  List<DebtModel> _debts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDebts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDebts() async {
    setState(() => _loading = true);
    final list = await _repo.loadDebts();
    setState(() {
      _debts = list;
      _loading = false;
    });
  }

  Future<void> _saveDebt(DebtModel debt) async {
    await _repo.upsertDebt(debt);
    await _loadDebts();
  }

  Future<void> _deleteDebt(String id) async {
    await _repo.deleteDebt(id);
    await _loadDebts();
  }

  int get _totalOwedToOthers {
    return _debts
        .where((d) => d.isIoweThem && !d.isPaid)
        .fold(0, (sum, d) => sum + d.amount);
  }

  int get _totalOwedToMe {
    return _debts
        .where((d) => !d.isIoweThem && !d.isPaid)
        .fold(0, (sum, d) => sum + d.amount);
  }

  void _showAddEditDebtDialog([DebtModel? debt]) {
    final isEdit = debt != null;
    final nameController = TextEditingController(text: debt?.name);
    final amountController = TextEditingController(
      text: debt != null ? debt.amount.toString() : '',
    );
    final noteController = TextEditingController(text: debt?.note);

    bool isIoweThem = debt?.isIoweThem ?? true;
    DateTime? dueDate = debt?.dueDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isEdit ? 'Ubah Catatan Utang' : 'Catat Utang Baru',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 20),
                  // Direction Selector (Saya Berutang vs Orang Berutang)
                  Row(
                    children: [
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isIoweThem
                                ? AppColors.alert.withValues(alpha: 0.1)
                                : (isDark ? AppColors.surfaceVariantDark : Colors.white),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isIoweThem ? AppColors.alert : (isDark ? AppColors.borderDark : AppColors.borderLight),
                              width: isIoweThem ? 2 : 1,
                            ),
                          ),
                          child: InkWell(
                            onTap: () => setModalState(() => isIoweThem = true),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: Text(
                                  'Saya Berutang',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isIoweThem ? AppColors.alert : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: !isIoweThem
                                ? AppColors.accent.withValues(alpha: 0.1)
                                : (isDark ? AppColors.surfaceVariantDark : Colors.white),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: !isIoweThem ? AppColors.accent : (isDark ? AppColors.borderDark : AppColors.borderLight),
                              width: !isIoweThem ? 2 : 1,
                            ),
                          ),
                          child: InkWell(
                            onTap: () => setModalState(() => isIoweThem = false),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: Text(
                                  'Orang Berutang',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: !isIoweThem ? AppColors.accent : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Name field
                  TextField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Nama Kontak',
                      prefixIcon: const Icon(PhosphorIconsRegular.user),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Amount field
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Nominal (Rupiah)',
                      prefixIcon: const Icon(PhosphorIconsRegular.coins),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Due Date Selection
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    leading: const Icon(PhosphorIconsRegular.calendar),
                    title: Text(
                      dueDate == null
                          ? 'Set Tenggat Waktu (Opsional)'
                          : DateFormat('dd MMMM yyyy', 'id_ID').format(dueDate!),
                    ),
                    trailing: dueDate != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setModalState(() => dueDate = null),
                          )
                        : null,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: dueDate ?? DateTime.now(),
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                      );
                      if (picked != null) {
                        setModalState(() => dueDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Note field
                  TextField(
                    controller: noteController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Catatan tambahan',
                      prefixIcon: const Icon(PhosphorIconsRegular.note),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: isIoweThem ? AppColors.alert : AppColors.accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        final name = nameController.text.trim();
                        final amountText = amountController.text.trim();
                        final amount = int.tryParse(amountText) ?? 0;

                        if (name.isEmpty || amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Nama dan nominal valid harus diisi!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        final resultDebt = DebtModel(
                          id: debt?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
                          name: name,
                          amount: amount,
                          isIoweThem: isIoweThem,
                          note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                          dueDate: dueDate,
                          isPaid: debt?.isPaid ?? false,
                        );

                        Navigator.pop(context);
                        _saveDebt(resultDebt);
                      },
                      child: Text(
                        isEdit ? 'Simpan Perubahan' : 'Catat Utang',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.darkCardGradient
            : const LinearGradient(
                colors: [Colors.white, AppColors.backgroundLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.alert,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Saya Berutang',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  CurrencyService.formatRupiah(_totalOwedToOthers),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.alert,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 48,
            color: isDark ? Colors.white10 : Colors.black12,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Orang Berutang',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  CurrencyService.formatRupiah(_totalOwedToMe),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtList(List<DebtModel> items, bool isDark) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconsRegular.handsClapping,
              size: 64,
              color: isDark ? Colors.white24 : Colors.black12,
            ),
            const SizedBox(height: 16),
            Text(
              'Semua beres! Tidak ada utang aktif.',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final activeColor = item.isIoweThem ? AppColors.alert : AppColors.accent;

        return Dismissible(
          key: Key(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(PhosphorIconsRegular.trash, color: Colors.white),
          ),
          onDismissed: (_) {
            HapticFeedback.mediumImpact();
            _deleteDebt(item.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Catatan utang ${item.name} berhasil dihapus.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: InkWell(
            onTap: () => _showAddEditDebtDialog(item),
            borderRadius: BorderRadius.circular(20),
            child: Ink(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: item.isPaid
                      ? (isDark ? Colors.white10 : Colors.black12)
                      : activeColor.withValues(alpha: 0.3),
                  width: item.isPaid ? 1 : 1.5,
                ),
              ),
              child: Row(
                children: [
                  // Paid check toggle circle
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _saveDebt(item.copyWith(isPaid: !item.isPaid));
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: item.isPaid ? activeColor : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: item.isPaid ? activeColor : (isDark ? Colors.white30 : Colors.black38),
                          width: 2,
                        ),
                      ),
                      child: item.isPaid
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            decoration: item.isPaid ? TextDecoration.lineThrough : null,
                            color: item.isPaid
                                ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)
                                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                          ),
                        ),
                        if (item.note != null && item.note!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.note!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                        if (item.dueDate != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                PhosphorIconsRegular.calendar,
                                size: 12,
                                color: isDark ? Colors.white30 : Colors.black38,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Jatuh tempo: ${DateFormat('dd MMM yyyy', 'id_ID').format(item.dueDate!)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.white30 : Colors.black38,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    CurrencyService.formatRupiah(item.amount),
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      decoration: item.isPaid ? TextDecoration.lineThrough : null,
                      color: item.isPaid
                          ? (isDark ? Colors.white30 : Colors.black38)
                          : activeColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final myDebts = _debts.where((d) => d.isIoweThem).toList();
    final myReceivables = _debts.where((d) => !d.isIoweThem).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mode Utang'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddEditDebtDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: _buildSummaryCard(isDark),
                ),
                // Tab bar selection
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  tabs: const [
                    Tab(text: 'Saya Berutang'),
                    Tab(text: 'Orang Berutang'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDebtList(myDebts, isDark),
                      _buildDebtList(myReceivables, isDark),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
