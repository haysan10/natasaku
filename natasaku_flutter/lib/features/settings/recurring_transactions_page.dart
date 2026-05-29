import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/services/currency_service.dart';
import '../../core/providers/repository_providers.dart';
import '../../data/models/recurring_transaction.dart';
import '../../shared/widgets/transaction_entry_sheet.dart';
import '../../shared/widgets/nata_money_input.dart';

class RecurringTransactionsPage extends ConsumerStatefulWidget {
  const RecurringTransactionsPage({super.key});

  @override
  ConsumerState<RecurringTransactionsPage> createState() =>
      _RecurringTransactionsPageState();
}

class _RecurringTransactionsPageState
    extends ConsumerState<RecurringTransactionsPage> {
  List<RecurringTransaction> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final repo = ref.read(budgetRepositoryProvider);
    final items = await repo.loadRecurringTransactions();
    if (mounted) {
      setState(() {
        _items = items;
        _isLoading = false;
      });
    }
  }

  Future<void> _addRecurring() async {
    final result = await showModalBottomSheet<RecurringTransaction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _RecurringFormSheet(),
    );
    if (result == null) return;

    final repo = ref.read(budgetRepositoryProvider);
    await repo.upsertRecurringTransaction(result);
    HapticFeedback.lightImpact();
    await _loadData();
  }

  Future<void> _editRecurring(RecurringTransaction item) async {
    final result = await showModalBottomSheet<RecurringTransaction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RecurringFormSheet(initial: item),
    );
    if (result == null) return;

    final repo = ref.read(budgetRepositoryProvider);
    await repo.upsertRecurringTransaction(result);
    HapticFeedback.lightImpact();
    await _loadData();
  }

  Future<void> _deleteRecurring(RecurringTransaction item) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _DeleteConfirmSheet(item: item),
    );
    if (confirmed != true) return;

    final repo = ref.read(budgetRepositoryProvider);
    await repo.deleteRecurringTransaction(item.id);
    HapticFeedback.mediumImpact();
    await _loadData();
  }

  Future<void> _toggleActive(RecurringTransaction item) async {
    final repo = ref.read(budgetRepositoryProvider);
    await repo.upsertRecurringTransaction(
      item.copyWith(isActive: !item.isActive),
    );
    HapticFeedback.selectionClick();
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi Berulang'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRecurring,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PhosphorIcon(
                        PhosphorIconsRegular.clockCounterClockwise,
                        size: 64,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada transaksi berulang',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tambahkan transaksi otomatis seperti\nkopi harian atau langganan bulanan.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _addRecurring,
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Sekarang'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return _RecurringCard(
                        item: item,
                        onEdit: () => _editRecurring(item),
                        onDelete: () => _deleteRecurring(item),
                        onToggle: () => _toggleActive(item),
                      ).animate().fade(delay: (index * 80).ms).slideY(
                            begin: 0.05,
                            duration: 300.ms,
                            curve: Curves.fastOutSlowIn,
                          );
                    },
                  ),
                ),
    );
  }
}

class _RecurringCard extends StatelessWidget {
  const _RecurringCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  final RecurringTransaction item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = item.isExpense ? AppColors.alert : AppColors.accent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: item.isActive
              ? (isDark ? AppColors.borderDark : AppColors.borderLight)
              : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onEdit,
          onLongPress: onDelete,
          borderRadius: BorderRadius.circular(24),
          child: Opacity(
            opacity: item.isActive ? 1.0 : 0.5,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: PhosphorIcon(
                        PhosphorIconsRegular.clockCounterClockwise,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.categoryName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.frequencyLabel} • Berikutnya: ${DateFormat('dd MMM', 'id_ID').format(item.nextDueDate)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (item.note != null && item.note!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.note!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${item.isExpense ? '-' : '+'}${CurrencyService.formatRupiah(item.amount).replaceAll('Rp', '')}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: onToggle,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: item.isActive
                                ? AppColors.success.withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.isActive ? 'Aktif' : 'Nonaktif',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: item.isActive
                                  ? AppColors.success
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecurringFormSheet extends StatefulWidget {
  const _RecurringFormSheet({this.initial});
  final RecurringTransaction? initial;

  @override
  State<_RecurringFormSheet> createState() => _RecurringFormSheetState();
}

class _RecurringFormSheetState extends State<_RecurringFormSheet> {
  late bool _isExpense;
  late String _frequency;
  String? _category;
  String? _note;
  int _amount = 0;
  late DateTime _nextDueDate;
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _isExpense = initial?.isExpense ?? true;
    _frequency = initial?.frequency ?? 'monthly';
    _category = initial?.categoryName;
    _note = initial?.note;
    _amount = initial?.amount ?? 0;
    _nextDueDate = initial?.nextDueDate ?? DateTime.now().add(const Duration(days: 1));
    _amountController = TextEditingController(
      text: _amount > 0 ? _amount.toString() : '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.initial != null;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
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
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isEditing ? 'Edit Transaksi Berulang' : 'Transaksi Berulang Baru',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),

                // Type toggle
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Pengeluaran')),
                    ButtonSegment(value: false, label: Text('Pemasukan')),
                  ],
                  selected: {_isExpense},
                  onSelectionChanged: (val) =>
                      setState(() => _isExpense = val.first),
                ),
                const SizedBox(height: 16),

                // Category
                Text('Kategori', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: nataCategories
                      .map(
                        (c) => ChoiceChip(
                          label: Text(c),
                          selected: _category == c,
                          onSelected: (_) => setState(() => _category = c),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),

                // Amount
                NataMoneyInput(
                  controller: _amountController,
                  withPrefix: true,
                  decoration: InputDecoration(
                    labelText: 'Nominal',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _amount =
                          int.tryParse(val.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Frequency
                Text('Frekuensi', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'daily', label: Text('Harian')),
                    ButtonSegment(value: 'weekly', label: Text('Mingguan')),
                    ButtonSegment(value: 'monthly', label: Text('Bulanan')),
                  ],
                  selected: {_frequency},
                  onSelectionChanged: (val) =>
                      setState(() => _frequency = val.first),
                ),
                const SizedBox(height: 16),

                // Next due date
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_rounded),
                  title: Text(
                    'Mulai: ${DateFormat('dd MMM yyyy', 'id_ID').format(_nextDueDate)}',
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _nextDueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => _nextDueDate = picked);
                  },
                ),
                const SizedBox(height: 8),

                // Note
                TextFormField(
                  initialValue: _note,
                  decoration: InputDecoration(
                    labelText: 'Catatan (opsional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onChanged: (val) => _note = val.trim().isEmpty ? null : val.trim(),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: (_amount > 0 && _category != null)
                        ? () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(
                              context,
                              RecurringTransaction(
                                id: widget.initial?.id ??
                                    DateTime.now()
                                        .microsecondsSinceEpoch
                                        .toString(),
                                categoryName: _category!,
                                amount: _amount,
                                isExpense: _isExpense,
                                note: _note,
                                frequency: _frequency,
                                nextDueDate: _nextDueDate,
                                lastExecutedDate:
                                    widget.initial?.lastExecutedDate,
                                isActive: widget.initial?.isActive ?? true,
                              ),
                            );
                          }
                        : null,
                    child: Text(isEditing ? 'Simpan Perubahan' : 'Tambah'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteConfirmSheet extends StatelessWidget {
  const _DeleteConfirmSheet({required this.item});
  final RecurringTransaction item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161618) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: const PhosphorIcon(
              PhosphorIconsRegular.trash,
              color: Color(0xFFF87171),
              size: 32,
            ),
          ),
          const SizedBox(height: 24),
          Text('Hapus Transaksi Berulang?',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            '${item.categoryName} (${CurrencyService.formatRupiah(item.amount)}) ${item.frequencyLabel.toLowerCase()} akan dihapus.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFF87171),
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Ya, Hapus'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
