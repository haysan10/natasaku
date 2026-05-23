import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/animations/nata_animations.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/services/currency_service.dart';
import '../../data/models/saving_goal.dart';
import '../../data/models/user_settings.dart';
import '../../shared/widgets/main_shell.dart';
import '../../shared/widgets/nata_shimmer.dart';
import '../../shared/widgets/nata_progress_bar.dart';
import '../../shared/widgets/nata_press_scale.dart';
import '../dashboard/providers/dashboard_provider.dart';

class SavingsPage extends ConsumerStatefulWidget {
  const SavingsPage({super.key});

  @override
  ConsumerState<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends ConsumerState<SavingsPage> {
  bool _loading = true;
  double _balance = 0;
  List<SavingGoal> _goals = [];
  List<Map<String, dynamic>> _history = [];
  UserSettings _settings = const UserSettings();
  String? _expandedGoalId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(budgetRepositoryProvider);
    final settings = await repo.loadUserSettings();
    final balance = await repo.loadSavingBalance();
    
    var goals = await repo.loadSavingGoals();
    // Backwards-compatibility migration for single goal
    if (goals.isEmpty) {
      final oldGoal = await repo.loadSavingGoal();
      if (oldGoal != null) {
        goals = [oldGoal];
        // Automatically migrate it to the new multi-goals list
        await repo.saveAllSavingGoals(goals);
      }
    }

    final history = await repo.loadSavingAllocations();
    
    history.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));

    if (!mounted) return;
    setState(() {
      _settings = settings;
      _balance = balance;
      _goals = goals;
      _history = history;
      _loading = false;
    });
    
    // Also sync Riverpod state so that dashboard is up-to-date
    ref.read(dashboardProvider.notifier).loadData();
  }

  Future<void> _toggleAutoSaving(bool enabled) async {
    HapticFeedback.lightImpact();
    final repo = ref.read(budgetRepositoryProvider);
    final updated = UserSettings(
      dailyReminderEnabled: _settings.dailyReminderEnabled,
      dailyReminderTime: _settings.dailyReminderTime,
      quickToolsNotificationEnabled: _settings.quickToolsNotificationEnabled,
      autoSavingEnabled: enabled,
      budgetMode: _settings.budgetMode,
      usageStyle: _settings.usageStyle,
    );
    await repo.saveUserSettings(updated);
    await ref.read(dashboardProvider.notifier).updateAutoSaving(enabled);
    if (!mounted) return;
    setState(() => _settings = updated);
  }

  void _showAutoSavingExplanation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Bagaimana Auto-Celengan Bekerja? ⚡',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Dengan mengaktifkan Auto-celengan:',
                style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87),
              ),
              const SizedBox(height: 12),
              _buildExplanationItem(
                Icons.trending_up_rounded,
                'Pertumbuhan Otomatis',
                'Sisa jatah harian kamu yang tidak terpakai atau nominal terjadwal akan otomatis dipindahkan ke Celengan Impian saat penutupan hari.',
                isDark,
              ),
              const SizedBox(height: 12),
              _buildExplanationItem(
                Icons.shield_rounded,
                'Keuangan Tetap Aman',
                'Alokasi dilakukan tanpa mengganggu budget bulanan pokok kamu, sehingga kamu bisa menabung dengan tenang.',
                isDark,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _toggleAutoSaving(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Aktifkan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExplanationItem(IconData icon, String title, String desc, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 2),
              Text(desc, style: TextStyle(color: isDark ? Colors.grey : Colors.black54, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _upsertGoal([SavingGoal? existingGoal]) async {
    final nameController = TextEditingController(text: existingGoal?.name ?? '');
    final targetController = TextEditingController(
      text: existingGoal == null ? '' : existingGoal.targetAmount.toStringAsFixed(0),
    );
    final currentController = TextEditingController(
      text: existingGoal == null ? '0' : existingGoal.currentAmount.toStringAsFixed(0),
    );
    final autoSaveAmountController = TextEditingController(
      text: existingGoal?.autoSaveAmount == null ? '' : existingGoal!.autoSaveAmount!.toStringAsFixed(0),
    );
    DateTime? targetDate = existingGoal?.targetDate;
    bool autoSaveEnabled = existingGoal?.autoSaveAmount != null && existingGoal!.autoSaveAmount! > 0;
    String autoSaveFrequency = existingGoal?.autoSaveFrequency ?? 'daily';
    String? modalErrorMessage;

    double parseAmount(String raw) {
      final normalized = raw.replaceAll('.', '').replaceAll(',', '.').trim();
      final value = double.tryParse(normalized) ?? 0;
      return value.isFinite ? value : 0;
    }

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 32),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
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
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            existingGoal == null ? 'Buat Celengan Impian 🚀' : 'Sunting Celengan ✏️',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context, false),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

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

                    TextField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Nama Impian',
                        hintText: 'Contoh: Laptop Baru, Liburan Bali, Dana Darurat',
                        prefixIcon: const Icon(Icons.star_outline_rounded, color: AppColors.primary),
                        filled: true,
                        fillColor: isDark ? AppColors.surfaceVariantDark.withValues(alpha: 0.3) : AppColors.surfaceVariantLight.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: targetController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Nominal Target (Rp)',
                        prefixIcon: const Icon(Icons.track_changes_rounded, color: AppColors.primary),
                        filled: true,
                        fillColor: isDark ? AppColors.surfaceVariantDark.withValues(alpha: 0.3) : AppColors.surfaceVariantLight.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: currentController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Saldo Terkumpul Awal (Rp)',
                        prefixIcon: const Icon(Icons.wallet, color: AppColors.primary),
                        filled: true,
                        fillColor: isDark ? AppColors.surfaceVariantDark.withValues(alpha: 0.3) : AppColors.surfaceVariantLight.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: targetDate ?? DateTime.now().add(const Duration(days: 30)),
                            firstDate: DateTime.now().subtract(const Duration(days: 1)),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: Theme.of(context).colorScheme.copyWith(
                                    primary: AppColors.primary,
                                    surface: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setModalState(() => targetDate = picked);
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
                        label: Text(
                          targetDate == null
                              ? 'Pilih Tanggal Target (Opsional)'
                              : 'Target Tanggal: ${DateFormat('dd MMM yyyy').format(targetDate!)}',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Automated Savings Section
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceVariantDark : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.sync_rounded, color: AppColors.primary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Nabung Otomatis (Auto-save)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Tabung rutin secara terjadwal otomatis',
                                      style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: autoSaveEnabled,
                                activeColor: AppColors.primary,
                                onChanged: (value) => setModalState(() => autoSaveEnabled = value),
                              ),
                            ],
                          ),
                          if (autoSaveEnabled) ...[
                            const SizedBox(height: 16),
                            TextField(
                              controller: autoSaveAmountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Nominal Tabungan Rutin (Rp)',
                                prefixIcon: const Icon(Icons.add_card_rounded, color: AppColors.primary),
                                filled: true,
                                fillColor: isDark ? AppColors.surfaceDark : Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text('Frekuensi Menabung', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: ChoiceChip(
                                    label: const Text('Harian'),
                                    selected: autoSaveFrequency == 'daily',
                                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                                    onSelected: (selected) {
                                      if (selected) setModalState(() => autoSaveFrequency = 'daily');
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ChoiceChip(
                                    label: const Text('Mingguan'),
                                    selected: autoSaveFrequency == 'weekly',
                                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                                    onSelected: (selected) {
                                      if (selected) setModalState(() => autoSaveFrequency = 'weekly');
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ChoiceChip(
                                    label: const Text('Bulanan'),
                                    selected: autoSaveFrequency == 'monthly',
                                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                                    onSelected: (selected) {
                                      if (selected) setModalState(() => autoSaveFrequency = 'monthly');
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    FilledButton(
                      onPressed: () async {
                        setModalState(() => modalErrorMessage = null);
                        final name = nameController.text.trim();
                        final target = parseAmount(targetController.text);
                        final current = parseAmount(currentController.text);
                        final autoSaveAmount = autoSaveEnabled ? parseAmount(autoSaveAmountController.text) : null;

                        // Validation checks
                        if (name.isEmpty) {
                          setModalState(() => modalErrorMessage = 'Nama impian tidak boleh kosong!');
                          HapticFeedback.heavyImpact();
                          return;
                        }
                        if (target <= 0) {
                          setModalState(() => modalErrorMessage = 'Nominal target harus lebih dari Rp 0!');
                          HapticFeedback.heavyImpact();
                          return;
                        }
                        if (target > 9999999999999) {
                          setModalState(() => modalErrorMessage = 'Nominal target terlalu besar!');
                          HapticFeedback.heavyImpact();
                          return;
                        }
                        if (current < 0) {
                          setModalState(() => modalErrorMessage = 'Saldo awal terkumpul tidak boleh kurang dari Rp 0!');
                          HapticFeedback.heavyImpact();
                          return;
                        }
                        if (autoSaveEnabled) {
                          if (autoSaveAmount == null || autoSaveAmount <= 0) {
                            setModalState(() => modalErrorMessage = 'Nominal tabungan rutin harus lebih dari Rp 0!');
                            HapticFeedback.heavyImpact();
                            return;
                          }
                          if (autoSaveAmount > target) {
                            setModalState(() => modalErrorMessage = 'Nominal tabungan rutin tidak boleh melebihi target!');
                            HapticFeedback.heavyImpact();
                            return;
                          }
                        }

                        if (targetDate != null) {
                          final today = DateTime.now();
                          final todayZero = DateTime(today.year, today.month, today.day);
                          if (targetDate!.isBefore(todayZero)) {
                            setModalState(() => modalErrorMessage = 'Tanggal target tidak boleh di masa lalu!');
                            HapticFeedback.heavyImpact();
                            return;
                          }
                        }
                        
                        final repo = ref.read(budgetRepositoryProvider);
                        await repo.upsertSavingGoal(
                          SavingGoal(
                            id: existingGoal?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
                            name: name,
                            targetAmount: target,
                            currentAmount: current,
                            targetDate: targetDate,
                            autoSaveAmount: autoSaveAmount,
                            autoSaveFrequency: autoSaveEnabled ? autoSaveFrequency : null,
                            lastAutoSaveDate: existingGoal?.lastAutoSaveDate,
                          ),
                        );
                        if (context.mounted) {
                          Navigator.pop(context, true);
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Simpan Celengan', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    targetController.dispose();
    currentController.dispose();
    autoSaveAmountController.dispose();
    if (saved == true) await _load();
  }

  Future<void> _deleteGoal(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Celengan?'),
        content: const Text('Apakah Anda yakin ingin menghapus celengan ini? Saldo celengan akan hilang dari target.'),
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

    if (confirmed == true) {
      final repo = ref.read(budgetRepositoryProvider);
      await repo.deleteSavingGoalById(id);
      await _load();
    }
  }

  Future<void> _quickTransfer(SavingGoal goal) async {
    final amountController = TextEditingController();
    final dashboardState = ref.read(dashboardProvider);
    final remainingBudget = dashboardState.remainingFund;

    double parseAmount(String raw) {
      final normalized = raw.replaceAll('.', '').replaceAll(',', '.').trim();
      final value = double.tryParse(normalized) ?? 0;
      return value.isFinite ? value : 0;
    }

    final success = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Amankan Anggaran ke Celengan 💸',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Masukkan nominal jatah/budget yang ingin Anda pindahkan dari dompet harian ke celengan "${goal.name}".',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.wallet_rounded, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Sisa Dana Fleksibel Tersedia', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            Text(
                              CurrencyService.formatRupiah(remainingBudget),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'Nominal Transfer (Rp)',
                    prefixIcon: const Icon(Icons.add_card_rounded, color: AppColors.primary),
                    filled: true,
                    fillColor: isDark ? AppColors.surfaceVariantDark.withValues(alpha: 0.3) : AppColors.surfaceVariantLight.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () async {
                    final amount = parseAmount(amountController.text);
                    if (amount <= 0) return;
                    if (amount > remainingBudget) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Anggaran tidak cukup! Kurangi nominal transfer Anda.'),
                          backgroundColor: AppColors.alert,
                        ),
                      );
                      return;
                    }

                    // Perform transfer
                    await ref.read(dashboardProvider.notifier).transferToGoal(amount, goal);
                    
                    if (context.mounted) {
                      Navigator.pop(context, true);
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text('Konfirmasi & Transfer Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );

    amountController.dispose();
    if (success == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil memindahkan jatah belanja ke celengan "${goal.name}"! 🥳'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      await _load();
    }
  }

  void _onNavigate(int index) {
    switch (index) {
      case 0: context.go(AppRouter.dashboard); break;
      case 1: context.go(AppRouter.transactions); break;
      case 2: context.go(AppRouter.budget); break;
      case 3: break; // current
      case 4: context.go(AppRouter.reports); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Calculate Multi Saving Summaries
    double totalCollected = 0.0;
    double totalTarget = 0.0;
    for (final g in _goals) {
      totalCollected += g.currentAmount;
      totalTarget += g.targetAmount;
    }
    // Include general auto-balance
    final grandTotalCollected = totalCollected + _balance;
    final totalProgress = totalTarget <= 0 ? 0.0 : (grandTotalCollected / totalTarget).clamp(0.0, 1.0);
    final totalRemaining = (totalTarget - grandTotalCollected).clamp(0.0, double.infinity);

    return Scaffold(
      body: SafeArea(
        child: _loading
            ? _buildSavingsShimmer()
            : RefreshIndicator(
                onRefresh: _load,
                color: AppColors.primary,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  children: [
                    // Executive Page Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tabungan & Celengan',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary),
                            ),
                            Text(
                              'Brankas Impian',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ).animate().fade().slideX(begin: -0.1),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceVariantDark : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                          ),
                          child: const PhosphorIcon(PhosphorIconsRegular.vault, color: AppColors.primary, size: 28),
                        ).animate().scale(delay: 200.ms),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Premium Multi-Savings Summary Hero Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
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
                                'Total Celengan Terkumpul',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  _goals.isNotEmpty ? 'Target aktif' : 'Belum ada target',
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Terkumpul',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            CurrencyService.formatRupiah(grandTotalCollected),
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (totalTarget > 0) ...[
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progres Kumulatif Target',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${(totalProgress * 100).toInt()}%',
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            NataProgressBar(
                              value: totalProgress,
                              height: 8,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.7),
                                  Colors.white,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Target: ${CurrencyService.formatRupiah(totalTarget)}',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11),
                                ),
                                Text(
                                  'Kurang: ${CurrencyService.formatRupiah(totalRemaining)}',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
                    const SizedBox(height: 16),

                    // Stat Metrics Grid
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceVariantDark : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 18),
                                ),
                                const SizedBox(height: 12),
                                const Text('Saldo Auto-Celengan', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(CurrencyService.formatRupiah(_balance), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceVariantDark : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.wallet_rounded, color: AppColors.primary, size: 18),
                                ),
                                const SizedBox(height: 12),
                                const Text('Sisa menuju target', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(CurrencyService.formatRupiah(totalRemaining), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ).animate().fade(delay: 150.ms).slideY(begin: 0.1),
                    const SizedBox(height: 24),

                    // Auto-saving Switch Panel
                    Builder(
                      builder: (context) {
                        final totalAutoSave = _goals.fold<double>(0.0, (sum, g) => sum + (g.autoSaveAmount ?? 0.0));
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceVariantDark : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.bolt_rounded, color: AppColors.accent, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Auto-celengan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    const SizedBox(height: 2),
                                    Text(
                                      _settings.autoSavingEnabled 
                                        ? (totalAutoSave > 0 
                                            ? 'Setiap hari, ${CurrencyService.formatRupiah(totalAutoSave)} disisihkan otomatis dari jatah harianmu. Alokasi berikutnya: besok'
                                            : 'Setiap hari, sisa jatah belanja otomatis disisihkan ke celengan impianmu. Alokasi berikutnya: besok')
                                        : 'Auto-celengan dinonaktifkan',
                                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: _settings.autoSavingEnabled,
                                activeThumbColor: AppColors.primary,
                                activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
                                onChanged: (value) {
                                  if (value) {
                                    _showAutoSavingExplanation();
                                  } else {
                                    _toggleAutoSaving(false);
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      }
                    ).animate().fade(delay: 200.ms),
                    const SizedBox(height: 28),

                    // Multi Savings Title & Add button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Celengan Impian Anda',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: () => _upsertGoal(),
                          icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                          label: const Text('Atur Target'),
                          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                        ),
                      ],
                    ).animate().fade(delay: 220.ms),
                    const SizedBox(height: 12),

                    // Multi-Goal Cards Grid
                    if (_goals.isEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceVariantDark : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.savings_outlined, color: Colors.grey.withValues(alpha: 0.5), size: 48),
                            const SizedBox(height: 12),
                            const Text(
                              'Belum ada celengan impian.\nYuk buat celengan pertamamu sekarang! 💎',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, height: 1.4),
                            ),
                            const SizedBox(height: 16),
                            NataPressScale(
                              onTap: () => _upsertGoal(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.25),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.add, size: 18, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Buat Celengan Sekarang',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fade(delay: 250.ms),
                    ] else ...[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _goals.length,
                        itemBuilder: (context, index) {
                          final goal = _goals[index];
                          final progress = goal.targetAmount <= 0 
                              ? 0.0 
                              : (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
                          final remaining = (goal.targetAmount - goal.currentAmount).clamp(0.0, double.infinity);
                          
                          String timelineText = 'Tanpa batas waktu';
                          if (goal.targetDate != null) {
                            final days = goal.targetDate!.difference(DateTime.now()).inDays;
                            timelineText = days < 0 
                                ? 'Lewat target' 
                                : days == 0 
                                    ? 'Hari ini' 
                                    : 'Sisa $days hari lagi';
                          }
                          final transactions = ref.watch(dashboardProvider).transactions;
                          final goalAllocations = <Map<String, dynamic>>[];

                          // 1. From transaction history (manual transfers)
                          for (final tx in transactions) {
                            if (tx.category == 'Menabung' && tx.note != null && tx.note!.contains(goal.name)) {
                              goalAllocations.add({
                                'date': tx.date.toIso8601String(),
                                'amount': tx.amount,
                                'source': 'Transfer Manual',
                              });
                            }
                          }

                          // 2. From saving allocations history (auto allocations)
                          for (final alloc in _history) {
                            final source = (alloc['source'] as String?) ?? '';
                            if (source == goal.name || source.contains(goal.name)) {
                              goalAllocations.add({
                                'date': alloc['date'] as String,
                                'amount': (alloc['amount'] as num).toDouble(),
                                'source': 'Auto-celengan',
                              });
                            }
                          }

                          // Sort by date descending
                          goalAllocations.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));

                          final isUnder20 = progress < 0.20;
                          final kurangColor = isUnder20 
                              ? (isDark ? const Color(0xFFFBBF24) : Colors.amber.shade800)
                              : Theme.of(context).colorScheme.primary;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_expandedGoalId == goal.id) {
                                  _expandedGoalId = null;
                                } else {
                                  _expandedGoalId = goal.id;
                                }
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceVariantDark : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          goal.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: () => _upsertGoal(goal),
                                            icon: const Icon(Icons.edit_rounded, size: 18, color: Colors.grey),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                          const SizedBox(width: 12),
                                          IconButton(
                                            onPressed: () => _deleteGoal(goal.id),
                                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.alert),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_month_rounded, size: 12, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(timelineText, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Terkumpul: ${CurrencyService.formatRupiah(goal.currentAmount)}',
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: isDark ? Colors.white70 : Colors.black87),
                                      ),
                                      Text(
                                        '${(progress * 100).toInt()}%',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  goal.currentAmount == 0
                                      ? Shimmer.fromColors(
                                          baseColor: isDark ? const Color(0xFF1E2F2D) : const Color(0xFFE0F2F1),
                                          highlightColor: isDark ? const Color(0xFF2DD4BF).withOpacity(0.3) : const Color(0xFFB2DFDB),
                                          child: NataProgressBar(
                                            value: 0.05,
                                            height: 8,
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFF00B4A6), Color(0xFF00D4C8)],
                                            ),
                                          ),
                                        )
                                      : NataProgressBar(
                                          value: progress,
                                          height: 8,
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF00B4A6), Color(0xFF00D4C8)],
                                          ),
                                        ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Target: ${CurrencyService.formatRupiah(goal.targetAmount)}',
                                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                                      ),
                                      Text(
                                        'Kurang: ${CurrencyService.formatRupiah(remaining)}',
                                        style: TextStyle(color: kurangColor, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  const Divider(height: 1),
                                  const SizedBox(height: 10),
                                  NataPressScale(
                                    onTap: () => _quickTransfer(goal),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Icon(Icons.add_circle_rounded, size: 18, color: AppColors.primary),
                                          SizedBox(width: 8),
                                          Text(
                                            'Amankan Jatah Ke Sini',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  AnimatedSize(
                                    duration: NataDuration.normal,
                                    curve: NataCurve.smooth,
                                    alignment: Alignment.topCenter,
                                    child: _expandedGoalId == goal.id
                                        ? Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 16),
                                              const Divider(height: 1),
                                              const SizedBox(height: 12),
                                              Text(
                                                'Riwayat Alokasi 🕒',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: isDark ? Colors.white70 : Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              if (goalAllocations.isEmpty)
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 8),
                                                  child: Text(
                                                    'Belum ada riwayat alokasi untuk celengan ini. Yuk, mulai menabung! 🌱',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey,
                                                      fontStyle: FontStyle.italic,
                                                    ),
                                                  ),
                                                )
                                              else
                                                ListView.builder(
                                                  shrinkWrap: true,
                                                  physics: const NeverScrollableScrollPhysics(),
                                                  itemCount: goalAllocations.length > 5 ? 5 : goalAllocations.length,
                                                  itemBuilder: (context, allocIndex) {
                                                    final alloc = goalAllocations[allocIndex];
                                                    final allocAmount = alloc['amount'] as double;
                                                    final allocDateStr = alloc['date'] as String;
                                                    final allocSource = alloc['source'] as String;
                                                    
                                                    // Format date to Indonesian
                                                    DateTime? parsedDate = DateTime.tryParse(allocDateStr);
                                                    String formattedDate = '';
                                                    if (parsedDate != null) {
                                                      formattedDate = DateFormat('d MMM yyyy', 'id_ID').format(parsedDate);
                                                    } else {
                                                      formattedDate = allocDateStr.split('T').first;
                                                    }

                                                    return Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                formattedDate,
                                                                style: const TextStyle(
                                                                  fontSize: 11,
                                                                  fontWeight: FontWeight.w600,
                                                                ),
                                                              ),
                                                              Text(
                                                                allocSource,
                                                                style: const TextStyle(
                                                                  fontSize: 9,
                                                                  color: Colors.grey,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Text(
                                                            '+${CurrencyService.formatRupiah(allocAmount)}',
                                                            style: const TextStyle(
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.bold,
                                                              color: AppColors.primary,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                            ],
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fade(delay: Duration(milliseconds: 100 * index)).slideX(begin: 0.05);
                        },
                      ),
                    ],
                    
                    const SizedBox(height: 28),

                    // Savings Flow Panel
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceVariantDark : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Alur tabungan', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          _buildFlowStep(
                            number: '1',
                            title: 'Simpan Anggaran',
                            body: 'Masukkan nominal alokasi tabungan bulanan saat setup keuangan.',
                            active: true,
                          ),
                          _buildFlowStep(
                            number: '2',
                            title: 'Amankan Jatah Harian',
                            body: 'Setiap hari Anda bisa amankan sisa jatah belanja ke celengan spesifik secara manual atau otomatis.',
                            active: _settings.autoSavingEnabled,
                          ),
                          _buildFlowStep(
                            number: '3',
                            title: 'Impian Tercapai!',
                            body: 'Saldo celengan naik, mengantarkan Anda mewujudkan mimpi-mimpi finansial.',
                            active: true,
                            isLast: true,
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 300.ms),

                    const SizedBox(height: 28),

                    // Savings Allocation History
                    Text(
                      'Riwayat Alokasi Tabungan',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ).animate().fade(delay: 320.ms),
                    const SizedBox(height: 12),

                    if (_history.isEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceVariantDark : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                        ),
                        child: const Center(
                          child: Text(
                            'Belum ada riwayat alokasi otomatis.\nRiwayat terkumpul saat auto-saving aktif di tengah malam.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.3),
                          ),
                        ),
                      ).animate().fade(delay: 350.ms),
                    ] else ...[
                      Container(
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _history.length > 5 ? 5 : _history.length,
                            separatorBuilder: (_, __) => Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                            itemBuilder: (context, index) {
                              final item = _history[index];
                              final amount = (item['amount'] as num).toDouble();
                              final dateStr = ((item['date'] as String?) ?? '').split('T').first;
                              final source = (item['source'] as String?) ?? 'auto';

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent.withValues(alpha: 0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.add_rounded, color: AppColors.accent, size: 16),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                          Text(
                                            source == 'auto' || source == 'daily_closing'
                                              ? 'Auto-celengan dari Tutup Hari' 
                                              : source,
                                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '+${CurrencyService.formatRupiah(amount)}',
                                      style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ).animate().fade(delay: 350.ms),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildFlowStep({
    required String number,
    required String title,
    required String body,
    required bool active,
    bool isLast = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = active ? AppColors.primary : Colors.grey;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : (isDark ? AppColors.surfaceVariantDark : Colors.grey.shade100),
                shape: BoxShape.circle,
              ),
              child: Text(
                number,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 1.5,
                height: 32,
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: const TextStyle(color: Colors.grey, fontSize: 12, height: 1.35),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSavingsShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NataShimmer(width: 140, height: 16, borderRadius: BorderRadius.circular(8)),
                  const SizedBox(height: 8),
                  NataShimmer(width: 200, height: 32, borderRadius: BorderRadius.circular(8)),
                ],
              ),
              NataShimmer(width: 52, height: 52, borderRadius: BorderRadius.circular(26)),
            ],
          ),
          const SizedBox(height: 20),
          // Hero card shimmer
          NataShimmer(width: double.infinity, height: 210, borderRadius: BorderRadius.circular(28)),
          const SizedBox(height: 28),
          // Section title
          NataShimmer(width: 120, height: 20, borderRadius: BorderRadius.circular(8)),
          const SizedBox(height: 12),
          // Savings goals list (simulated cards)
          Row(
            children: [
              Expanded(child: NataShimmer(width: double.infinity, height: 140, borderRadius: BorderRadius.circular(24))),
              const SizedBox(width: 12),
              Expanded(child: NataShimmer(width: double.infinity, height: 140, borderRadius: BorderRadius.circular(24))),
            ],
          ),
          const SizedBox(height: 12),
          NataShimmer(width: double.infinity, height: 120, borderRadius: BorderRadius.circular(24)),
        ],
      ),
    );
  }
}
