import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Swipeable list row dengan reveal action kiri dan kanan.
/// - Swipe kiri (dari kanan ke kiri) → aksi edit (biru)  
/// - Swipe kanan (dari kiri ke kanan) → aksi hapus (rose soft)
///
/// Delete memicu konfirmasi via bottom sheet, bukan langsung hapus.
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
  });

  final Widget child;
  final VoidCallback? onEdit;
  final Future<void> Function()? onDeleteConfirmed;
  final String deleteConfirmTitle;
  final String deleteConfirmSubtitle;
  final String editLabel;
  final String deleteLabel;

  @override
  State<NataSwipeableRow> createState() => _NataSwipeableRowState();
}

class _NataSwipeableRowState extends State<NataSwipeableRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragOffset = 0;
  bool _isDeleting = false;
  static const double _threshold = 80;
  static const double _maxReveal = 96;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset = (_dragOffset + details.delta.dx).clamp(-_maxReveal, _maxReveal);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragOffset < -_threshold && widget.onEdit != null) {
      // swipe left → reveal edit
      HapticFeedback.selectionClick();
      widget.onEdit!();
    } else if (_dragOffset > _threshold && widget.onDeleteConfirmed != null) {
      // swipe right → show delete confirm
      HapticFeedback.mediumImpact();
      _showDeleteConfirm();
    }
    setState(() => _dragOffset = 0);
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

    return AnimatedOpacity(
      opacity: _isDeleting ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background delete action (swipe right, rose soft)
            if (showDelete)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: revealAmount,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(Icons.delete_outline_rounded,
                        color: Color(0xFFF87171), size: 24),
                  ),
                ),
              ),
            // Background edit action (swipe left, blue)
            if (showEdit)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: revealAmount,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(Icons.edit_outlined,
                        color: Color(0xFF3B82F6), size: 24),
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

/// Delete confirm bottom sheet kecil (tidak fullscreen)
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
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
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
          // Hapus button (rose soft, NOT full red)
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
