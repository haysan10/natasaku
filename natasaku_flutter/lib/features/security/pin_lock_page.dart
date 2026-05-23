import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_colors.dart';
import 'providers/security_provider.dart';

enum PinMode { unlock, setup }

class PinLockPage extends ConsumerStatefulWidget {
  final PinMode mode;
  final VoidCallback? onUnlock;
  
  const PinLockPage({
    super.key, 
    this.mode = PinMode.unlock,
    this.onUnlock,
  });

  @override
  ConsumerState<PinLockPage> createState() => _PinLockPageState();
}

class _PinLockPageState extends ConsumerState<PinLockPage> with SingleTickerProviderStateMixin {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _isError = false;
  
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onNumpadTap(String value) {
    HapticFeedback.lightImpact();
    
    if (_isError) {
      setState(() {
        _isError = false;
        _pin = '';
      });
    }

    if (value == 'back') {
      if (_pin.isNotEmpty) {
        setState(() => _pin = _pin.substring(0, _pin.length - 1));
      }
    } else {
      if (_pin.length < 4) {
        setState(() => _pin += value);
      }
      
      if (_pin.length == 4) {
        _processPin();
      }
    }
  }

  Future<void> _processPin() async {
    // Slight delay to show the 4th dot
    await Future.delayed(const Duration(milliseconds: 150));
    
    if (widget.mode == PinMode.unlock) {
      final success = ref.read(securityProvider.notifier).verifyPin(_pin);
      if (success) {
        HapticFeedback.mediumImpact();
        widget.onUnlock?.call();
      } else {
        _triggerError();
      }
    } else if (widget.mode == PinMode.setup) {
      if (!_isConfirming) {
        // Move to confirm step
        setState(() {
          _confirmPin = _pin;
          _pin = '';
          _isConfirming = true;
        });
      } else {
        if (_pin == _confirmPin) {
          // Success setting PIN
          HapticFeedback.mediumImpact();
          await ref.read(securityProvider.notifier).setPin(_pin);
          if (mounted) Navigator.pop(context);
        } else {
          _triggerError();
        }
      }
    }
  }

  void _triggerError() {
    HapticFeedback.heavyImpact();
    _shakeController.forward(from: 0);
    setState(() => _isError = true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    String title = 'Masukkan PIN';
    String subtitle = 'Buka kunci NataSaku';
    
    if (widget.mode == PinMode.setup) {
      if (_isConfirming) {
        title = 'Konfirmasi PIN';
        subtitle = 'Masukkan kembali PIN Anda';
      } else {
        title = 'Buat PIN Keamanan';
        subtitle = 'PIN digunakan untuk mengamankan data Anda';
      }
    }

    return PopScope(
      canPop: widget.mode == PinMode.setup,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: widget.mode == PinMode.setup 
            ? AppBar(backgroundColor: Colors.transparent, elevation: 0)
            : null,
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              // Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: PhosphorIcon(
                  widget.mode == PinMode.unlock ? PhosphorIconsFill.lockKey : PhosphorIconsFill.shieldCheck,
                  color: AppColors.primary,
                  size: 40,
                ),
              ).animate().scale(curve: Curves.easeOutBack, duration: 600.ms),
              
              const SizedBox(height: 24),
              
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ).animate().fadeIn(delay: 200.ms),
              
              const SizedBox(height: 8),
              
              Text(
                _isError ? 'PIN salah. Coba lagi.' : subtitle,
                style: TextStyle(
                  color: _isError ? AppColors.alert : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  fontSize: 16,
                  fontWeight: _isError ? FontWeight.bold : FontWeight.normal,
                ),
              ).animate().fadeIn(delay: 300.ms),
              
              const SizedBox(height: 40),
              
              // Pin Dots (Animated)
              AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  // Shake calculation
                  final x = _isError ? (30 * (0.5 - (0.5 - _shakeController.value).abs()) * (_shakeController.value * 5 % 2 == 0 ? 1 : -1)) : 0.0;
                  
                  return Transform.translate(
                    offset: Offset(x, 0),
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final isActive = index < _pin.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive 
                            ? (_isError ? AppColors.alert : AppColors.primary)
                            : (isDark ? AppColors.surfaceVariantDark : Colors.grey.shade300),
                        border: isActive 
                            ? null 
                            : Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade400, width: 2),
                      ),
                    );
                  }),
                ),
              ),
              
              const Spacer(flex: 3),
              
              // Numpad Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _PinNumpadBtn('1', onTap: () => _onNumpadTap('1')),
                        _PinNumpadBtn('2', onTap: () => _onNumpadTap('2')),
                        _PinNumpadBtn('3', onTap: () => _onNumpadTap('3')),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _PinNumpadBtn('4', onTap: () => _onNumpadTap('4')),
                        _PinNumpadBtn('5', onTap: () => _onNumpadTap('5')),
                        _PinNumpadBtn('6', onTap: () => _onNumpadTap('6')),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _PinNumpadBtn('7', onTap: () => _onNumpadTap('7')),
                        _PinNumpadBtn('8', onTap: () => _onNumpadTap('8')),
                        _PinNumpadBtn('9', onTap: () => _onNumpadTap('9')),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 80, height: 80), // Empty space
                        _PinNumpadBtn('0', onTap: () => _onNumpadTap('0')),
                        _PinNumpadBtn(
                          '<', 
                          onTap: () => _onNumpadTap('back'), 
                          icon: PhosphorIconsRegular.backspace,
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
              
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinNumpadBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  const _PinNumpadBtn(this.label, {required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 80,
          height: 80,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? AppColors.surfaceVariantDark.withValues(alpha: 0.5) : Colors.white,
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: icon != null
              ? PhosphorIcon(icon!, size: 32, color: isDark ? Colors.white : Colors.black87)
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
        ),
      ),
    );
  }
}
