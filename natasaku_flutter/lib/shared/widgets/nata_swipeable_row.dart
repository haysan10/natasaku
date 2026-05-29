import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Swipeable list row with spring animation and gradient reveal actions.
/// - Swipe left (right to left) → edit action (blue gradient)
/// - Swipe right (left to right) → delete action (rose gradient)
///
/// Delete triggers confirmation via bottom sheet.
class NataSwipeableRow extends StatefulWidget {
  const NataSwipeableRow({
    super.key,
    required this.child,
    this.onEdit,
    this.onDeleteConfirmed,
    this.deleteConfirmTitle = 'Hapus transaksi ini?',
    this.deleteConfirmSubtitle = 'Tindakan ini tidak bisa dibatalkan.',
    this.editLabel = 'Edit',
    this.deleteLabel = 'Hapus',
    this.undoLabel,
  });

  final Widget child;
  final VoidCallback? onEdit;
  final Future<void> Function()? onDeleteConfirmed;
  final String deleteConfirmTitle;
  final String deleteConfirmSubtitle;
  final String editLabel;
  final String deleteLabel;

  /// If set, an undo snackbar is shown after delete with this label.
  final String? undoLabel;

  @override
  State<NataSwipeableRow> createState() => _NataSwipeableRowState();
}

class _NataSwipeableRowState extends State<NataSwipeableRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _dragOffset = 0;
  bool _isDeleting = false;
  bool _hasTriggeredHaptic = false;
  static const double _threshold = 80;
  static const double _maxReveal = 96;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset =
          (_dragOffset + details.delta.dx).clamp(-_maxReveal, _maxReveal);
    });

    // Haptic feedback at threshold
    if (!_hasTriggeredHaptic && _dragOffset.abs() > _threshold) {
      _hasTriggeredHaptic = true;
      HapticFeedback.selectionClick();
    } else if (_dragOffset.abs() <= _threshold) {
      _hasTriggeredHaptic = false;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragOffset < -_threshold && widget.onEdit != null) {
      HapticFeedback.selectionClick();
      widget.onEdit!();
    } else if (_dragOffset > _threshold && widget.onDeleteConfirmed != null) {
      HapticFeedback.mediumImpact();
      _showDeleteConfirm();
    }

    // Spring animation back to zero
    _animation = Tween<double>(begin: _dragOffset, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward(from: 0);
    _animation.addListener(() {
      if (mounted) setState(() => _dragOffset = _animation.value);
    });
  }

  Future<void> _showDeleteConfirm() async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DeleteConfirmSheet(
        title: widget.deleteConfirmTitle,
        subtitle: widget.deleteConfirmSubtitle,
      ),
    );
    if (confirmed == true && widget.onDeleteConfirmed != null && mounted) {
      setState(() => _isDeleting = true);
      await widget.onDeleteConfirmed!();
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showDelete = _dragOffset > 0;
    final showEdit = _dragOffset < 0;
    final revealAmount = _dragOffset.abs();
    final progress = (revealAmount / _threshold).clamp(0.0, 1.0);

    return AnimatedOpacity(
      opacity: _isDeleting ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background delete action (swipe right, rose gradient)
            if (showDelete)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: revealAmount,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        const Color(0xFFF87171).withValues(alpha: 0.05 + progress * 0.25),
                        const Color(0xFFFEE2E2).withValues(alpha: 0.3 + progress * 0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: AnimatedScale(
                      scale: 0.7 + progress * 0.3,
                      duration: const Duration(milliseconds: 100),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: Color.lerp(
                          const Color(0xFFF87171).withValues(alpha: 0.4),
                          const Color(0xFFF87171),
                          progress,
                        ),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            // Background edit action (swipe left, blue gradient)
            if (showEdit)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: revealAmount,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        const Color(0xFF3B82F6).withValues(alpha: 0.05 + progress * 0.2),
                        const Color(0xFFDBEAFE).withValues(alpha: 0.3 + progress * 0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: AnimatedScale(
                      scale: 0.7 + progress * 0.3,
                      duration: const Duration(milliseconds: 100),
                      child: Icon(
                        Icons.edit_outlined,
                        color: Color.lerp(
                          const Color(0xFF3B82F6).withValues(alpha: 0.4),
                          const Color(0xFF3B82F6),
                          progress,
                        ),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            // Main content with offset
            AnimatedContainer(
              duration: const Duration(milliseconds: 60),
              transform: Matrix4.translationValues(_dragOffset, 0, 0),
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}

/// Delete confirm bottom sheet (compact, not fullscreen)
class _DeleteConfirmSheet extends StatelessWidget {
  const _DeleteConfirmSheet({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161618) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFF87171),
              size: 28,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          // Delete button (rose soft, NOT full red)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF87171),
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Hapus'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Batal'),
            ),
          ),
        ],
      ),
    );
  }
}
