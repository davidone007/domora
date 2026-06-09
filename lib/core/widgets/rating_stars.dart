import 'package:flutter/material.dart';
import 'package:domora/core/theme/app_theme.dart';

/// Widget reutilizable de estrellas para mostrar o seleccionar un rating.
///
/// - **Modo solo lectura** (default): muestra estrellas llenas, medias y vacías
///   calculadas desde [rating] (0.0 – [starCount]).
/// - **Modo editable**: si [onRatingChanged] no es null, muestra botones
///   interactivos que disparan el callback con el nuevo valor entero.
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.starCount = 5,
    this.size = 18,
    this.color,
    this.onRatingChanged,
  });

  final double rating;
  final int starCount;
  final double size;

  /// Color de las estrellas activas. Por defecto usa [Colors.amber.shade700].
  final Color? color;

  /// Si no es null, el widget se vuelve editable. Recibe el valor entero (1-[starCount]).
  final ValueChanged<int>? onRatingChanged;

  Color get _activeColor => color ?? Colors.amber.shade700;

  @override
  Widget build(BuildContext context) {
    if (onRatingChanged != null) {
      return _EditableStars(
        rating: rating.round().clamp(0, starCount),
        starCount: starCount,
        size: size,
        activeColor: _activeColor,
        inactiveColor: AppTheme.textTertiary,
        onRatingChanged: onRatingChanged!,
      );
    }
    return _ReadonlyStars(
      rating: rating,
      starCount: starCount,
      size: size,
      color: _activeColor,
    );
  }
}

class _ReadonlyStars extends StatelessWidget {
  const _ReadonlyStars({
    required this.rating,
    required this.starCount,
    required this.size,
    required this.color,
  });

  final double rating;
  final int starCount;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fullStars = rating.floor().clamp(0, starCount);
    final hasHalf = (rating - fullStars) >= 0.5 && fullStars < starCount;
    final emptyStars = starCount - fullStars - (hasHalf ? 1 : 0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < fullStars; i++)
          Icon(Icons.star, color: color, size: size),
        if (hasHalf) Icon(Icons.star_half, color: color, size: size),
        for (var i = 0; i < emptyStars; i++)
          Icon(Icons.star_border, color: color, size: size),
      ],
    );
  }
}

class _EditableStars extends StatelessWidget {
  const _EditableStars({
    required this.rating,
    required this.starCount,
    required this.size,
    required this.activeColor,
    required this.inactiveColor,
    required this.onRatingChanged,
  });

  final int rating;
  final int starCount;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final ValueChanged<int> onRatingChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        final selected = index < rating;
        return IconButton(
          onPressed: () => onRatingChanged(index + 1),
          padding: const EdgeInsets.all(8),
          iconSize: size,
          tooltip: '${index + 1} estrella${index == 0 ? '' : 's'}',
          icon: Icon(
            selected ? Icons.star : Icons.star_border,
            color: selected ? activeColor : inactiveColor,
          ),
        );
      }),
    );
  }
}
