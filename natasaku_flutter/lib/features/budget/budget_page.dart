import 'dart:math';

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
import '../../data/models/budget_mode.dart';
import '../../data/models/budget_status.dart';
import '../../data/models/category_budget.dart';
import '../../shared/widgets/main_shell.dart';
import '../../shared/widgets/transaction_entry_sheet.dart'; // contains nataCategories
import '../budgeting/budgeting_engine.dart';
import '../../core/utils/nominal_input_validator.dart';
import '../../core/providers/repository_providers.dart';
import '../../data/models/budget_period.dart';
import '../dashboard/providers/dashboard_provider.dart';
import 'providers/category_budget_provider.dart';

class BudgetPage extends ConsumerStatefulWidget {
  const BudgetPage({super.key});

  @override
  ConsumerState<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends ConsumerState<BudgetPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).loadData();
      ref.read(categoryBudgetProvider.notifier).loadBudgets();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onNavigate(int index) {
    switch (index) {
      case 0: context.go(AppRouter.dashboard); break;
      case 1: context.go(AppRouter.transactions); break;
      case 2: break; // current
      case 3: context.go(AppRouter.savings); break;
      case 4: context.go(AppRouter.reports); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);

    return MainShell(
      index: 2,
      onNavigate: _onNavigate,
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : state.period == null
                ? const _EmptyBudgetView()
                : NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Struktur Keuangan',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Budget Planner',
                                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ).animate().fade().slideX(begin: -0.1),
                                ),
                                IconButton(
                                  onPressed: () => context.push(AppRouter.setup),
                                  icon: const PhosphorIcon(PhosphorIconsRegular.pencilSimple),
                                  style: IconButton.styleFrom(
                                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                    foregroundColor: AppColors.primary,
                                    padding: const EdgeInsets.all(12),
                                  ),
                                ).animate().fade(delay: 200.ms),
                              ],
                            ),
                          ),
                        ),
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _SliverTabBarDelegate(
                            TabBar(
                              controller: _tabController,
                              indicatorSize: TabBarIndicatorSize.tab,
                              dividerColor: Colors.transparent,
                              indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: AppColors.primary,
                              ),
                              labelColor: Colors.white,
                              unselectedLabelColor: Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              tabs: const [
                                Tab(text: 'Ringkasan Harian'),
                                Tab(text: 'Limit Kategori'),
                              ],
                            ),
                          ),
                        ),
                      ];
                    },
                    body: TabBarView(
                      controller: _tabController,
                      children: [
                        _BudgetContent(state: state),
                        const _CategoryBudgetView(),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => 64.0;
  @override
  double get maxExtent => 64.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: tabBar,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SliverTabBarDelegate oldDelegate) {
    return false;
  }
}

class _BudgetContent extends ConsumerWidget {
  final DashboardState state;
  const _BudgetContent({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = state.period!;
    final remainingFund = state.remainingFund;
    final remainingDays = state.remainingDays;
    
    final baseDaily = BudgetingEngine.calculateDailySafeBudget(
      remainingFund: max<double>(remainingFund, 0),
      remainingDays: remainingDays,
    );
    
    final safeDaily = BudgetingEngine.applyBudgetMode(
      baseDailyBudget: baseDaily,
      mode: period.mode,
    );
    
    final periodStatus = BudgetingEngine.getPeriodFundStatus(
      remainingFund: remainingFund,
      remainingDays: remainingDays,
    );
    
    final tomorrowBudget = BudgetingEngine.calculateTomorrowSafeBudget(
      remainingFundAfterToday: remainingFund - state.todayExpense,
      remainingDaysAfterToday: max(remainingDays - 1, 0),
    );

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
      children: [
        // Status Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 12),
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
                    'Jatah Aman Harian',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const PhosphorIcon(PhosphorIconsFill.checkCircle, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          _periodStatusLabel(periodStatus),
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                CurrencyService.formatRupiah(safeDaily),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const PhosphorIcon(PhosphorIconsRegular.calendar, color: Colors.white70, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_fmtDate(period.startDate)} - ${_fmtDate(period.endDate)}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                          ),
                          Text(
                            'Sisa ${max(remainingDays, 0)} hari',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fade(delay: 100.ms).slideY(begin: 0.1),

        const SizedBox(height: 20),
        
        // Future Prediction Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? AppColors.surfaceVariantDark 
                : AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? AppColors.borderDark 
                  : AppColors.accent.withValues(alpha: 0.2)
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.15 : 0.03),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const PhosphorIcon(PhosphorIconsRegular.lightbulb, color: AppColors.accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Prediksi Jatah Besok', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyService.formatRupiah(tomorrowBudget),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.accent, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Jika hari ini kamu berhenti jajan, jatah besok akan naik!',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fade(delay: 200.ms).slideX(begin: 0.1),

        const SizedBox(height: 20),

        _BudgetBreakdownSection(period: period),

        const SizedBox(height: 20),
        
        // Grid Metrics
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.15,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _MetricCard(
              label: 'Dana Awal',
              value: period.flexibleFund,
              icon: PhosphorIconsRegular.wallet,
            ),
            _MetricCard(
              label: 'Sisa Dana',
              value: remainingFund,
              icon: PhosphorIconsRegular.piggyBank,
              color: remainingFund >= 0 ? AppColors.accent : AppColors.alert,
            ),
            _MetricCard(
              label: 'Terpakai',
              value: state.totalExpense,
              icon: PhosphorIconsRegular.trendDown,
              color: AppColors.alert,
            ),
            _MetricCard(
              label: 'Pemasukan',
              value: state.totalIncome,
              icon: PhosphorIconsRegular.trendUp,
              color: AppColors.accent,
            ),
          ],
        ).animate().fade(delay: 300.ms).slideY(begin: 0.1),

        const SizedBox(height: 20),
        
        // Mode Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceVariantDark : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? AppColors.borderDark : AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.15 : 0.03),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const PhosphorIcon(PhosphorIconsRegular.sliders, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mode: ${_modeLabel(period.mode)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _modeDescription(period.mode),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fade(delay: 400.ms).slideY(begin: 0.1),
      ],
    );
  }

  String _modeLabel(BudgetMode mode) {
    switch (mode) {
      case BudgetMode.normal: return 'Normal';
      case BudgetMode.hemat: return 'Hemat';
      case BudgetMode.krisis: return 'Krisis';
    }
  }

  String _modeDescription(BudgetMode mode) {
    switch (mode) {
      case BudgetMode.normal: return 'Jatah harian santai mengikuti sisa uang dibagi sisa hari.';
      case BudgetMode.hemat: return 'Disimpan sedikit untuk buffer cadangan.';
      case BudgetMode.krisis: return 'Sangat ketat! Jatah harian dipotong drastis demi bertahan.';
    }
  }

  String _periodStatusLabel(PeriodFundStatus status) {
    switch (status) {
      case PeriodFundStatus.aman: return 'Aman';
      case PeriodFundStatus.waspada: return 'Waspada';
      case PeriodFundStatus.kritis: return 'Kritis';
      case PeriodFundStatus.danaHabis: return 'Dana Habis';
      case PeriodFundStatus.periodeSelesai: return 'Selesai';
    }
  }

  String _fmtDate(DateTime date) {
    return DateFormat('dd MMM', 'id_ID').format(date);
  }
}

class _CategoryBudgetView extends ConsumerStatefulWidget {
  const _CategoryBudgetView();

  @override
  ConsumerState<_CategoryBudgetView> createState() => _CategoryBudgetViewState();
}

class _CategoryBudgetViewState extends ConsumerState<_CategoryBudgetView> {
  void _editCategoryBudget([CategoryBudgetDetail? detail]) async {
    final isNew = detail == null;
    
    // Available categories not yet budget-limited (or include current for editing)
    final existingCategories = ref.read(categoryBudgetProvider).budgets
        .map((b) => b.category.toLowerCase())
        .toList();
    
    final availableCategories = nataCategories
        .where((c) => isNew ? !existingCategories.contains(c.toLowerCase()) : true)
        .toList();

    if (isNew && availableCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua kategori standar telah memiliki limit budget!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    String category = detail?.budget.category ?? availableCategories.first;
    final limitController = TextEditingController(
      text: isNew ? '' : detail.budget.limitAmount.toInt().toString(),
    );
    String emoji = detail?.budget.emoji ?? '📦';

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String? modalErrorMessage;
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white24 : Colors.black12,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              isNew ? 'Tambah Limit Kategori' : 'Edit Limit Kategori',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context, false),
                            icon: const Icon(Icons.close_rounded),
                            style: IconButton.styleFrom(
                              backgroundColor: isDark ? Colors.white10 : Colors.black54.withValues(alpha: 0.05),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Error Message Banner
                      if (modalErrorMessage != null) ...[
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
                                  modalErrorMessage!,
                                  style: const TextStyle(color: AppColors.alert, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Category dropdown/selector
                      if (isNew) ...[
                        Text(
                          'Kategori Pengeluaran',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: category,
                              isExpanded: true,
                              dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              items: availableCategories.map((cat) {
                                return DropdownMenuItem<String>(
                                  value: cat,
                                  child: Text(cat),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(() {
                                    category = val;
                                    // Set dynamic emojis for categories
                                    switch (val) {
                                      case 'Makan': emoji = '🍔'; break;
                                      case 'Minum': emoji = '☕'; break;
                                      case 'Transport': emoji = '🚗'; break;
                                      case 'Belanja': emoji = '🛒'; break;
                                      case 'Tagihan': emoji = '💵'; break;
                                      case 'Keluarga': emoji = '👨‍👩‍👧‍👦'; break;
                                      case 'Hiburan': emoji = '🎮'; break;
                                      case 'Kesehatan': emoji = '💊'; break;
                                      default: emoji = '📦';
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ] else ...[
                        Row(
                          children: [
                            Text(
                              'Kategori: ',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight),
                            ),
                            Text(
                              category,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Emoji Selection
                      Text(
                        'Pilih Emoji',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['🍔', '☕', '🚗', '🛒', '🎮', '💊', '💵', '👨‍👩‍👧‍👦', '🏠', '📦'].map((e) {
                          final isSelected = emoji == e;
                          return InkWell(
                            onTap: () => setModalState(() => emoji = e),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: 150.ms,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? AppColors.primary.withValues(alpha: 0.15) 
                                    : (isDark ? AppColors.surfaceVariantDark : Colors.white),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.borderLight),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Text(e, style: const TextStyle(fontSize: 20)),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Limit amount input
                      Text(
                        'Limit Budget Periode Ini',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: limitController,
                        keyboardType: TextInputType.number,
                        autofocus: isNew,
                        decoration: InputDecoration(
                          prefixText: 'Rp ',
                          hintText: '500000',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          filled: true,
                          fillColor: isDark ? AppColors.surfaceVariantDark : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Actions
                      Row(
                        children: [
                          if (!isNew)
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.alert),
                                  foregroundColor: AppColors.alert,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Hapus Limit'),
                                      content: Text('Apakah kamu yakin ingin menghapus budget limit untuk kategori $category?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          style: TextButton.styleFrom(foregroundColor: AppColors.alert),
                                          child: const Text('Hapus'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await ref.read(categoryBudgetProvider.notifier).deleteBudget(detail.budget.id);
                                    if (context.mounted) Navigator.pop(context, true);
                                  }
                                },
                                child: const Text('Hapus Limit'),
                              ),
                            ),
                          if (!isNew) const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () async {
                                setModalState(() => modalErrorMessage = null);
                                final amountStr = limitController.text.trim();
                                if (amountStr.isEmpty) {
                                  setModalState(() => modalErrorMessage = 'Nominal limit tidak boleh kosong!');
                                  HapticFeedback.heavyImpact();
                                  return;
                                }

                                final amount = double.tryParse(amountStr.replaceAll('.', '').replaceAll(',', '.').trim()) ?? 0.0;
                                if (amount <= 0) {
                                  setModalState(() => modalErrorMessage = 'Nominal limit harus lebih dari Rp 0!');
                                  HapticFeedback.heavyImpact();
                                  return;
                                }
                                if (amount > 999999999999) {
                                  setModalState(() => modalErrorMessage = 'Nominal limit terlalu besar!');
                                  HapticFeedback.heavyImpact();
                                  return;
                                }

                                final budget = CategoryBudget(
                                  id: isNew ? DateTime.now().microsecondsSinceEpoch.toString() : detail.budget.id,
                                  category: category,
                                  limitAmount: amount,
                                  emoji: emoji,
                                );

                                await ref.read(categoryBudgetProvider.notifier).saveBudget(budget);
                                if (context.mounted) Navigator.pop(context, true);
                              },
                              child: const Text('Simpan Limit'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    limitController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final details = ref.watch(categoryBudgetDetailsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (details.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const PhosphorIcon(PhosphorIconsRegular.tag, color: AppColors.primary, size: 64),
            ).animate().scale(curve: Curves.easeOutBack, duration: 600.ms),
            const SizedBox(height: 24),
            Text(
              'Belum ada limit kategori',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Atur batas maksimum pengeluaran untuk kategori tertentu seperti Makan, Belanja, atau Transportasi agar keuangan tetap terkontrol.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              onPressed: () => _editCategoryBudget(),
              icon: const PhosphorIcon(PhosphorIconsRegular.plusCircle, size: 20),
              label: const Text('Atur Limit Kategori'),
            ),
          ],
        ),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
      children: [
        // Premium Info banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceVariantDark : AppColors.primarySoft.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              const PhosphorIcon(PhosphorIconsRegular.info, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Kami memantau transaksi pengeluaranmu dalam periode budget aktif dan memberitahu jika sudah melebihi 80% limit.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.primaryContainer,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fade().slideY(begin: 0.1),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daftar Limit',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () => _editCategoryBudget(),
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Tambah'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ...details.map((detail) {
          final isExceeded = detail.isExceeded;
          final isWarning = detail.isWarning;
          final progressColor = isExceeded
              ? AppColors.alert
              : isWarning
                  ? Colors.amber
                  : AppColors.primary;

          return Card(
            elevation: 3,
            shadowColor: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
            margin: const EdgeInsets.only(bottom: 16),
            color: isDark ? AppColors.surfaceDark : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: isExceeded
                    ? AppColors.alert.withValues(alpha: 0.4)
                    : isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                width: isExceeded ? 1.5 : 1,
              ),
            ),
            child: InkWell(
              onTap: () => _editCategoryBudget(detail),
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Category Icon/Emoji Box
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                            shape: BoxShape.circle,
                          ),
                          child: Text(detail.budget.emoji, style: const TextStyle(fontSize: 22)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                detail.budget.category,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${CurrencyService.formatRupiah(detail.spent)} dari ${CurrencyService.formatRupiah(detail.budget.limitAmount)}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Status Badge
                        if (isExceeded)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.alert.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'OVER',
                              style: TextStyle(color: AppColors.alert, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          )
                        else if (isWarning)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '80%+',
                              style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: detail.progress,
                        minHeight: 10,
                        backgroundColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                        color: progressColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tersisa: ${CurrencyService.formatRupiah(detail.remaining)}',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isExceeded 
                                ? AppColors.alert 
                                : isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        Text(
                          '${(detail.progress * 100).toInt()}%',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color? color;

  const _MetricCard({required this.label, required this.value, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: activeColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: PhosphorIcon(icon, color: activeColor, size: 20),
          ),
          const Spacer(),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyService.formatRupiah(value).replaceAll('Rp', ''),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: activeColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBudgetView extends StatelessWidget {
  const _EmptyBudgetView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const PhosphorIcon(PhosphorIconsRegular.wallet, color: AppColors.primary, size: 64),
            ).animate().scale(curve: Curves.easeOutBack, duration: 600.ms),
            const SizedBox(height: 24),
            Text('Budget belum diatur', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Atur periode gajian dan dana fleksibelmu agar kami bisa menghitung jatah harian yang aman.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.push(AppRouter.setup),
              icon: const PhosphorIcon(PhosphorIconsRegular.rocketLaunch),
              label: const Text('Mulai Atur Keuangan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetBreakdownSection extends ConsumerStatefulWidget {
  final BudgetPeriod period;
  const _BudgetBreakdownSection({required this.period});

  @override
  ConsumerState<_BudgetBreakdownSection> createState() => _BudgetBreakdownSectionState();
}

class _BudgetBreakdownSectionState extends ConsumerState<_BudgetBreakdownSection> {
  void _editComponent(String type, double currentValue) async {
    final controller = TextEditingController(text: currentValue.toInt().toString());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    String title = '';
    if (type == 'income') title = 'Pemasukan Utama';
    if (type == 'fixed') title = 'Pengeluaran Tetap';
    if (type == 'savings') title = 'Alokasi Tabungan';

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String? errorMessage;
        String? warningMessage;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black12,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Edit $title',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context, false),
                          icon: const Icon(Icons.close_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: isDark ? Colors.white10 : Colors.black54.withValues(alpha: 0.05),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    if (errorMessage != null) ...[
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
                                errorMessage!,
                                style: const TextStyle(color: AppColors.alert, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (warningMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                warningMessage!,
                                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    Text(
                      'Nominal Baru',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      decoration: InputDecoration(
                        prefixText: 'Rp ',
                        hintText: '500000',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        filled: true,
                        fillColor: isDark ? AppColors.surfaceVariantDark : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () async {
                          setModalState(() {
                            errorMessage = null;
                          });

                          final amountStr = controller.text.trim();
                          if (amountStr.isEmpty) {
                            setModalState(() => errorMessage = 'Nominal tidak boleh kosong!');
                            HapticFeedback.heavyImpact();
                            return;
                          }

                          final amount = double.tryParse(amountStr.replaceAll('.', '').replaceAll(',', '.').trim()) ?? 0.0;
                          
                          double targetIncome = widget.period.flexibleFund;
                          double targetFixed = widget.period.fixedExpenses;
                          double targetSavings = widget.period.monthlySavingAllocation;

                          if (type == 'income') targetIncome = amount;
                          if (type == 'fixed') targetFixed = amount;
                          if (type == 'savings') targetSavings = amount;

                          final validation = NominalInputValidator.validateSetup(
                            totalIncome: targetIncome.round(),
                            totalFixedExpense: targetFixed.round(),
                            savingAllocation: targetSavings.round(),
                            startDate: widget.period.startDate,
                            endDate: widget.period.endDate,
                          );

                          if (validation['status'] == 'error') {
                            setModalState(() => errorMessage = validation['message'] as String);
                            HapticFeedback.heavyImpact();
                            return;
                          }

                          if (validation['status'] == 'warning' && warningMessage == null) {
                            setModalState(() => warningMessage = '${validation['message']}\n\nKetuk Simpan lagi untuk menyetujui.');
                            HapticFeedback.warningNotification();
                            return;
                          }

                          final repo = ref.read(budgetRepositoryProvider);
                          await repo.savePeriod(
                            BudgetPeriod(
                              id: widget.period.id,
                              startDate: widget.period.startDate,
                              endDate: widget.period.endDate,
                              flexibleFund: targetIncome,
                              fixedExpenses: targetFixed,
                              monthlySavingAllocation: targetSavings,
                              mode: widget.period.mode,
                            ),
                          );

                          await ref.read(dashboardProvider.notifier).loadData();
                          if (context.mounted) Navigator.pop(context, true);
                        },
                        child: const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final period = widget.period;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final isWarning = period.fixedExpenses > period.flexibleFund * 0.8;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Rencana Pembagian Keuangan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (isWarning)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.alert.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.alert.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppColors.alert, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Tetap > 80%!',
                      style: TextStyle(color: AppColors.alert, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        
        Card(
          elevation: 3,
          shadowColor: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
          color: isDark ? AppColors.surfaceDark : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: isWarning 
                  ? AppColors.alert.withValues(alpha: 0.4) 
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
              width: isWarning ? 1.5 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildBreakdownItem(
                  icon: PhosphorIconsRegular.wallet,
                  title: 'Pemasukan Utama',
                  value: period.flexibleFund,
                  color: AppColors.accent,
                  onEdit: () => _editComponent('income', period.flexibleFund),
                ),
                const Divider(height: 24, thickness: 0.5),
                _buildBreakdownItem(
                  icon: PhosphorIconsRegular.receipt,
                  title: 'Tagihan Tetap',
                  value: period.fixedExpenses,
                  color: AppColors.alert,
                  onEdit: () => _editComponent('fixed', period.fixedExpenses),
                ),
                const Divider(height: 24, thickness: 0.5),
                _buildBreakdownItem(
                  icon: PhosphorIconsRegular.piggyBank,
                  title: 'Alokasi Tabungan',
                  value: period.monthlySavingAllocation,
                  color: Colors.amber,
                  onEdit: () => _editComponent('savings', period.monthlySavingAllocation),
                ),
                const Divider(height: 24, thickness: 0.5),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const PhosphorIcon(PhosphorIconsRegular.scales, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dana Fleksibel Bersih',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Dana aman untuk jatah harian',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      CurrencyService.formatRupiah(period.flexibleFund - period.fixedExpenses - period.monthlySavingAllocation),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownItem({
    required IconData icon,
    required String title,
    required double value,
    required Color color,
    required VoidCallback onEdit,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: PhosphorIcon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                CurrencyService.formatRupiah(value),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onEdit,
          icon: const PhosphorIcon(PhosphorIconsRegular.pencilSimple, size: 16),
          style: IconButton.styleFrom(
            backgroundColor: isDark ? Colors.white10 : Colors.black54.withValues(alpha: 0.03),
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.all(8),
          ),
        ),
      ],
    );
  }
}
