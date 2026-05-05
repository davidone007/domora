import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:domora/core/entities/avatar_file.dart';

/// Selector circular de avatar. Permite tomar una foto o elegir de la galería.
/// Devuelve la ruta del archivo seleccionado mediante [onChanged].
class AvatarPicker extends StatelessWidget {
  final AvatarFile? image;
  final String? imageUrl;
  final ValueChanged<AvatarFile?> onChanged;
  final double size;

  const AvatarPicker({
    super.key,
    required this.image,
    required this.onChanged,
    this.imageUrl,
    this.size = 110,
  });

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(ctx).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tomar una foto'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            if (image != null || (imageUrl != null && imageUrl!.isNotEmpty))
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Quitar foto',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  onChanged(null);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null) return;
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (picked != null) {
      try {
        final bytes = await picked.readAsBytes();
        final name = (picked.name.isNotEmpty) ? picked.name : picked.path.split('/').last;
        onChanged(AvatarFile(filename: name, bytes: bytes));
      } catch (e) {
        // Fallback: notify null if reading fails
        onChanged(null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFile = image != null;
    final hasUrl = imageUrl != null && imageUrl!.isNotEmpty;

    return Center(
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.25),
                width: 1.4,
              ),
              image: hasFile
                  ? DecorationImage(
                      image: MemoryImage(image!.bytes),
                      fit: BoxFit.cover,
                    )
                  : hasUrl
                      ? DecorationImage(
                          image: NetworkImage(imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
            ),
            child: (!hasFile && !hasUrl)
                ? Icon(
                    Icons.person_outline,
                    size: size * 0.5,
                    color: theme.colorScheme.primary,
                  )
                : null,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Material(
              color: theme.colorScheme.primary,
              shape: const CircleBorder(),
              elevation: 2,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _pickImage(context),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.camera_alt_outlined,
                      size: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
