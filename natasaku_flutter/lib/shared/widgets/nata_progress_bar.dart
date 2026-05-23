import 'package:flutter/material.dart';
import '../../core/animations/nata_animations.dart';

/// Progress bar dengan animated fill (500ms ease-in-out) + gradient.
/// Digunakan di hero card, savings progress, category breakdown.
class NataProgressBar extends StatefulWidget {
  const NataProgressBar({
    super.key,
    required this.value,
    this.height = 10,
    this.borderRadius,
    this.gradient,
    this.backgroundColor,
    this.durationMs = 500,
    this.curve = Curves.easeInOut,
  }) : assert(value >= 0.0 && value <= 1.0);

  /// Progress nilai antara 0.0 dan 1.0
  final double value;
  final double height;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final Color? backgroundColor;
  final int durationMs;
  final Curve curve;

  @override
  State<NataProgressBar> createState() => _NataProgressBarState();
}

class _NataProgressBarState extends State<NataProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationMs),
    );
    _animation = Tween<double>(begin: 0, end: widget.value.clamp(0.0, 1.0))
        .animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    _controller.forward();
  }

  @override
  void didUpdateWidget(NataProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final from = _animation.value;
      _animation = Tween<double>(
        begin: from,
        end: widget.value.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    final defaultBg = isDark
        ? colorScheme.surfaceContainerHighest
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);

    final radius = widget.borderRadius ?? BorderRadius.circular(widget.height / 2);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final currentVal = _animation.value;
        
        // Color transition: green (teal) -> amber (secondary) -> rose (error)
        final Color currentProgressColor = currentVal >= 1.0
            ? colorScheme.error
            : currentVal > 0.7
                ? colorScheme.secondary
                : colorScheme.primary;

        final currentGradient = widget.gradient ?? LinearGradient(
          colors: [currentProgressColor.withValues(alpha: 0.8), currentProgressColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );

        return ClipRRect(
          borderRadius: radius,
          child: Container(
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? defaultBg,
              borderRadius: radius,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: currentVal.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: currentGradient,
                  borderRadius: radius,
                  boxShadow: [
                    BoxShadow(
                      color: currentProgressColor.withValues(alpha: 0.30),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Progress bar untuk status overbudget — gradient rose soft
class NataOverBudgetProgressBar extends StatelessWidget {
  const NataOverBudgetProgressBar({
    super.key,
    required this.value,
    this.height = 10,
  });

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return NataProgressBar(
      value: value.clamp(0.0, 1.0),
      height: height,
      gradient: LinearGradient(
        colors: [colorScheme.error.withValues(alpha: 0.8), colorScheme.error],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      backgroundColor: colorScheme.errorContainer.withValues(alpha: 0.4),
    );
  }
}
