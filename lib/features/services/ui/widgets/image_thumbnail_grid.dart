import 'package:flutter/material.dart';
import 'package:domora/core/entities/avatar_file.dart';
import 'package:domora/core/theme/app_theme.dart';

class ImageThumbnailGrid extends StatelessWidget {
  final List<AvatarFile> images;
  final int primaryIndex;
  final Function(int) onRemove;
  final Function(int) onSetPrimary;

  const ImageThumbnailGrid({
    super.key,
    required this.images,
    required this.primaryIndex,
    required this.onRemove,
    required this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final isPrimary = index == primaryIndex;
        return Stack(
          children: [
            // Imagen
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isPrimary ? AppTheme.primary : AppTheme.border,
                    width: isPrimary ? 2 : 1,
                  ),
                  image: DecorationImage(
                    image: MemoryImage(images[index].bytes),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            
            // Botón eliminar
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => onRemove(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),

            // Marcador de Principal
            if (isPrimary)
              Positioned(
                bottom: 4,
                left: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'PRINCIPAL',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              )
            else
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: () => onSetPrimary(index),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
