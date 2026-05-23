import 'package:flutter/material.dart';

/// Animated counter yang menghitung dari 0 ke nilai target (count-up).
/// Digunakan untuk hero card nominal — 300ms ease-out sesuai spec.
class NataAnimatedCounter extends StatefulWidget {
  const NataAnimatedCounter({
    super.key,
    required this.value,
    required this.formatter,
    this.style,
    this.durationMs = 300,
    this.curve = Curves.easeOut,
    this.animate = true,
  });

  final double value;
  final String Function(double) formatter;
  final TextStyle? style;
  final int durationMs;
  final Curve curve;
  final bool animate;

  @override
  State<NataAnimatedCounter> createState() => _NataAnimatedCounterState();
}

class _NataAnimatedCounterState extends State<NataAnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationMs),
    );
    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(NataAnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = _animation.value;
      _animation = Tween<double>(
        begin: _previousValue,
        end: widget.value,
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Text(
          widget.formatter(_animation.value),
          style: widget.style ?? Theme.of(context).textTheme.headlineLarge,
        );
      },
    );
  }
}
