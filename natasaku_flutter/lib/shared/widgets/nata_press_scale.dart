import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wrapper yang memberikan press scale animation pada child widget.
/// Scale 0.97 + spring animation 150ms saat pressed.
/// Minimal touch target 48dp.
class NataPressScale extends StatefulWidget {
  const NataPressScale({
    super.key,
    required this.child,
    required this.onTap,
    this.onLongPress,
    this.hapticOnPress = true,
    this.scaleTo = 0.97,
    this.durationMs = 120,
    this.springDurationMs = 200,
    this.enabled = true,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool hapticOnPress;
  final double scaleTo;
  final int durationMs;
  final int springDurationMs;
  final bool enabled;
  final BorderRadius? borderRadius;

  @override
  State<NataPressScale> createState() => _NataPressScaleState();
}

class _NataPressScaleState extends State<NataPressScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationMs),
      reverseDuration: Duration(milliseconds: widget.springDurationMs),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleTo).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (!widget.enabled || widget.onTap == null) return;
    setState(() => _isPressed = true);
    _controller.forward();
    if (widget.hapticOnPress) HapticFeedback.selectionClick();
  }

  void _onTapUp(TapUpDetails _) {
    _release();
  }

  void _onTapCancel() {
    _release();
  }

  void _release() {
    if (!_isPressed) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
