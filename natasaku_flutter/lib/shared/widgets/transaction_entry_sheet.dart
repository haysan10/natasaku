import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/datasources/local/local_storage.dart';
import '../../data/repositories/budget_repository.dart';
import '../../core/theme/app_colors.dart';
import 'nata_money_input.dart';

class TransactionDraft {
  const TransactionDraft({
    required this.amount,
    required this.isExpense,
    required this.date,
    this.category,
    this.note,
    this.photoPath,
    this.isNeed = true,
  });

  final int amount;
  final bool isExpense;
  final DateTime date;
  final String? category;
  final String? note;
  final String? photoPath;
  final bool isNeed;
}

const List<({String label, int amount, String category})> quickExpenseTemplates = [
  (label: 'Kopi', amount: 15000, category: '☕ Kopi & Jajan'),
  (label: 'Transport', amount: 5000, category: '🚌 Transportasi'),
  (label: 'Warteg', amount: 20000, category: '🍜 Makan & Minum'),
  (label: 'Indomaret', amount: 25000, category: '🛒 Belanja Bulanan'),
];

const List<String> nataCategories = <String>[
  '🍜 Makan & Minum',
  '🚌 Transportasi',
  '🛒 Belanja Bulanan',
  '☕ Kopi & Jajan',
  '🎬 Hiburan',
  '👕 Pakaian',
  '💊 Kesehatan',
  '💄 Kecantikan',
  '📱 Elektronik',
  '🏃 Olahraga',
  '📖 Pendidikan',
  '🎀 Hadiah',
  '🚨 Darurat',
  '➕ Lainnya',
];

Future<TransactionDraft?> showTransactionEntrySheet(
  BuildContext context, {
  bool initialExpense = true,
  int? initialAmount,
  String? initialCategory,
  String? initialNote,
  DateTime? initialDate,
  String? initialPhotoPath,
  bool initialNeed = true,
}) {
  return showModalBottomSheet<TransactionDraft>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return _TransactionEntryContent(
        initialExpense: initialExpense,
        initialAmount: initialAmount,
        initialCategory: initialCategory,
        initialNote: initialNote,
        initialDate: initialDate,
        initialPhotoPath: initialPhotoPath,
        initialNeed: initialNeed,
      );
    },
  );
}

class _TransactionEntryContent extends StatefulWidget {
  final bool initialExpense;
  final int? initialAmount;
  final String? initialCategory;
  final String? initialNote;
  final DateTime? initialDate;
  final String? initialPhotoPath;
  final bool initialNeed;

  const _TransactionEntryContent({
    required this.initialExpense,
    this.initialAmount,
    this.initialCategory,
    this.initialNote,
    this.initialDate,
    this.initialPhotoPath,
    required this.initialNeed,
  });

  @override
  State<_TransactionEntryContent> createState() =>
      _TransactionEntryContentState();
}

class _TransactionEntryContentState extends State<_TransactionEntryContent> {
  late bool _isExpense;
  late bool _isNeed;
  late final TextEditingController _amountController;
  DateTime _date = DateTime.now();
  String? _category;
  String? _note;
  String? _errorMessage;
  String? _photoPath;
  bool _isSaving = false;
  List<int> _quickPresets = [10000, 25000, 50000, 100000];

  @override
  void initState() {
    super.initState();
    _isExpense = widget.initialExpense;
    _isNeed = widget.initialNeed;
    _date = widget.initialDate ?? DateTime.now();
    _category = widget.initialCategory;
    _note = widget.initialNote;
    _photoPath = widget.initialPhotoPath;

    String initialText = '';
    if (widget.initialAmount != null && widget.initialAmount! > 0) {
      final formatter = NumberFormat.decimalPattern('id');
      initialText = 'Rp ${formatter.format(widget.initialAmount!)}';
    }
    _amountController = TextEditingController(text: initialText);
    _loadQuickPresets();
  }

  Future<void> _loadQuickPresets() async {
    final repo = BudgetRepository(LocalStorage());
    final presets = await repo.loadQuickAmountPresets();
    if (mounted) {
      setState(() => _quickPresets = presets);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  int get _parsedAmount {
    final digits = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 0;
    return int.tryParse(digits) ?? 0;
  }

  bool get _canSubmit => !_isSaving && _parsedAmount > 0 && _category != null;

  String _formatPreset(int value) {
    if (value >= 1000000) {
      final m = value / 1000000;
      return 'Rp${m.toStringAsFixed(m.truncateToDouble() == m ? 0 : 1)}jt';
    } else if (value >= 1000) {
      final k = value ~/ 1000;
      return 'Rp${k}rb';
    }
    return 'Rp$value';
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    final period = await BudgetRepository(LocalStorage()).loadPeriod();
    final firstDate = period == null
        ? DateTime(2020)
        : DateTime(
            period.startDate.year,
            period.startDate.month,
            period.startDate.day,
          );
    final initialDate = _date.isAfter(todayDateOnly)
        ? todayDateOnly
        : (_date.isBefore(firstDate) ? firstDate : _date);
    if (!mounted) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: todayDateOnly,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: _isExpense ? AppColors.alert : AppColors.accent,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _addNote() async {
    final controller = TextEditingController(text: _note);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Catatan'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 200, // Updated UX constraint to 200 characters
          decoration: const InputDecoration(
            hintText: 'Tulis sesuatu...',
            counterText:
                '', // We can custom render or use standard. Let's use custom text field or standard. Standard length display is good.
          ),
          buildCounter: (context,
              {required currentLength,
              required isFocused,
              required maxLength}) {
            return Text(
              '$currentLength/$maxLength',
              style: TextStyle(
                color: currentLength > 180
                    ? AppColors.alert
                    : AppColors.textSecondaryLight,
                fontSize: 12,
              ),
            );
          },
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor:
                    _isExpense ? AppColors.alert : AppColors.accent),
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (result != null) {
      setState(() => _note = result.trim().isEmpty ? null : result.trim());
    }
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Lampirkan Foto', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Ambil Foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Pilih dari Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            if (_photoPath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: AppColors.alert),
                title: const Text('Hapus Foto', style: TextStyle(color: AppColors.alert)),
                onTap: () {
                  setState(() => _photoPath = null);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );

    if (source == null) return;
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      if (picked == null) return;

      // Copy to app-local directory
      final appDir = await getApplicationDocumentsDirectory();
      final receiptsDir = Directory('${appDir.path}/receipts');
      if (!receiptsDir.existsSync()) receiptsDir.createSync(recursive: true);
      final fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = '${receiptsDir.path}/$fileName';
      await File(picked.path).copy(savedPath);

      if (mounted) {
        HapticFeedback.lightImpact();
        setState(() => _photoPath = savedPath);
      }
    } catch (_) {
      // Silently fail if image picker is unavailable
    }
  }

  Future<void> _pickCategory() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pilih Kategori',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: nataCategories
                  .map((c) => ActionChip(
                        label: Text(c),
                        onPressed: () => Navigator.pop(context, c),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _category = result;
        _errorMessage = null;
      });
    }
  }

  void _submit() {
    if (_isSaving) return;
    final amount = _parsedAmount;
    if (amount <= 0) {
      HapticFeedback.heavyImpact();
      setState(() => _errorMessage = 'Nominal harus lebih dari Rp 0!');
      return;
    }
    if (amount > 999999999999) {
      HapticFeedback.heavyImpact();
      setState(() => _errorMessage = 'Nominal terlalu besar!');
      return;
    }
    if (_category == null) {
      HapticFeedback.heavyImpact();
      setState(() => _errorMessage = 'Pilih kategori pengeluaran dulu.');
      return;
    }

    HapticFeedback.lightImpact();
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      Navigator.pop(
        context,
        TransactionDraft(
          amount: amount,
          isExpense: _isExpense,
          date: _date,
          category: _category,
          note: _note,
          photoPath: _photoPath,
          isNeed: _isNeed,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _isExpense ? AppColors.alert : AppColors.accent;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Toggle
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  Expanded(
                    child: _TypeToggle(
                      title: 'Pengeluaran',
                      icon: PhosphorIconsRegular.trendDown,
                      isSelected: _isExpense,
                      activeColor: AppColors.alert,
                      onTap: () => setState(() => _isExpense = true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TypeToggle(
                      title: 'Pemasukan',
                      icon: PhosphorIconsRegular.trendUp,
                      isSelected: !_isExpense,
                      activeColor: AppColors.accent,
                      onTap: () => setState(() => _isExpense = false),
                    ),
                  ),
                ],
              ),
            ),

            if (_isExpense) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final template in quickExpenseTemplates)
                        ActionChip(
                          label: Text(template.label),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            final formatter = NumberFormat.decimalPattern('id');
                            setState(() {
                              _category = template.category;
                              _amountController.text =
                                  'Rp ${formatter.format(template.amount)}';
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],

            if (_errorMessage != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.alert.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.alert.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AppColors.alert, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                              color: AppColors.alert,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // ── Quick Amount Presets ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    for (final preset in _quickPresets)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(_formatPreset(preset)),
                          backgroundColor: activeColor.withValues(alpha: 0.08),
                          side: BorderSide(color: activeColor.withValues(alpha: 0.2)),
                          labelStyle: TextStyle(
                            color: activeColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            final formatter = NumberFormat.decimalPattern('id');
                            setState(() {
                              _amountController.text = 'Rp ${formatter.format(preset)}';
                              _errorMessage = null;
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Display Amount TextField
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceVariantDark : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: activeColor.withValues(alpha: 0.3), width: 2),
                ),
                child: TextField(
                  controller: _amountController,
                  autofocus: false,
                  readOnly: true,
                  showCursor: false,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 32,
                        color: activeColor,
                        fontWeight: FontWeight.w900,
                      ),
                  decoration: InputDecoration(
                    hintText: 'Rp 0',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white24 : Colors.black26,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    suffixIcon: _parsedAmount > 0
                        ? IconButton(
                            icon: Icon(Icons.cancel,
                                color: activeColor.withValues(alpha: 0.5)),
                            onPressed: () {
                              setState(() {
                                _amountController.clear();
                                _errorMessage = null;
                              });
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),

            // Metadata Row (Category, Date, Note)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _MetaChip(
                    icon: PhosphorIconsRegular.calendar,
                    label: DateFormat('dd MMM', 'id_ID').format(_date),
                    onTap: _pickDate,
                    activeColor: activeColor,
                  ),
                  const SizedBox(width: 8),
                  _MetaChip(
                    icon: PhosphorIconsRegular.tag,
                    label: _category ?? 'Kategori',
                    onTap: _pickCategory,
                    activeColor: activeColor,
                    isSet: _category != null,
                  ),
                  const SizedBox(width: 8),
                  _MetaChip(
                    icon: PhosphorIconsRegular.textAa,
                    label: _note == null
                        ? 'Catatan'
                        : (_note!.length > 10
                            ? '${_note!.substring(0, 10)}...'
                            : _note!),
                    onTap: _addNote,
                    activeColor: activeColor,
                    isSet: _note != null,
                  ),
                  const SizedBox(width: 8),
                  _MetaChip(
                    icon: PhosphorIconsRegular.camera,
                    label: _photoPath != null ? 'Foto ✓' : 'Foto',
                    onTap: _pickPhoto,
                    activeColor: activeColor,
                    isSet: _photoPath != null,
                  ),
                ],
              ),
            ),

            // ── Photo Preview ──────────────────────────────────────────
            if (_photoPath != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Image.file(
                        File(_photoPath!),
                        height: 80,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => setState(() => _photoPath = null),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (_isExpense) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        decoration: BoxDecoration(
                          color: _isNeed
                              ? AppColors.success.withValues(alpha: 0.1)
                              : (isDark ? AppColors.surfaceVariantDark : Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isNeed ? AppColors.success : (isDark ? AppColors.borderDark : AppColors.borderLight),
                            width: _isNeed ? 2 : 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _isNeed = true);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  PhosphorIconsRegular.shieldCheck,
                                  color: _isNeed ? AppColors.success : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Kebutuhan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: _isNeed ? AppColors.success : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        decoration: BoxDecoration(
                          color: !_isNeed
                              ? AppColors.warning.withValues(alpha: 0.1)
                              : (isDark ? AppColors.surfaceVariantDark : Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: !_isNeed ? AppColors.warning : (isDark ? AppColors.borderDark : AppColors.borderLight),
                            width: !_isNeed ? 2 : 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _isNeed = false);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  PhosphorIconsRegular.sparkle,
                                  color: !_isNeed ? AppColors.warning : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Keinginan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: !_isNeed ? AppColors.warning : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: NataMoneyNumpad(
                controller: _amountController,
                activeColor: activeColor,
                enabled: !_isSaving,
                withPrefix: true,
                onChanged: (_) {
                  setState(() => _errorMessage = null);
                },
              ),
            ),

            // Save Button Panel (replacing custom numpad)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    )
                  ]),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: activeColor,
                    disabledBackgroundColor: activeColor.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: _canSubmit ? _submit : null,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Simpan',
                            key: ValueKey('save_text'),
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _TypeToggle({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isSelected
        ? activeColor
        : (isDark ? AppColors.surfaceVariantDark : Colors.white);
    final fgColor = isSelected
        ? Colors.white
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isSelected
                    ? activeColor
                    : (isDark ? AppColors.borderDark : AppColors.borderLight)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PhosphorIcon(icon, color: fgColor, size: 18),
              const SizedBox(width: 8),
              Text(title,
                  style:
                      TextStyle(color: fgColor, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color activeColor;
  final bool isSet;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.activeColor,
    this.isSet = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isSet
        ? activeColor
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

    return Material(
      color: isSet
          ? activeColor.withValues(alpha: 0.1)
          : (isDark ? AppColors.surfaceVariantDark : Colors.white),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isSet
                    ? activeColor.withValues(alpha: 0.3)
                    : (isDark ? AppColors.borderDark : AppColors.borderLight)),
          ),
          child: Row(
            children: [
              PhosphorIcon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: color, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
