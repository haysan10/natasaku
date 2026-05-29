import 'dart:io';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Full-screen photo viewer with pinch-to-zoom for receipt/note photos.
class PhotoViewerPage extends StatelessWidget {
  const PhotoViewerPage({
    super.key,
    required this.photoPath,
    this.onDelete,
  });

  final String photoPath;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Foto Struk'),
        actions: [
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.alert),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Hapus Foto?'),
                    content: const Text(
                      'Foto struk ini akan dihapus secara permanen.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Batal'),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.alert,
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          onDelete!();
                          Navigator.pop(context);
                        },
                        child: const Text('Hapus'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: File(photoPath).existsSync()
              ? Image.file(
                  File(photoPath),
                  fit: BoxFit.contain,
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.broken_image_outlined,
                      size: 64,
                      color: Colors.grey.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Foto tidak ditemukan',
                      style: TextStyle(
                        color: Colors.grey.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
