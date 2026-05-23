import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/rupiah_numpad_input.dart';
import 'nata_press_scale.dart';

class NataMoneyInput extends StatefulWidget {
  const NataMoneyInput({
    super.key,
    required this.controller,
    required this.decoration,
    this.activeColor = AppColors.primary,
    this.autofocus = false,
    this.autovalidateMode,
    this.enabled = true,
    this.maxDigits = 12,
    this.onChanged,
    this.style,
    this.validator,
    this.withPrefix = false,
  });

  final TextEditingController controller;
  final InputDecoration decoration;
  final Color activeColor;
  final bool autofocus;
  final AutovalidateMode? autovalidateMode;
  final bool enabled;
  final int maxDigits;
  final ValueChanged<String>? onChanged;
  final TextStyle? style;
  final FormFieldValidator<String>? validator;
  final bool withPrefix;

  @override
  State<NataMoneyInput> createState() => _NataMoneyInputState();
}

class _NataMoneyInputState extends State<NataMoneyInput>
    with TickerProviderStateMixin {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _normalizeControllerText();

    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(covariant NataMoneyInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.withPrefix != widget.withPrefix) {
      _normalizeControllerText();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) setState(() {});
  }

  void _normalizeControllerText() {
    final formatted = RupiahNumpadInput.formatRaw(
      widget.controller.text,
      withPrefix: widget.withPrefix,
    );
    if (formatted == widget.controller.text) return;

    widget.controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _handleChanged(String value) {
    widget.onChanged?.call(value);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          readOnly: true,
          showCursor: false,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          keyboardType: TextInputType.none,
          autovalidateMode: widget.autovalidateMode,
          style: widget.style,
          validator: widget.validator,
          onTap: () => _focusNode.requestFocus(),
          decoration: widget.decoration.copyWith(
            suffixIcon: widget.controller.text.isEmpty
                ? widget.decoration.suffixIcon
                : IconButton(
                    tooltip: 'Bersihkan nominal',
                    onPressed: widget.enabled
                        ? () {
                            widget.controller.clear();
                            widget.onChanged?.call('');
                            setState(() {});
                          }
                        : null,
                    icon: Icon(
                      PhosphorIconsRegular.xCircle,
                      color: widget.activeColor.withValues(alpha: 0.68),
                    ),
                  ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: isFocused
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: NataMoneyNumpad(
                    controller: widget.controller,
                    activeColor: widget.activeColor,
                    enabled: widget.enabled,
                    maxDigits: widget.maxDigits,
                    onChanged: _handleChanged,
                    withPrefix: widget.withPrefix,
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class NataNumberInput extends StatefulWidget {
  const NataNumberInput({
    super.key,
    required this.controller,
    required this.decoration,
    this.activeColor = AppColors.primary,
    this.autofocus = false,
    this.enabled = true,
    this.maxDigits = 2,
    this.onChanged,
    this.style,
  });

  final TextEditingController controller;
  final InputDecoration decoration;
  final Color activeColor;
  final bool autofocus;
  final bool enabled;
  final int maxDigits;
  final ValueChanged<String>? onChanged;
  final TextStyle? style;

  @override
  State<NataNumberInput> createState() => _NataNumberInputState();
}

class _NataNumberInputState extends State<NataNumberInput>
    with TickerProviderStateMixin {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _normalizeControllerText();

    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) setState(() {});
  }

  void _normalizeControllerText() {
    final digits = RupiahNumpadInput.digitsOnly(widget.controller.text);
    final normalized = digits.length > widget.maxDigits
        ? digits.substring(0, widget.maxDigits)
        : digits;
    if (normalized == widget.controller.text) return;

    widget.controller.value = TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
    );
  }

  void _handleChanged(String value) {
    widget.onChanged?.call(value);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          readOnly: true,
          showCursor: false,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          keyboardType: TextInputType.none,
          style: widget.style,
          onTap: () => _focusNode.requestFocus(),
          decoration: widget.decoration.copyWith(
            suffixIcon: widget.controller.text.isEmpty
                ? widget.decoration.suffixIcon
                : IconButton(
                    tooltip: 'Bersihkan angka',
                    onPressed: widget.enabled
                        ? () {
                            widget.controller.clear();
                            widget.onChanged?.call('');
                            setState(() {});
                          }
                        : null,
                    icon: Icon(
                      PhosphorIconsRegular.xCircle,
                      color: widget.activeColor.withValues(alpha: 0.68),
                    ),
                  ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: isFocused
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: NataNumberNumpad(
                    controller: widget.controller,
                    activeColor: widget.activeColor,
                    enabled: widget.enabled,
                    maxDigits: widget.maxDigits,
                    onChanged: _handleChanged,
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class NataMoneyNumpad extends StatelessWidget {
  const NataMoneyNumpad({
    super.key,
    required this.controller,
    this.activeColor = AppColors.primary,
    this.enabled = true,
    this.maxDigits = 12,
    this.onChanged,
    this.withPrefix = false,
  });

  final TextEditingController controller;
  final Color activeColor;
  final bool enabled;
  final int maxDigits;
  final ValueChanged<String>? onChanged;
  final bool withPrefix;

  void _press(String key) {
    final next = RupiahNumpadInput.applyKey(
      controller.text,
      key,
      maxDigits: maxDigits,
      withPrefix: withPrefix,
    );

    controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
    onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    const rows = [
      [
        _NumpadToken.digit('1'),
        _NumpadToken.digit('2'),
        _NumpadToken.digit('3')
      ],
      [
        _NumpadToken.digit('4'),
        _NumpadToken.digit('5'),
        _NumpadToken.digit('6')
      ],
      [
        _NumpadToken.digit('7'),
        _NumpadToken.digit('8'),
        _NumpadToken.digit('9')
      ],
      [
        _NumpadToken.action('clear'),
        _NumpadToken.digit('0'),
        _NumpadToken.action('backspace'),
      ],
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? AppColors.borderDark.withValues(alpha: 0.9)
        : AppColors.borderLight.withValues(alpha: 0.95);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark.withValues(alpha: 0.92)
            : AppColors.surfaceVariantLight.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: _NumpadKey(
                    token: const _NumpadToken.action('000'),
                    activeColor: activeColor,
                    enabled: enabled,
                    onTap: () => _press('000'),
                    compact: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _NumpadKey(
                    token: const _NumpadToken.action('00'),
                    activeColor: activeColor,
                    enabled: enabled,
                    onTap: () => _press('00'),
                    compact: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final row in rows) ...[
              Row(
                children: [
                  for (var index = 0; index < row.length; index++) ...[
                    Expanded(
                      child: _NumpadKey(
                        token: row[index],
                        activeColor: activeColor,
                        enabled: enabled,
                        onTap: () => _press(row[index].value),
                      ),
                    ),
                    if (index != row.length - 1) const SizedBox(width: 8),
                  ],
                ],
              ),
              if (row != rows.last) const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class NataNumberNumpad extends StatelessWidget {
  const NataNumberNumpad({
    super.key,
    required this.controller,
    this.activeColor = AppColors.primary,
    this.enabled = true,
    this.maxDigits = 2,
    this.onChanged,
  });

  final TextEditingController controller;
  final Color activeColor;
  final bool enabled;
  final int maxDigits;
  final ValueChanged<String>? onChanged;

  void _press(String key) {
    final currentDigits = RupiahNumpadInput.digitsOnly(controller.text);
    var next = currentDigits;

    switch (key) {
      case 'backspace':
        next = currentDigits.isEmpty
            ? ''
            : currentDigits.substring(0, currentDigits.length - 1);
        break;
      case 'clear':
        next = '';
        break;
      default:
        if (RegExp(r'^\d$').hasMatch(key)) next = '$currentDigits$key';
    }

    if (next.length > maxDigits) next = next.substring(0, maxDigits);

    controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
    onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    const rows = [
      [
        _NumpadToken.digit('1'),
        _NumpadToken.digit('2'),
        _NumpadToken.digit('3')
      ],
      [
        _NumpadToken.digit('4'),
        _NumpadToken.digit('5'),
        _NumpadToken.digit('6')
      ],
      [
        _NumpadToken.digit('7'),
        _NumpadToken.digit('8'),
        _NumpadToken.digit('9')
      ],
      [
        _NumpadToken.action('clear'),
        _NumpadToken.digit('0'),
        _NumpadToken.action('backspace'),
      ],
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark.withValues(alpha: 0.92)
            : AppColors.surfaceVariantLight.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final row in rows) ...[
              Row(
                children: [
                  for (var index = 0; index < row.length; index++) ...[
                    Expanded(
                      child: _NumpadKey(
                        token: row[index],
                        activeColor: activeColor,
                        enabled: enabled,
                        onTap: () => _press(row[index].value),
                      ),
                    ),
                    if (index != row.length - 1) const SizedBox(width: 8),
                  ],
                ],
              ),
              if (row != rows.last) const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _NumpadKey extends StatelessWidget {
  const _NumpadKey({
    required this.token,
    required this.activeColor,
    required this.enabled,
    required this.onTap,
    this.compact = false,
  });

  final _NumpadToken token;
  final Color activeColor;
  final bool enabled;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAction = token.kind == _NumpadTokenKind.action;
    final isDanger = token.value == 'clear';
    final bgColor = switch ((isAction, isDanger, isDark)) {
      (true, true, _) => AppColors.alert.withValues(alpha: 0.12),
      (true, false, _) => activeColor.withValues(alpha: 0.14),
      (false, _, true) => AppColors.surfaceVariantDark,
      _ => Colors.white,
    };
    final borderColor = switch ((isAction, isDanger, isDark)) {
      (true, true, _) => AppColors.alert.withValues(alpha: 0.24),
      (true, false, _) => activeColor.withValues(alpha: 0.24),
      (false, _, true) => AppColors.borderDark,
      _ => AppColors.borderLight,
    };
    final fgColor = switch ((isAction, isDanger, isDark)) {
      (true, true, _) => AppColors.alert,
      (true, false, _) => activeColor,
      (false, _, true) => AppColors.textPrimaryDark,
      _ => AppColors.textPrimaryLight,
    };

    return NataPressScale(
      enabled: enabled,
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: compact ? 40 : 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? bgColor : bgColor.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: token.icon == null
            ? Text(
                token.label,
                style: TextStyle(
                  color: fgColor.withValues(alpha: enabled ? 1 : 0.5),
                  fontSize: compact ? 15 : 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              )
            : PhosphorIcon(
                token.icon!,
                size: compact ? 18 : 22,
                color: fgColor.withValues(alpha: enabled ? 1 : 0.5),
              ),
      ),
    );
  }
}

enum _NumpadTokenKind { digit, action }

class _NumpadToken {
  const _NumpadToken._({
    required this.value,
    required this.label,
    required this.kind,
    this.icon,
  });

  const _NumpadToken.digit(String value)
      : this._(
          value: value,
          label: value,
          kind: _NumpadTokenKind.digit,
        );

  const _NumpadToken.action(String value)
      : this._(
          value: value,
          label: value == 'clear' ? 'C' : value,
          icon: value == 'backspace' ? PhosphorIconsRegular.backspace : null,
          kind: _NumpadTokenKind.action,
        );

  final String value;
  final String label;
  final IconData? icon;
  final _NumpadTokenKind kind;
}
