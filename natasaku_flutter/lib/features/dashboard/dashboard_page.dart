import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/currency_service.dart';
import '../../shared/widgets/main_shell.dart';
import '../../data/models/transaction_model.dart';
import '../../shared/widgets/transaction_entry_sheet.dart';
import '../../core/dev/mock_data_seeder.dart';
import '../bills/providers/bills_provider.dart';
import 'providers/dashboard_provider.dart';
import 'feature_tour_manager.dart';
import '../../shared/widgets/nata_shimmer.dart';
import '../../shared/widgets/nata_status_chip.dart';
import '../../shared/widgets/nata_progress_bar.dart';
import '../../shared/widgets/nata_press_scale.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardContent extends ConsumerStatefulWidget {
  final DashboardState state;
  const _DashboardContent({super.key, required this.state});

  @override
  ConsumerState<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).loadData();
    });
  }

  void _onNavigate(int index) {
    switch (index) {
      case 0: break;
      case 1: context.go(AppRouter.transactions); break;
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);

    final content = FeatureTourManager(
      hasBudget: state.period != null,
      child: Scaffold(
        body: SafeArea(
          child: state.isLoading
              ? _buildShimmerLoading()
              : state.period == null
                  ? const _EmptySetupView()
                  : _DashboardContent(state: state)
                  .animate()
                  .fade(duration: 350.ms)
                  .slideY(
                    begin: 0.04,
                    end: 0.0,
                    duration: 350.ms,
                    curve: Curves.fastOutSlowIn, // NataCurve.smooth
                  ),
        ),
      ),
    );

    final hasShell = context.findAncestorWidgetOfExactType<MainShell>() != null;
    if (hasShell) {
      return content;
    } else {
      return MainShell(
        index: 0,
        onNavigate: _onNavigate,
        child: content,
      );
    }
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NataShimmer(width: 180, height: 20, borderRadius: BorderRadius.circular(10)),
          const SizedBox(height: 8),
          NataShimmer(width: 120, height: 16, borderRadius: BorderRadius.circular(8)),
          const SizedBox(height: 24),
          const NataCardShimmer(height: 180),
          const NataCardShimmer(height: 72),
          const NataCardShimmer(height: 72),
          const NataCardShimmer(height: 120),
          const SizedBox(height: 16),
          NataShimmer(width: 140, height: 18, borderRadius: BorderRadius.circular(9)),
          const SizedBox(height: 12),
          const NataListItemShimmer(),
          const NataListItemShimmer(),
          const NataListItemShimmer(),
        ],
      ),
    );
  }
}

class _DashboardContentState extends ConsumerState<_DashboardContent> with SingleTickerProviderStateMixin {
  bool _hideBalance = false;
  bool _showDiagnosisDetails = false;
  late AnimationController _chartController;

  @override
  void initState() {
    super.initState();
    _chartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _chartController.forward();
  }

  @override
  void dispose() {
    _chartController.dispose();
    super.dispose();
  }

  String _formatMoney(double value) {
    if (_hideBalance) return '••••••';
    return CurrencyService.formatRupiah(value);
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'makan':
      case 'minum':
      case 'kuliner':
        return Icons.restaurant_rounded;
      case 'transport':
      case 'bensin':
      case 'ojek':
        return Icons.directions_car_rounded;
      case 'belanja':
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'hiburan':
      case 'game':
      case 'nonton':
        return Icons.sports_esports_rounded;
      case 'kesehatan':
      case 'obat':
        return Icons.medical_services_rounded;
      case 'tagihan':
      case 'pulsa':
      case 'listrik':
        return Icons.receipt_rounded;
      case 'menabung':
      case 'tabungan':
        return Icons.savings_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'makan':
      case 'minum':
      case 'kuliner':
        return Colors.orange;
      case 'transport':
      case 'bensin':
      case 'ojek':
        return Colors.blue;
      case 'belanja':
      case 'shopping':
        return Colors.purple;
      case 'hiburan':
      case 'game':
      case 'nonton':
        return Colors.pink;
      case 'kesehatan':
      case 'obat':
        return Colors.red;
      case 'tagihan':
      case 'pulsa':
      case 'listrik':
        return Colors.cyan;
      case 'menabung':
      case 'tabungan':
        return AppColors.accent;
      default:
        return AppColors.primary;
    }
  }

  List<BarChartGroupData> _buildChartGroups(List<TransactionModel> transactions, double dailySafeBudget) {
    final now = DateTime.now();
    final list = <BarChartGroupData>[];
    
    for (int i = 6; i >= 0; i--) {
      final index = 6 - i;
      final day = now.subtract(Duration(days: i));
      final startOfDay = DateTime(day.year, day.month, day.day);
      final endOfDay = DateTime(day.year, day.month, day.day, 23, 59, 59);
      
      final dayExpense = transactions
          .where((t) => t.isExpense && t.date.isAfter(startOfDay) && t.date.isBefore(endOfDay))
          .fold(0.0, (sum, t) => sum + t.amount);
          
      final isToday = i == 0;

      // Staggered animation using Interval
      final start = (index * 60) / 1000.0;
      final end = (start + 0.4).clamp(0.0, 1.0);
      final animationValue = CurvedAnimation(
        parent: _chartController,
        curve: Interval(start, end, curve: Curves.easeOutBack),
      ).value;
      
      // Theme colors
      final colorScheme = Theme.of(context).colorScheme;
      final Color barColor = dayExpense > dailySafeBudget
          ? colorScheme.error
          : (isToday 
              ? colorScheme.primary 
              : colorScheme.primary.withValues(alpha: 0.3)); // Muted to 30% opacity if not today

      list.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: dayExpense * animationValue,
              color: barColor,
              width: 14,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)), // RRect corners
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: dailySafeBudget == 0 ? 100000 : dailySafeBudget,
                color: colorScheme.primary.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
      );
    }
    return list;
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    final now = DateTime.now();
    final day = now.subtract(Duration(days: 6 - value.toInt()));
    final label = DateFormat('E', 'id_ID').format(day);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final remainingBudgetToday = max(state.dailySafeBudget - state.todayExpense, 0.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allowanceSpentPercent = state.dailySafeBudget == 0 ? 0.0 : state.todayExpense / state.dailySafeBudget;

    // ── Category Grouping Calculation ──────────────────────────────────────
    final today = DateTime.now();
    final categoryTotals = <String, double>{};
    for (final tx in state.transactions) {
      if (tx.isExpense) {
        final isToday = tx.date.year == today.year && tx.date.month == today.month && tx.date.day == today.day;
        if (isToday) {
          final cat = tx.category ?? 'Lainnya';
          categoryTotals[cat] = (categoryTotals[cat] ?? 0.0) + tx.amount;
        }
      }
    }
    final todayTotalExpense = state.todayExpense;

    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardProvider.notifier).loadData(),
      color: AppColors.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header Row with Hide/Show Toggle ──────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            () {
                              final hour = DateTime.now().hour;
                              if (hour >= 4 && hour < 11) return 'Selamat Pagi, Teman NataSaku 👋';
                              if (hour >= 11 && hour < 15) return 'Selamat Siang, Teman NataSaku 👋';
                              if (hour >= 15 && hour < 18) return 'Selamat Sore, Teman NataSaku 👋';
                              return 'Selamat Malam, Teman NataSaku 👋';
                            }(),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: isDark 
                                  ? AppColors.textSecondaryDark 
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'Jatah Hari Ini',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(
                                  _hideBalance ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  size: 20,
                                ),
                                onPressed: () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    _hideBalance = !_hideBalance;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ).animate().fade().slideX(begin: -0.1),
                      
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const PhosphorIcon(
                          PhosphorIconsRegular.wallet,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // ── Main Balance Card (Hero) ───────────────────────────
                  NataPressScale(
                    key: TourKeys.heroCard,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.go(AppRouter.budget);
                    },
                    scaleTo: 0.98,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.28),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.10),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Sisa Jatah Boleh Dipakai',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              // NataStatusChipOnDark — crossfade animation, rose soft for overbudget
                              NataStatusChipOnDark(
                                key: TourKeys.statusChip,
                                status: budgetStatusFromRatio(allowanceSpentPercent),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _AnimatedCountText(
                            value: remainingBudgetToday,
                            isSecret: _hideBalance,
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Daily spend progress bar
                          NataProgressBar(
                            value: allowanceSpentPercent.clamp(0.0, 1.0),
                            height: 6,
                            gradient: LinearGradient(
                              colors: allowanceSpentPercent > 1.0
                                  ? [const Color(0xFFFCA5A5), const Color(0xFFF87171)]
                                  : allowanceSpentPercent > 0.7
                                      ? [const Color(0xFFFDE68A), const Color(0xFFFCD34D)]
                                      : [Colors.white.withValues(alpha: 0.6), Colors.white.withValues(alpha: 0.9)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            backgroundColor: Colors.white.withValues(alpha: 0.18),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: _SubStat(
                                  label: 'Dipakai',
                                  value: _formatMoney(state.todayExpense),
                                  icon: PhosphorIconsRegular.arrowDownRight,
                                  isExpense: true,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 36,
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: _SubStat(
                                    label: 'Batas Aman',
                                    value: _formatMoney(state.dailySafeBudget),
                                    icon: PhosphorIconsRegular.shieldCheck,
                                    isExpense: false,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ).animate().fade(delay: 100.ms).slideY(begin: 0.1),

                  const SizedBox(height: 16),

                  // ── Amankan Sisa ke Tabungan Card & Trigger ────────────
                  if (remainingBudgetToday > 0) ...[
                    NataPressScale(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        _showSecureLeftoverSheet(context, ref, remainingBudgetToday);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.07),
                          border: Border.all(color: AppColors.accent.withValues(alpha: 0.18)),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const PhosphorIcon(PhosphorIconsRegular.piggyBank, color: AppColors.accent, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Amankan Sisa Jatah', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                                  Text('Simpan sisa jatah hari ini ke Celengan! 🚀', style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ),
                            const PhosphorIcon(PhosphorIconsRegular.caretRight, color: AppColors.accent, size: 20),
                          ],
                        ),
                      ),
                    ).animate().fade(delay: 150.ms).slideY(begin: 0.1),
                    const SizedBox(height: 12),
                  ],

                  // ── Auto Amankan Sisa Switch Card ───────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceVariantDark : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt_rounded, color: Colors.amber, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Auto Amankan Sisa', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                              const Text('Otomatis tabung sisa jatah di akhir hari', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: state.userSettings?.autoSavingEnabled ?? true,
                          activeColor: AppColors.primary,
                          onChanged: (val) async {
                            HapticFeedback.selectionClick();
                            await ref.read(dashboardProvider.notifier).updateAutoSaving(val);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(val 
                                        ? 'Auto-amankan sisa aktif! Sisa jatahmu akan otomatis ditabung tiap tengah malam. ⏰'
                                        : 'Auto-amankan sisa dinonaktifkan.'),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                );
                            }
                          },
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 180.ms).slideY(begin: 0.1),

                  const SizedBox(height: 20),

                  // ── Detektor Kesehatan Finansial Premium Card ──────────────
                  _HealthDiagnosisCard(
                    state: state,
                    showDetails: _showDiagnosisDetails,
                    onToggleDetails: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _showDiagnosisDetails = !_showDiagnosisDetails;
                      });
                    },
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.05),

                  const SizedBox(height: 24),

                  // ── Target Tabungan Tracker ────────────────────────────
                  if (state.savingGoal != null) ...[
                    Text('Target Tabungan', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))
                        .animate().fade(delay: 210.ms),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceVariantDark : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                state.savingGoal!.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Text(
                                '${((state.savingGoal!.currentAmount / state.savingGoal!.targetAmount).clamp(0.0, 1.0) * 100).toInt()}%',
                                style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: (state.savingGoal!.currentAmount / state.savingGoal!.targetAmount).clamp(0.0, 1.0),
                              minHeight: 8,
                              backgroundColor: AppColors.accent.withValues(alpha: 0.12),
                              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Terkumpul: ${_formatMoney(state.savingGoal!.currentAmount)}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                'Target: ${_formatMoney(state.savingGoal!.targetAmount)}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 220.ms).slideY(begin: 0.1),
                    const SizedBox(height: 24),
                  ],

                  // ── Progress Pemakaian Jatah (NataProgressBar) ──────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Pemakaian Hari Ini', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text(
                        '${((state.todayExpense / (state.dailySafeBudget == 0 ? 1 : state.dailySafeBudget)).clamp(0.0, 1.0) * 100).toInt()}%',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: state.todayExpense > state.dailySafeBudget
                              ? const Color(0xFFF87171)
                              : AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ).animate().fade(delay: 230.ms),
                  const SizedBox(height: 8),
                  // NataProgressBar — animated gradient fill, rose soft for overbudget
                  (state.todayExpense > state.dailySafeBudget
                    ? NataOverBudgetProgressBar(
                        value: (state.todayExpense / (state.dailySafeBudget == 0 ? 1 : state.dailySafeBudget)).clamp(0.0, 1.0),
                        height: 10,
                      )
                    : NataProgressBar(
                        value: (state.dailySafeBudget == 0
                            ? 0.0
                            : (state.todayExpense / state.dailySafeBudget).clamp(0.0, 1.0)),
                        height: 10,
                      )
                  ).animate().fade(delay: 240.ms),

                  const SizedBox(height: 24),

                  // ── 7-Day Trend Chart ────────────────────────────────
                  Text('Progress Mingguan (7 Hari)', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))
                      .animate().fade(delay: 250.ms),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceVariantDark : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: 160,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BarChart(
                          BarChartData(
                            barGroups: _buildChartGroups(state.transactions, state.dailySafeBudget),
                            borderData: FlBorderData(show: false),
                            gridData: const FlGridData(show: false),
                            alignment: BarChartAlignment.spaceAround,
                            maxY: state.dailySafeBudget * 1.5 < 100000 ? 150000 : state.dailySafeBudget * 1.5,
                            titlesData: FlTitlesData(
                              show: true,
                              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: _getBottomTitles,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ).animate().fade(delay: 260.ms).slideY(begin: 0.1),

                  const SizedBox(height: 24),

                  // ── Penyebab Pengeluaran (Category Breakdown) ─────────
                  Text('Penyebab Pengeluaran (Hari Ini)', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))
                      .animate().fade(delay: 270.ms),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceVariantDark : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (categoryTotals.isEmpty) ...[
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Column(
                                children: [
                                  Icon(Icons.emoji_emotions_outlined, color: Colors.grey.withValues(alpha: 0.5), size: 36),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Belum ada pengeluaran hari ini.\nDompetmu tersenyum! 🪙',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ] else ...[
                          ...categoryTotals.entries.map((entry) {
                            final cat = entry.key;
                            final amount = entry.value;
                            final percent = todayTotalExpense == 0 ? 0.0 : amount / todayTotalExpense;
                            final color = _getCategoryColor(cat);
                            final icon = _getCategoryIcon(cat);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(icon, color: color, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(cat, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      ),
                                      Text(
                                        '${(percent * 100).toInt()}%',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatMoney(amount),
                                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: percent,
                                      minHeight: 6,
                                      backgroundColor: color.withValues(alpha: 0.1),
                                      valueColor: AlwaysStoppedAnimation(color),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ],
                    ),
                  ).animate().fade(delay: 280.ms).slideY(begin: 0.1),

                  const SizedBox(height: 24),

                  // ── Quick Actions ─────────────────────────────────────
                  Text('Aksi Cepat', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))
                      .animate().fade(delay: 290.ms),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionButton(
                          title: 'Catat Jajan',
                          subtitle: 'Pengeluaran',
                          icon: PhosphorIconsRegular.shoppingBag,
                          color: AppColors.alert,
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            final draft = await showTransactionEntrySheet(
                              context, initialExpense: true,
                            );
                            if (draft != null && context.mounted) {
                              ref.read(dashboardProvider.notifier).addTransaction(
                                TransactionModel(
                                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                                  date: draft.date,
                                  amount: draft.amount,
                                  isExpense: true,
                                  category: draft.category,
                                  note: draft.note,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickActionButton(
                          title: 'Pemasukan',
                          subtitle: 'Pemasukan',
                          icon: PhosphorIconsRegular.wallet,
                          color: AppColors.accent,
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            final draft = await showTransactionEntrySheet(
                              context, initialExpense: false,
                            );
                            if (draft != null && context.mounted) {
                              ref.read(dashboardProvider.notifier).addTransaction(
                                TransactionModel(
                                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                                  date: draft.date,
                                  amount: draft.amount,
                                  isExpense: false,
                                  category: draft.category,
                                  note: draft.note,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickActionButton(
                          title: 'Laporan',
                          subtitle: 'Ringkasan',
                          icon: PhosphorIconsRegular.chartBar,
                          color: AppColors.primaryDark,
                          onTap: () => context.go(AppRouter.reports),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickActionButton(
                          title: 'Tagihan',
                          subtitle: 'Tetap',
                          icon: PhosphorIconsRegular.receipt,
                          color: Colors.cyan,
                          onTap: () => context.push(AppRouter.bills),
                        ),
                      ),
                    ],
                  ).animate().fade(delay: 300.ms).slideY(begin: 0.1),

                  const SizedBox(height: 28),

                  // ── Transaksi Terakhir ────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Transaksi Terakhir', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () => context.go(AppRouter.transactions),
                        child: const Text('Lihat Semua'),
                      ),
                    ],
                  ).animate().fade(delay: 310.ms),

                  ...state.transactions.reversed.take(5).map((tx) {
                    final color = tx.isExpense ? AppColors.alert : AppColors.accent;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceVariantDark : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              tx.isExpense ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                              color: color, size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tx.note ?? tx.category ?? '-',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                                Text(tx.category ?? '',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${tx.isExpense ? '-' : '+'}${_formatMoney(tx.amount)}',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: color, fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  if (state.transactions.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('Belum ada transaksi hari ini.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),

                  const SizedBox(height: 96),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isExpense;

  const _SubStat({required this.label, required this.value, required this.icon, required this.isExpense});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            PhosphorIcon(icon, color: Colors.white.withOpacity(0.9), size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? AppColors.surfaceVariantDark : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: PhosphorIcon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySetupView extends ConsumerWidget {
  const _EmptySetupView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 48),
            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 32),
            Text(
              'Ayo Mulai Petualanganmu!',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ).animate().fade(delay: 200.ms),
            const SizedBox(height: 16),
            Text(
              'Atur periode gajianmu sekarang untuk melihat batas aman belanja harian.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ).animate().fade(delay: 300.ms),
            const SizedBox(height: 40),
            FilledButton(
              onPressed: () => context.push(AppRouter.setup),
              child: const Text('Atur Keuangan Sekarang'),
            ).animate().fade(delay: 400.ms).slideY(begin: 0.2),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sedang memuat data tes...'), duration: Duration(seconds: 1)),
                );
                try {
                  await MockDataSeeder.seed();
                  await ref.read(dashboardProvider.notifier).loadData();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sukses memuat data tes UMR Jakarta!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal memuat data tes: $e')),
                    );
                  }
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.purple,
                side: const BorderSide(color: Colors.purple),
              ),
              icon: const Icon(Icons.science_outlined, size: 18),
              label: const Text('🧪  Muat Data Tes (UMR Jakarta)'),
            ).animate().fade(delay: 500.ms).slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }
}

void _showSecureLeftoverSheet(BuildContext context, WidgetRef ref, double amount) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 48),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const PhosphorIcon(PhosphorIconsRegular.piggyBank, color: AppColors.accent, size: 40),
            ).animate().scale(curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            Text('Simpan Sisa Jatahmu?', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Kamu punya sisa ${CurrencyService.formatRupiah(amount).replaceAll('Rp', '')} hari ini. Mau diapakan uang ini?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ref.read(dashboardProvider.notifier).transferToSavings(amount);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: const Text('Yeay! Sisa jatah berhasil ditabung. 🥳'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  );
              },
              icon: const PhosphorIcon(PhosphorIconsRegular.download),
              label: const Text('Masukkan ke Celengan!'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Biarkan untuk Besok'),
            ),
          ],
        ),
      );
    },
  );
}

class _HealthDiagnosisCard extends StatelessWidget {
  final DashboardState state;
  final bool showDetails;
  final VoidCallback onToggleDetails;

  const _HealthDiagnosisCard({
    required this.state,
    required this.showDetails,
    required this.onToggleDetails,
  });

  @override
  Widget build(BuildContext context) {
    final score = state.healthScore;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme values based on score
    Color statusColor;
    String statusTitle;
    String statusSubtitle;
    IconData statusIcon;

    if (score >= 80) {
      statusColor = AppColors.accent;
      statusTitle = 'SEHAT KEUANGAN';
      statusSubtitle = 'Luar biasa! Arus kas Anda sangat aman dan terkelola dengan baik. 🚀';
      statusIcon = Icons.check_circle_rounded;
    } else if (score >= 55) {
      statusColor = Colors.orange;
      statusTitle = 'WASPADA FINANSIAL';
      statusSubtitle = 'Cukup aman, namun ada pengeluaran atau rasio yang perlu sedikit diawasi. ⚠️';
      statusIcon = Icons.warning_rounded;
    } else {
      statusColor = AppColors.alert;
      statusTitle = 'KRITIS FINANSIAL';
      statusSubtitle = 'Waduh! Dompet Anda mengalami defisit atau pemborosan tinggi. Batasi belanja! 🚨';
      statusIcon = Icons.error_rounded;
    }

    // Dynamic diagnosis recommendations
    final recommendations = <Map<String, dynamic>>[];
    
    if (state.remainingFund < 0) {
      recommendations.add({
        'color': AppColors.alert,
        'icon': Icons.trending_down_rounded,
        'text': 'Dompet Anda sedang mengalami defisit sisa dana! Tunda belanja barang non-primer.',
      });
    }
    
    if (state.todayExpense > state.dailySafeBudget) {
      recommendations.add({
        'color': AppColors.alert,
        'icon': Icons.shopping_cart_checkout_rounded,
        'text': 'Pengeluaran hari ini melebihi batas aman harian Anda. Kurangi belanja untuk besok.',
      });
    }

    final totalExp = state.totalExpense;
    final flexFund = state.period?.flexibleFund ?? 0.0;
    if (flexFund > 0 && totalExp / flexFund > 0.8) {
      recommendations.add({
        'color': Colors.orange,
        'icon': Icons.pie_chart_rounded,
        'text': 'Pengeluaran periode ini sudah mencapai ${((totalExp / flexFund) * 100).toInt()}% dari dana fleksibel.',
      });
    }

    if (state.savingGoal != null) {
      final savingProgress = state.savingGoal!.currentAmount / state.savingGoal!.targetAmount;
      if (savingProgress < 0.5) {
        recommendations.add({
          'color': Colors.blue,
          'icon': Icons.savings_rounded,
          'text': 'Target celengan "${state.savingGoal!.name}" baru mencapai ${(savingProgress * 100).toInt()}%. Yuk rajin menabung!',
        });
      }
    }

    if (state.userSettings?.autoSavingEnabled == false) {
      recommendations.add({
        'color': Colors.amber,
        'icon': Icons.bolt_rounded,
        'text': 'Aktifkan fitur "Auto Amankan Sisa" agar kelebihan jatah harian otomatis ditabung tiap tengah malam.',
      });
    }

    if (recommendations.isEmpty) {
      recommendations.add({
        'color': AppColors.accent,
        'icon': Icons.thumb_up_rounded,
        'text': 'Semua indikator keuangan Anda berjalan sangat sehat! Pertahankan kinerja luar biasa ini.',
      });
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            color: statusColor.withValues(alpha: 0.08),
            child: Row(
              children: [
                // Circular Score Display
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 5,
                        backgroundColor: statusColor.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation(statusColor),
                      ),
                    ),
                    Text(
                      '$score',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Diagnosis text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(statusIcon, color: statusColor, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            statusTitle,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Detektor Kesehatan NataSaku',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Brief insight text
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Toggle Button for Details
                InkWell(
                  onTap: onToggleDetails,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.assignment_turned_in_rounded, color: statusColor, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              showDetails ? 'Sembunyikan Rekomendasi' : 'Lihat 3+ Rekomendasi Medis Finansial',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          showDetails ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                          color: statusColor,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Expanded list of recommendations
                if (showDetails) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  ...recommendations.map((rec) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: rec['color'].withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              rec['icon'] as IconData,
                              color: rec['color'] as Color,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              rec['text'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.35,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedCountText extends StatefulWidget {
  const _AnimatedCountText({
    required this.value,
    required this.isSecret,
    required this.style,
  });

  final double value;
  final bool isSecret;
  final TextStyle? style;

  @override
  State<_AnimatedCountText> createState() => _AnimatedCountTextState();
}

class _AnimatedCountTextState extends State<_AnimatedCountText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _oldValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _AnimatedCountText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _oldValue = oldWidget.value;
      _animation = Tween<double>(begin: _oldValue, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSecret) {
      return Text('••••••', style: widget.style);
    }
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          CurrencyService.formatRupiah(_animation.value),
          style: widget.style,
        );
      },
    );
  }
}

