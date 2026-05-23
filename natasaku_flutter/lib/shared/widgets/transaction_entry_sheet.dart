import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/services/currency_service.dart';

class TransactionDraft {
  const TransactionDraft({
    required this.amount,
    required this.isExpense,
    required this.date,
    this.category,
    this.note,
  });

  final double amount;
  final bool isExpense;
  final DateTime date;
  final String? category;
  final String? note;
}

const List<String> nataCategories = <String>[
  'Makan', 'Minum', 'Transport', 'Belanja', 'Tagihan', 
  'Keluarga', 'Hiburan', 'Kesehatan', 'Lainnya',
];

Future<TransactionDraft?> showTransactionEntrySheet(
  BuildContext context, {
  bool initialExpense = true,
  double? initialAmount,
  String? initialCategory,
  String? initialNote,
  DateTime? initialDate,
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
      );
    },
  );
}

class _TransactionEntryContent extends StatefulWidget {
  final bool initialExpense;
  final double? initialAmount;
  final String? initialCategory;
  final String? initialNote;
  final DateTime? initialDate;

  const _TransactionEntryContent({
    required this.initialExpense,
    this.initialAmount,
    this.initialCategory,
    this.initialNote,
    this.initialDate,
  });

  @override
  State<_TransactionEntryContent> createState() => _TransactionEntryContentState();
}

class _TransactionEntryContentState extends State<_TransactionEntryContent> {
  late bool _isExpense;
  String _amountStr = '';
  DateTime _date = DateTime.now();
  String? _category;
  String? _note;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isExpense = widget.initialExpense;
    _date = widget.initialDate ?? DateTime.now();
    _category = widget.initialCategory;
    _note = widget.initialNote;

    if (widget.initialAmount != null && widget.initialAmount! > 0) {
      _amountStr = widget.initialAmount!.toInt().toString();
    }
  }

  void _onNumpadTap(String value) {
    HapticFeedback.lightImpact();
    setState(() {
      _errorMessage = null; // Clear error when typing
      if (value == 'backspace') {
        if (_amountStr.isNotEmpty) {
          _amountStr = _amountStr.substring(0, _amountStr.length - 1);
        }
      } else if (value == '000') {
        if (_amountStr.isNotEmpty && _amountStr.length < 10) {
          _amountStr += '000';
        }
      } else {
        if (_amountStr.length < 12) {
          _amountStr += value;
        }
      }
    });
  }

  double get _parsedAmount {
    if (_amountStr.isEmpty) return 0;
    return double.tryParse(_amountStr) ?? 0;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
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
            counterText: '', // We can custom render or use standard. Let's use custom text field or standard. Standard length display is good.
          ),
          buildCounter: (context, {required currentLength, required isFocused, required maxLength}) {
            return Text(
              '$currentLength/$maxLength',
              style: TextStyle(
                color: currentLength > 180 ? AppColors.alert : AppColors.textSecondaryLight,
                fontSize: 12,
              ),
            );
          },
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _isExpense ? AppColors.alert : AppColors.accent),
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
            Text('Pilih Kategori', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: nataCategories.map((c) => ActionChip(
                label: Text(c),
                onPressed: () => Navigator.pop(context, c),
              )).toList(),
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
    if (_parsedAmount <= 0) {
      HapticFeedback.heavyImpact();
      setState(() => _errorMessage = 'Nominal harus lebih dari Rp 0!');
      return;
    }
    if (_parsedAmount > 999999999999) {
      HapticFeedback.heavyImpact();
      setState(() => _errorMessage = 'Nominal terlalu besar!');
      return;
    }
    Navigator.pop(
      context,
      TransactionDraft(
        amount: _parsedAmount,
        isExpense: _isExpense,
        date: _date,
        category: _category ?? 'Lainnya', // Robust fallback category!
        note: _note,
      ),
    );
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

            if (_errorMessage != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.alert.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.alert.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.alert, size: 20),
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
              ),
              const SizedBox(height: 12),
            ],

            // Display Amount
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceVariantDark : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: activeColor.withValues(alpha: 0.3), width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      _amountStr.isEmpty ? 'Rp 0' : CurrencyService.formatRupiah(_parsedAmount),
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: _amountStr.length > 8 ? 32 : 48,
                        color: _amountStr.isEmpty ? AppColors.textSecondaryLight : activeColor,
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ).animate(target: _amountStr.isNotEmpty ? 1 : 0).scale(duration: 100.ms, begin: const Offset(0.9, 0.9)),
                  ],
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
                    label: _note == null ? 'Catatan' : (_note!.length > 10 ? '${_note!.substring(0, 10)}...' : _note!),
                    onTap: _addNote,
                    activeColor: activeColor,
                    isSet: _note != null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            
            // Numpad
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  )
                ]
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _NumpadBtn('1', onTap: () => _onNumpadTap('1')),
                      _NumpadBtn('2', onTap: () => _onNumpadTap('2')),
                      _NumpadBtn('3', onTap: () => _onNumpadTap('3')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _NumpadBtn('4', onTap: () => _onNumpadTap('4')),
                      _NumpadBtn('5', onTap: () => _onNumpadTap('5')),
                      _NumpadBtn('6', onTap: () => _onNumpadTap('6')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _NumpadBtn('7', onTap: () => _onNumpadTap('7')),
                      _NumpadBtn('8', onTap: () => _onNumpadTap('8')),
                      _NumpadBtn('9', onTap: () => _onNumpadTap('9')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _NumpadBtn('000', onTap: () => _onNumpadTap('000'), isSpecial: true),
                      _NumpadBtn('0', onTap: () => _onNumpadTap('0')),
                      _NumpadBtn(
                        '<', 
                        onTap: () => _onNumpadTap('backspace'), 
                        isSpecial: true, 
                        icon: PhosphorIconsRegular.backspace,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: activeColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: _parsedAmount <= 0 ? null : _submit,
                      child: const Text(
                        'Simpan Transaksi',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
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
    final bgColor = isSelected ? activeColor : (isDark ? AppColors.surfaceVariantDark : Colors.white);
    final fgColor = isSelected ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

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
            border: Border.all(color: isSelected ? activeColor : (isDark ? AppColors.borderDark : AppColors.borderLight)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PhosphorIcon(icon, color: fgColor, size: 18),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: fgColor, fontWeight: FontWeight.w600)),
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
    final color = isSet ? activeColor : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);
    
    return Material(
      color: isSet ? activeColor.withValues(alpha: 0.1) : (isDark ? AppColors.surfaceVariantDark : Colors.white),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSet ? activeColor.withValues(alpha: 0.3) : (isDark ? AppColors.borderDark : AppColors.borderLight)),
          ),
          child: Row(
            children: [
              PhosphorIcon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumpadBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isSpecial;
  final IconData? icon;

  const _NumpadBtn(this.label, {required this.onTap, this.isSpecial = false, this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: isSpecial ? (isDark ? AppColors.surfaceVariantDark : AppColors.backgroundLight) : Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: MediaQuery.of(context).size.width / 3 - 32,
          height: 64,
          alignment: Alignment.center,
          decoration: isSpecial ? null : BoxDecoration(
            borderRadius: BorderRadius.circular(24),
          ),
          child: icon != null
              ? PhosphorIcon(icon!, size: 28, color: isDark ? Colors.white : Colors.black87)
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: isSpecial ? 24 : 32,
                    fontWeight: isSpecial ? FontWeight.w600 : FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
        ),
      ),
    );
  }
}
