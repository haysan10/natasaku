import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

/// Model untuk satu langkah tour
class TourStep {
  const TourStep({
    required this.targetKey,
    required this.tooltipTitle,
    required this.tooltipBody,
    required this.actionLabel,
    this.overlayPadding = 8.0,
    this.isCircle = false,
    this.targetRoute,
  });

  final GlobalKey targetKey;
  final String tooltipTitle;
  final String tooltipBody;
  final String actionLabel;
  final double overlayPadding;
  final bool isCircle;
  final String? targetRoute;
}

/// Feature Tour Overlay — spotlight overlay reusable.
///
/// Digunakan sebagai overlay di atas seluruh app setelah setup pertama.
/// Menampilkan lubang terang di area target, tooltip bubble, dan tombol aksi.
class FeatureTourOverlay extends StatefulWidget {
  const FeatureTourOverlay({
    super.key,
    required this.steps,
    required this.onComplete,
    required this.child,
    this.showTour = true,
    this.onNavigate,
  });

  final List<TourStep> steps;
  final VoidCallback onComplete;
  final Widget child;
  final bool showTour;
  final Future<void> Function(String route)? onNavigate;

  @override
  State<FeatureTourOverlay> createState() => _FeatureTourOverlayState();
}

class _FeatureTourOverlayState extends State<FeatureTourOverlay>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  bool _visible = false;
  Rect? _targetRect;

  late AnimationController _fadeController;
  late AnimationController _spotlightController;
  late AnimationController _tooltipController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _spotlightAnimation;
  late Animation<double> _tooltipAnimation;
  late Animation<Offset> _tooltipSlide;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _spotlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _tooltipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _spotlightAnimation = CurvedAnimation(
      parent: _spotlightController,
      curve: Curves.easeOutBack,
    );
    _tooltipAnimation = CurvedAnimation(
      parent: _tooltipController,
      curve: Curves.easeOut,
    );
    _tooltipSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(_tooltipAnimation);

    if (widget.showTour) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startTour());
    }
  }

  @override
  void didUpdateWidget(FeatureTourOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showTour && !oldWidget.showTour) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startTour());
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _spotlightController.dispose();
    _tooltipController.dispose();
    super.dispose();
  }

  Future<void> _startTour() async {
    if (!mounted) return;
    
    if (widget.steps.isNotEmpty) {
      final firstStep = widget.steps.first;
      if (firstStep.targetRoute != null && widget.onNavigate != null) {
        await widget.onNavigate!(firstStep.targetRoute!);
      }
    }
    
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    _updateTargetRect();
    setState(() => _visible = true);
    await _fadeController.forward();
    await _spotlightController.forward();
    await _tooltipController.forward();
  }

  void _updateTargetRect() {
    if (_currentStep >= widget.steps.length) return;
    final step = widget.steps[_currentStep];
    final context = step.targetKey.currentContext;
    if (context == null) return;

    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final position = box.localToGlobal(Offset.zero);
    final size = box.size;
    final padding = step.overlayPadding;

    setState(() {
      _targetRect = Rect.fromLTWH(
        position.dx - padding,
        position.dy - padding,
        size.width + padding * 2,
        size.height + padding * 2,
      );
    });
  }

  Future<void> _nextStep() async {
    HapticFeedback.lightImpact();

    if (_currentStep >= widget.steps.length - 1) {
      await _dismiss();
      return;
    }

    // Animate out tooltip
    await _tooltipController.reverse();
    await _spotlightController.reverse();

    setState(() => _currentStep++);
    
    final nextStep = widget.steps[_currentStep];
    if (nextStep.targetRoute != null && widget.onNavigate != null) {
      await widget.onNavigate!(nextStep.targetRoute!);
      // wait for page transition
      await Future.delayed(const Duration(milliseconds: 600));
    }
    
    if (!mounted) return;
    _updateTargetRect();

    // Animate in new spotlight + tooltip
    await _spotlightController.forward();
    await _tooltipController.forward();
  }

  Future<void> _skip() async {
    HapticFeedback.selectionClick();
    await _dismiss();
  }

  Future<void> _dismiss() async {
    await Future.wait([
      _tooltipController.reverse(),
      _spotlightController.reverse(),
    ]);
    await _fadeController.reverse();
    if (mounted) {
      setState(() {
        _visible = false;
        _currentStep = 0;
      });
    }
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return widget.child;

    final step = _currentStep < widget.steps.length
        ? widget.steps[_currentStep]
        : null;

    return Stack(
      children: [
        widget.child,
        // Dark overlay with spotlight hole
        if (_visible && step != null)
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, _) => GestureDetector(
              onTap: _nextStep,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: _SpotlightPainter(
                    targetRect: _targetRect,
                    spotlightProgress: _spotlightAnimation.value,
                    cornerRadius: 16,
                    isCircle: step.isCircle,
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Stack(
                      children: [
                        // Skip button
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 16,
                          right: 20,
                          child: SafeArea(
                            child: TextButton(
                              onPressed: _skip,
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white70,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                              ),
                              child: const Text(
                                'Lewati',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),

                        // Step indicator
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 16,
                          left: 20,
                          child: SafeArea(
                            child: Text(
                              '${_currentStep + 1} / ${widget.steps.length}',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        // Tooltip bubble
                        if (_targetRect != null)
                          _buildPositionedTooltip(
                            context: context,
                            step: step,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPositionedTooltip({
    required BuildContext context,
    required TourStep step,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final safeAreaTop = MediaQuery.of(context).padding.top;
    
    // Compute position
    final targetRect = _targetRect!;
    const bubbleWidth = 280.0;
    const bubbleEstHeight = 160.0;
    
    final centerX = targetRect.center.dx;
    final targetBottom = targetRect.bottom;
    final targetTop = targetRect.top;

    double left = centerX - bubbleWidth / 2;
    left = left.clamp(16.0, screenSize.width - bubbleWidth - 16);

    double top;
    bool arrowAtTop = true;
    if (targetBottom + bubbleEstHeight + 24 < screenSize.height - 80) {
      // Below target
      top = targetBottom + 20;
      arrowAtTop = true;
    } else if (targetTop - bubbleEstHeight - 24 > safeAreaTop + 60) {
      // Above target
      top = targetTop - bubbleEstHeight - 20;
      arrowAtTop = false;
    } else {
      // Center of screen fallback
      top = screenSize.height * 0.55;
      arrowAtTop = true;
    }

    final arrowX = centerX - left;

    return Positioned(
      left: left,
      top: top,
      width: bubbleWidth,
      child: AnimatedBuilder(
        animation: _tooltipAnimation,
        builder: (context, _) => SlideTransition(
          position: _tooltipSlide,
          child: FadeTransition(
            opacity: _tooltipAnimation,
            child: _TooltipBubble(
              step: step,
              currentStep: _currentStep,
              totalSteps: widget.steps.length,
              onAction: _nextStep,
              arrowX: arrowX,
              arrowAtTop: arrowAtTop,
            ),
          ),
        ),
      ),
    );
  }
}

/// Tooltip bubble yang menampilkan judul, body, tombol aksi
class _TooltipBubble extends StatelessWidget {
  const _TooltipBubble({
    required this.step,
    required this.currentStep,
    required this.totalSteps,
    required this.onAction,
    required this.arrowX,
    required this.arrowAtTop,
  });

  final TourStep step;
  final int currentStep;
  final int totalSteps;
  final VoidCallback onAction;
  final double arrowX;
  final bool arrowAtTop;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppColors.surfaceDark : Colors.white;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final titleColor = isDark ? AppColors.textPrimaryDark : const Color(0xFF1A2421);
    final bodyColor = isDark ? AppColors.textSecondaryDark : const Color(0xFF6B7E78);

    const caretHeight = 10.0;

    return CustomPaint(
      painter: BubblePainter(
        isDark: isDark,
        arrowX: arrowX,
        arrowAtTop: arrowAtTop,
        bgColor: cardBgColor,
        borderColor: borderColor,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: arrowAtTop ? 20 + caretHeight : 20,
          bottom: arrowAtTop ? 20 : 20 + caretHeight,
          left: 20,
          right: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Step dots
            Row(
              children: List.generate(totalSteps, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: i == currentStep ? 20 : 6,
                  height: 6,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: i == currentStep
                        ? AppColors.primary
                        : (isDark ? Colors.white12 : const Color(0xFFDDE7E3)),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Text(
              step.tooltipTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: titleColor,
                letterSpacing: 0,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              step.tooltipBody,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: bodyColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  step.actionLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.white,
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

/// CustomPainter untuk menggambar gelembung tooltip beserta caret penunjuk
class BubblePainter extends CustomPainter {
  BubblePainter({
    required this.isDark,
    required this.arrowX,
    required this.arrowAtTop,
    required this.bgColor,
    required this.borderColor,
  });

  final bool isDark;
  final double arrowX;
  final bool arrowAtTop;
  final Color bgColor;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    const caretWidth = 16.0;
    const caretHeight = 10.0;
    const radius = 20.0;

    final path = Path();
    
    final double boxTop = arrowAtTop ? caretHeight : 0.0;
    final double boxBottom = arrowAtTop ? size.height : size.height - caretHeight;
    const boxLeft = 0.0;
    final double boxRight = size.width;

    final clampedArrowX = arrowX.clamp(radius + caretWidth / 2, size.width - radius - caretWidth / 2);

    path.moveTo(boxLeft + radius, boxTop);

    if (arrowAtTop) {
      path.lineTo(clampedArrowX - caretWidth / 2, boxTop);
      path.lineTo(clampedArrowX, 0.0);
      path.lineTo(clampedArrowX + caretWidth / 2, boxTop);
    }
    
    path.lineTo(boxRight - radius, boxTop);
    path.arcToPoint(
      Offset(boxRight, boxTop + radius),
      radius: const Radius.circular(radius),
    );

    path.lineTo(boxRight, boxBottom - radius);
    path.arcToPoint(
      Offset(boxRight - radius, boxBottom),
      radius: const Radius.circular(radius),
    );

    if (!arrowAtTop) {
      path.lineTo(clampedArrowX + caretWidth / 2, boxBottom);
      path.lineTo(clampedArrowX, size.height);
      path.lineTo(clampedArrowX - caretWidth / 2, boxBottom);
    }

    path.lineTo(boxLeft + radius, boxBottom);
    path.arcToPoint(
      Offset(boxLeft, boxBottom - radius),
      radius: const Radius.circular(radius),
    );

    path.lineTo(boxLeft, boxTop + radius);
    path.arcToPoint(
      Offset(boxLeft + radius, boxTop),
      radius: const Radius.circular(radius),
    );
    
    path.close();

    // 1. Draw Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: isDark ? 0.35 : 0.16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    
    canvas.save();
    canvas.translate(0, 8);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // 2. Draw Background
    final fillPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // 3. Draw Border stroke
    final strokePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant BubblePainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.arrowX != arrowX ||
        oldDelegate.arrowAtTop != arrowAtTop ||
        oldDelegate.bgColor != bgColor ||
        oldDelegate.borderColor != borderColor;
  }
}

/// Custom painter untuk overlay gelap dengan lubang terang di target
class _SpotlightPainter extends CustomPainter {
  const _SpotlightPainter({
    required this.targetRect,
    required this.spotlightProgress,
    required this.cornerRadius,
    required this.isCircle,
  });

  final Rect? targetRect;
  final double spotlightProgress;
  final double cornerRadius;
  final bool isCircle;

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.black.withValues(alpha: 0.65);

    if (targetRect == null || spotlightProgress == 0) {
      canvas.drawRect(Offset.zero & size, overlayPaint);
      return;
    }

    // Scale spotlight from center
    Rect scaledRect = _scaleRect(targetRect!, spotlightProgress);

    if (isCircle) {
      final center = scaledRect.center;
      final diameter = math.min(scaledRect.width, scaledRect.height);
      scaledRect = Rect.fromCenter(
        center: center,
        width: diameter,
        height: diameter,
      );
    }

    // Re-draw overlay with hole using even-odd fill
    final holePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;

    final outerPath = Path()..addRect(Offset.zero & size);
    final innerPath = Path();
    if (isCircle) {
      innerPath.addOval(scaledRect);
    } else {
      innerPath.addRRect(
        RRect.fromRectAndRadius(
          scaledRect,
          Radius.circular(cornerRadius * spotlightProgress),
        ),
      );
    }

    final combined = Path.combine(PathOperation.difference, outerPath, innerPath);
    canvas.drawPath(combined, holePaint);

    // Soft glow ring around spotlight
    final glowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.15 * spotlightProgress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    // Sharp accent border ring around spotlight
    final borderPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.8 * spotlightProgress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    if (isCircle) {
      canvas.drawOval(scaledRect.inflate(3), glowPaint);
      canvas.drawOval(scaledRect, borderPaint);
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          scaledRect.inflate(3),
          Radius.circular(cornerRadius * spotlightProgress),
        ),
        glowPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          scaledRect,
          Radius.circular(cornerRadius * spotlightProgress),
        ),
        borderPaint,
      );
    }
  }

  Rect _scaleRect(Rect original, double progress) {
    final center = original.center;
    final halfWidth = original.width / 2 * math.max(progress, 0.01);
    final halfHeight = original.height / 2 * math.max(progress, 0.01);
    return Rect.fromCenter(
      center: center,
      width: halfWidth * 2,
      height: halfHeight * 2,
    );
  }

  @override
  bool shouldRepaint(_SpotlightPainter oldDelegate) =>
      oldDelegate.targetRect != targetRect ||
      oldDelegate.spotlightProgress != spotlightProgress ||
      oldDelegate.isCircle != isCircle;
}
