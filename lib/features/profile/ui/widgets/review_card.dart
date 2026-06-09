import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/widgets/rating_stars.dart';
import '../../domain/entities/provider_review.dart';

/// Un widget premium para mostrar reseñas con puntuación de estrellas
/// y subcalificaciones opcionales de manera unificada y estética.
class ReviewCard extends StatelessWidget {
  final ProviderReview review;
  final bool showShadow;
  final double padding;
  final double starsSize;

  const ReviewCard({
    super.key,
    required this.review,
    this.showShadow = true,
    this.padding = 16,
    this.starsSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final dateLabel = review.createdAt != null
        ? DateFormat('dd MMM, yyyy', 'es_CO').format(review.createdAt!)
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(showShadow ? 16 : 14),
        border: Border.all(color: AppTheme.border),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.reviewerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              if (dateLabel != null)
                Text(
                  dateLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textTertiary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          RatingStars(rating: review.rating.toDouble(), size: starsSize),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment!,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
          ],
          if (review.hasSubRatings) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _SubRatingsDisplay(review: review),
          ],
        ],
      ),
    );
  }
}

class _SubRatingsDisplay extends StatelessWidget {
  final ProviderReview review;
  const _SubRatingsDisplay({required this.review});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (review.punctualityRating != null)
          _SubRatingRow(
            icon: Icons.schedule_outlined,
            label: 'Puntualidad',
            rating: review.punctualityRating!,
          ),
        if (review.qualityRating != null) ...[
          if (review.punctualityRating != null) const SizedBox(height: 6),
          _SubRatingRow(
            icon: Icons.workspace_premium_outlined,
            label: 'Calidad',
            rating: review.qualityRating!,
          ),
        ],
        if (review.communicationRating != null) ...[
          if (review.punctualityRating != null ||
              review.qualityRating != null)
            const SizedBox(height: 6),
          _SubRatingRow(
            icon: Icons.chat_outlined,
            label: 'Comunicación',
            rating: review.communicationRating!,
          ),
        ],
      ],
    );
  }
}

class _SubRatingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int rating;
  const _SubRatingRow({
    required this.icon,
    required this.label,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.textTertiary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        RatingStars(rating: rating.toDouble(), size: 13),
      ],
    );
  }
}
