import 'package:flutter/material.dart';

/// Shimmer placeholder widget untuk loading state.
/// Menggantikan CircularProgressIndicator di tengah layar.
class NataShimmer extends StatefulWidget {
  const NataShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.margin,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;

  @override
  State<NataShimmer> createState() => _NataShimmerState();
}

class _NataShimmerState extends State<NataShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
    _animation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF232326) : const Color(0xFFEEF0EF);
    final highlight = isDark ? const Color(0xFF2E2E33) : const Color(0xFFF8FAF9);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0.0, 0.5, 1.0],
              colors: [base, highlight, base],
              transform: _GradientShift(_animation.value),
            ),
          ),
        );
      },
    );
  }
}

class _GradientShift implements GradientTransform {
  const _GradientShift(this.value);
  final double value;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * value,
      0.0,
      0.0,
    );
  }
}

/// Widget shimmer untuk Card placeholder (full card loading state)
class NataCardShimmer extends StatelessWidget {
  const NataCardShimmer({super.key, this.height = 140});

  final double height;

  @override
  Widget build(BuildContext context) {
    return NataShimmer(
      width: double.infinity,
      height: height,
      borderRadius: BorderRadius.circular(24),
      margin: const EdgeInsets.only(bottom: 12),
    );
  }
}

/// Widget shimmer untuk list item (TransactionRow placeholder)
class NataListItemShimmer extends StatelessWidget {
  const NataListItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          NataShimmer(
            width: 44,
            height: 44,
            borderRadius: BorderRadius.circular(22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NataShimmer(
                  width: double.infinity,
                  height: 14,
                  borderRadius: BorderRadius.circular(7),
                ),
                const SizedBox(height: 6),
                NataShimmer(
                  width: 120,
                  height: 12,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          NataShimmer(
            width: 72,
            height: 16,
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
    );
  }
}
