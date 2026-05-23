import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/currency_service.dart';
import '../../data/models/transaction_model.dart';
import '../../shared/widgets/main_shell.dart';
import '../../shared/widgets/transaction_entry_sheet.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/nata_shimmer.dart';
import '../../shared/widgets/nata_swipeable_row.dart';
import '../dashboard/providers/dashboard_provider.dart';

enum _TransactionFilter { all, expense, income }

class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  _TransactionFilter _filter = _TransactionFilter.all;
  int _visibleCount = 30;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _visibleCount = 30; // reset pagination count on search query change
      });
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (_visibleCount < _filteredItems.length) {
          setState(() {
            _visibleCount += 30;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onNavigate(int index) {
    switch (index) {
      case 0: context.go(AppRouter.dashboard); break;
      case 1: break; // current
      case 2: context.go(AppRouter.budget); break;
      case 3: context.go(AppRouter.savings); break;
      case 4: context.go(AppRouter.reports); break;
    }
  }

  Future<void> _addTransaction() async {
    final draft = await showTransactionEntrySheet(context);
    if (draft == null) return;

    final transaction = TransactionModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      date: draft.date,
      amount: draft.amount,
      isExpense: draft.isExpense,
      note: draft.note,
      category: draft.category,
    );
    
    await ref.read(dashboardProvider.notifier).addTransaction(transaction);
    
    if (!mounted) return;
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Sip! Transaksi berhasil dicatat.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          action: SnackBarAction(
            label: 'Batal',
            textColor: AppColors.primarySoft,
            onPressed: () {
              ref.read(dashboardProvider.notifier).deleteTransaction(transaction.id);
            },
          ),
        ),
      );
  }

  Future<void> _editTransaction(TransactionModel tx) async {
    final draft = await showTransactionEntrySheet(
      context,
      initialExpense: tx.isExpense,
      initialAmount: tx.amount,
      initialCategory: tx.category,
      initialNote: tx.note,
      initialDate: tx.date,
    );
    if (draft == null) return;

    // Delete old, add new
    await ref.read(dashboardProvider.notifier).deleteTransaction(tx.id);
    final updatedTx = TransactionModel(
      id: tx.id,
      date: draft.date,
      amount: draft.amount,
      isExpense: draft.isExpense,
      note: draft.note,
      category: draft.category,
    );
    await ref.read(dashboardProvider.notifier).addTransaction(updatedTx);
  }

  Future<void> _deleteTransaction(TransactionModel tx) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _DeleteConfirmSheet(tx: tx),
    );
    
    if (confirmed != true) return;

    await ref.read(dashboardProvider.notifier).deleteTransaction(tx.id);
    
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Transaksi dihapus.'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Pulihkan',
            textColor: AppColors.primarySoft,
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(dashboardProvider.notifier).addTransaction(tx);
            },
          ),
        ),
      );
  }

  List<TransactionModel> get _filteredItems {
    final allItems = ref.read(dashboardProvider).transactions;
    final sorted = List<TransactionModel>.from(allItems)..sort((a, b) => b.date.compareTo(a.date));
    
    final query = _searchController.text.trim().toLowerCase();
    return sorted.where((tx) {
      final matchesType = switch (_filter) {
        _TransactionFilter.all => true,
        _TransactionFilter.expense => tx.isExpense,
        _TransactionFilter.income => !tx.isExpense,
      };
      if (!matchesType) return false;
      if (query.isEmpty) return true;
      final haystack = [
        tx.category,
        tx.note,
        CurrencyService.formatRupiah(tx.amount),
        tx.isExpense ? 'pengeluaran' : 'pemasukan',
      ].whereType<String>().join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  Map<String, List<TransactionModel>> _groupByDate(List<TransactionModel> items) {
    final grouped = <String, List<TransactionModel>>{};
    for (final item in items) {
      final key = _dateLabel(item.date);
      grouped.putIfAbsent(key, () => <TransactionModel>[]).add(item);
    }
    return grouped;
  }
  
  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Hari Ini';
    }
    if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
      return 'Kemarin';
    }
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    final filtered = _filteredItems;
    final paginated = filtered.take(_visibleCount).toList();
    final grouped = _groupByDate(paginated);
    final totalExpense = filtered.where((tx) => tx.isExpense).fold(0.0, (sum, tx) => sum + tx.amount);
    final totalIncome = filtered.where((tx) => !tx.isExpense).fold(0.0, (sum, tx) => sum + tx.amount);

    final content = Scaffold(
      body: SafeArea(
        child: state.isLoading
            ? _buildTransactionShimmer()
            : RefreshIndicator(
                onRefresh: () => ref.read(dashboardProvider.notifier).loadData(),
                color: AppColors.primary,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Riwayat',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Text(
                                      'Transaksi',
                                      style: Theme.of(context).textTheme.headlineLarge,
                                    ),
                                  ],
                                ).animate().fade().slideX(begin: -0.1),
                                
                                IconButton(
                                  onPressed: () {
                                    // context.push(AppRouter.settings);
                                  },
                                  icon: const PhosphorIcon(PhosphorIconsRegular.faders),
                                ).animate().fade(delay: 200.ms),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Custom Search Bar
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? AppColors.borderDark : AppColors.borderLight),
                              ),
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Cari jajan apa ya...',
                                  hintStyle: Theme.of(context).textTheme.bodyMedium,
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16),
                                    child: PhosphorIcon(PhosphorIconsRegular.magnifyingGlass, color: AppColors.textSecondaryLight),
                                  ),
                                  prefixIconConstraints: const BoxConstraints(minWidth: 50),
                                  suffixIcon: _searchController.text.isEmpty
                                      ? null
                                      : IconButton(
                                          onPressed: _searchController.clear,
                                          icon: const PhosphorIcon(PhosphorIconsRegular.xCircle),
                                        ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  fillColor: Colors.transparent,
                                  filled: false,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
                            
                            const SizedBox(height: 20),
                            
                            // Custom Choice Chips
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: [
                                  _CustomChip(
                                    label: 'Semua',
                                    icon: PhosphorIconsRegular.circlesFour,
                                    isSelected: _filter == _TransactionFilter.all,
                                    onTap: () => setState(() => _filter = _TransactionFilter.all),
                                  ),
                                  const SizedBox(width: 12),
                                  _CustomChip(
                                    label: 'Pengeluaran',
                                    icon: PhosphorIconsRegular.trendDown,
                                    color: AppColors.alert,
                                    isSelected: _filter == _TransactionFilter.expense,
                                    onTap: () => setState(() => _filter = _TransactionFilter.expense),
                                  ),
                                  const SizedBox(width: 12),
                                  _CustomChip(
                                    label: 'Pemasukan',
                                    icon: PhosphorIconsRegular.trendUp,
                                    color: AppColors.accent,
                                    isSelected: _filter == _TransactionFilter.income,
                                    onTap: () => setState(() => _filter = _TransactionFilter.income),
                                  ),
                                ],
                              ),
                            ).animate().fade(delay: 200.ms).slideX(begin: 0.1),
                            
                            const SizedBox(height: 24),
                            
                            // Summary metrics
                            Row(
                              children: [
                                Expanded(
                                  child: _SummaryCard(
                                    title: 'Keluar',
                                    amount: totalExpense,
                                    isExpense: true,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _SummaryCard(
                                    title: 'Masuk',
                                    amount: totalIncome,
                                    isExpense: false,
                                  ),
                                ),
                              ],
                            ).animate().fade(delay: 300.ms).slideY(begin: 0.1),
                          ],
                        ),
                      ),
                    ),
                    
                    if (state.transactions.isEmpty)
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: NataEmptyState(
                                  icon: PhosphorIconsRegular.receipt,
                                  title: 'Yuk Mulai Catat! 📝',
                                  subtitle: 'Belum ada transaksi nih.\nTekan tombol + di bawah untuk mencatat jajan pertamamu hari ini!',
                                  buttonLabel: 'Catat Sekarang',
                                  onButtonTap: _addTransaction,
                                  accentColor: AppColors.primary,
                                ),
                              )
                    else if (filtered.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: NataEmptyState(
                          icon: PhosphorIconsRegular.magnifyingGlass,
                          title: 'Tidak Ditemukan',
                          subtitle: 'Tidak ada transaksi yang cocok dengan filter atau pencarianmu.',
                          accentColor: AppColors.textSecondaryLight,
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final entry = grouped.entries.elementAt(index);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16, bottom: 12),
                                    child: Text(
                                      entry.key,
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: Theme.of(context).brightness == Brightness.dark 
                                            ? AppColors.textSecondaryDark 
                                            : AppColors.textSecondaryLight,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ).animate().fade(),
                                   ...entry.value.map((tx) {
                                      final messenger = ScaffoldMessenger.of(context);
                                      return NataSwipeableRow(
                                        onEdit: () => _editTransaction(tx),
                                        onDeleteConfirmed: () => ref.read(dashboardProvider.notifier).deleteTransaction(tx.id).then((_) {
                                          if (mounted) {
                                            messenger
                                              ..hideCurrentSnackBar()
                                              ..showSnackBar(
                                                SnackBar(
                                                  content: const Text('Transaksi dihapus.'),
                                                  duration: const Duration(seconds: 5),
                                                  action: SnackBarAction(
                                                    label: 'Pulihkan',
                                                    textColor: AppColors.primarySoft,
                                                    onPressed: () {
                                                      HapticFeedback.lightImpact();
                                                      ref.read(dashboardProvider.notifier).addTransaction(tx);
                                                    },
                                                  ),
                                                ),
                                              );
                                          }
                                        }),
                                        deleteConfirmTitle: 'Hapus catatan ini?',
                                        deleteConfirmSubtitle: 'Catatan ${CurrencyService.formatRupiah(tx.amount)} akan dihapus dari riwayatmu.',
                                        child: _TransactionRow(
                                          transaction: tx,
                                          onEdit: () => _editTransaction(tx),
                                          onDelete: () => _deleteTransaction(tx),
                                        ),
                                      );
                                    }),
                                ],
                              );
                            },
                            childCount: grouped.length,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
        ),
      );

    final hasShell = context.findAncestorWidgetOfExactType<MainShell>() != null;
    if (hasShell) {
      return content;
    } else {
      return MainShell(
        index: 1,
        onNavigate: _onNavigate,
        child: content,
      );
    }
  }

  Widget _buildTransactionShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NataShimmer(width: 120, height: 18, borderRadius: BorderRadius.circular(9)),
          const SizedBox(height: 4),
          NataShimmer(width: 160, height: 32, borderRadius: BorderRadius.circular(8)),
          const SizedBox(height: 24),
          NataShimmer(width: double.infinity, height: 52, borderRadius: BorderRadius.circular(20)),
          const SizedBox(height: 16),
          Row(
            children: [
              NataShimmer(width: 90, height: 44, borderRadius: BorderRadius.circular(20)),
              const SizedBox(width: 12),
              NataShimmer(width: 110, height: 44, borderRadius: BorderRadius.circular(20)),
              const SizedBox(width: 12),
              NataShimmer(width: 100, height: 44, borderRadius: BorderRadius.circular(20)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: NataShimmer(width: double.infinity, height: 72, borderRadius: BorderRadius.circular(24))),
              const SizedBox(width: 16),
              Expanded(child: NataShimmer(width: double.infinity, height: 72, borderRadius: BorderRadius.circular(24))),
            ],
          ),
          const SizedBox(height: 24),
          for (int i = 0; i < 6; i++) const NataListItemShimmer(),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final num amount;
  final bool isExpense;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.isExpense,
  });

  @override
  Widget build(BuildContext context) {
    final color = isExpense ? AppColors.alert : AppColors.accent;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PhosphorIcon(isExpense ? PhosphorIconsRegular.trendDown : PhosphorIconsRegular.trendUp, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyService.formatRupiah(amount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _CustomChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: isSelected ? activeColor : (isDark ? AppColors.surfaceVariantDark : Colors.white),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? activeColor : (isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PhosphorIcon(
                icon, 
                size: 16, 
                color: isSelected ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isSelected ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  final TransactionModel transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = transaction.isExpense ? AppColors.alert : AppColors.accent;
    final title = transaction.category ?? (transaction.isExpense ? 'Pengeluaran' : 'Pemasukan');
    final note = transaction.note?.trim();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onEdit,
          onLongPress: onDelete,
          borderRadius: BorderRadius.circular(24),
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
                  child: PhosphorIcon(
                    transaction.isExpense ? PhosphorIconsRegular.basket : PhosphorIconsRegular.wallet,
                    color: color,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (note != null && note.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          note,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${transaction.isExpense ? '-' : '+'}${CurrencyService.formatRupiah(transaction.amount).replaceAll('Rp', '')}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fade().scale(curve: Curves.easeOutBack, alignment: Alignment.centerLeft);
  }
}

class _DeleteConfirmSheet extends StatelessWidget {
  final TransactionModel tx;
  const _DeleteConfirmSheet({required this.tx});

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
              color: Color(0xFFFEE2E2), // rose soft, bukan merah penuh
              shape: BoxShape.circle,
            ),
            child: const PhosphorIcon(
              PhosphorIconsRegular.trash,
              color: Color(0xFFF87171),
              size: 32,
            ),
          ),
          const SizedBox(height: 24),
          Text('Hapus Catatan Ini?', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Catatan ${CurrencyService.formatRupiah(tx.amount)} akan dihapus dari riwayatmu.',
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
                  // rose soft button, bukan merah penuh
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
