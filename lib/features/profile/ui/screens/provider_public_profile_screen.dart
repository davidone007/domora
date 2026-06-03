import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/features/profile/domain/entities/provider_review.dart';
import '../bloc/provider_public_profile_bloc.dart';

class ProviderPublicProfileScreen extends StatefulWidget {
  final String userId;

  const ProviderPublicProfileScreen({super.key, required this.userId});

  @override
  State<ProviderPublicProfileScreen> createState() => _ProviderPublicProfileScreenState();
}

class _ProviderPublicProfileScreenState extends State<ProviderPublicProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProviderPublicProfileBloc>().add(FetchProviderPublicProfileEvent(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: BlocBuilder<ProviderPublicProfileBloc, ProviderPublicProfileState>(
        builder: (context, state) {
          if (state.status == ProviderPublicProfileStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ProviderPublicProfileStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
                  const SizedBox(height: 16),
                  Text(state.errorMessage ?? 'Error al cargar perfil'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context
                        .read<ProviderPublicProfileBloc>()
                        .add(FetchProviderPublicProfileEvent(widget.userId)),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state.status == ProviderPublicProfileStatus.success && state.profile != null) {
            final profile = state.profile!;
            final provider = profile.providerProfile!;
            final user = profile.user;
            final stats = profile.stats;

            return SingleChildScrollView(
              child: Column(
                children: [
                  _ProfileHeader(
                    fullName: user.fullName,
                    avatarUrl: provider.avatarUrl,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StatsRow(
                          hourlyRate: provider.hourlyRate,
                          yearsExperience: provider.yearsExperience,
                          averageRating: stats?.averageRating ?? 0.0,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Sobre mí',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          provider.bio ?? 'El proveedor aún no ha agregado una biografía.',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        if (provider.coverageCities.isNotEmpty) ...[
                          _SectionTitle(title: 'Zonas de atención'),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: provider.coverageCities
                                .map(
                                  (city) => Chip(
                                    label: Text(city),
                                    backgroundColor: AppTheme.primarySoft,
                                    labelStyle: const TextStyle(
                                      color: AppTheme.primaryDark,
                                      fontSize: 13,
                                    ),
                                    side: BorderSide.none,
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 32),
                        ],
                        _SectionTitle(title: 'Servicios Completados'),
                        _StatHighlightCard(
                          icon: Icons.check_circle_outline,
                          iconColor: AppTheme.primary,
                          title: 'Servicios realizados',
                          value: '${stats?.completedServicesCount ?? 0}',
                          subtitle: stats != null && stats.completedServicesCount > 0
                              ? 'Clientes satisfechos y trabajos finalizados.'
                              : 'Aun no registra servicios completados.',
                        ),
                        const SizedBox(height: 24),
                        _SectionTitle(title: 'Calificaciones'),
                        Row(
                          children: [
                            Expanded(
                              child: _StatHighlightCard(
                                icon: Icons.star_outline,
                                iconColor: Colors.amber.shade700,
                                title: 'Promedio',
                                value: stats != null && stats.totalReviewsCount > 0
                                    ? stats.averageRating.toStringAsFixed(1)
                                    : 'N/A',
                                subtitle: 'de 5.0',
                                compact: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatHighlightCard(
                                icon: Icons.rate_review_outlined,
                                iconColor: AppTheme.primary,
                                title: 'Reseñas',
                                value: '${stats?.totalReviewsCount ?? 0}',
                                subtitle: 'opiniones registradas',
                                compact: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _RatingStrip(
                          rating: stats?.averageRating ?? 0.0,
                          totalReviews: stats?.totalReviewsCount ?? 0,
                        ),
                        const SizedBox(height: 20),
                        _SectionTitle(title: 'Reseñas'),
                        if (profile.reviews.isEmpty)
                          const _PlaceholderInfo(
                            icon: Icons.rate_review_outlined,
                            text: 'Aun no hay reseñas registradas.',
                          )
                        else
                          Column(
                            children: profile.reviews
                                .map((review) => _ReviewCard(review: review))
                                .toList(),
                          ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String fullName;
  final String? avatarUrl;

  const _ProfileHeader({required this.fullName, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 100, bottom: 40),
      decoration: const BoxDecoration(
        color: AppTheme.primarySoft,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Hero(
            tag: 'provider_avatar_$fullName',
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 56,
                backgroundColor: AppTheme.background,
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                child: avatarUrl == null
                    ? const Icon(Icons.person, size: 50, color: AppTheme.primary)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'PROVEEDOR VERIFICADO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final double hourlyRate;
  final int yearsExperience;
  final double averageRating;

  const _StatsRow({
    required this.hourlyRate,
    required this.yearsExperience,
    required this.averageRating,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            label: 'Tarifa/h',
            value: currencyFormat.format(hourlyRate),
            icon: Icons.payments_outlined,
          ),
          Container(height: 30, width: 1, color: AppTheme.border),
          _StatItem(
            label: 'Experiencia',
            value: '$yearsExperience años',
            icon: Icons.work_outline,
          ),
          Container(height: 30, width: 1, color: AppTheme.border),
          _StatItem(
            label: 'Rating',
            value: averageRating > 0 ? averageRating.toStringAsFixed(1) : 'N/A',
            icon: Icons.star_outline,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primary, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textTertiary),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _PlaceholderInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PlaceholderInfo({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textTertiary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class _StatHighlightCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;
  final bool compact;

  const _StatHighlightCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardPadding = compact ? const EdgeInsets.all(14) : const EdgeInsets.all(18);
    return Container(
      padding: cardPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingStrip extends StatelessWidget {
  final double rating;
  final int totalReviews;

  const _RatingStrip({required this.rating, required this.totalReviews});

  @override
  Widget build(BuildContext context) {
    final normalized = rating.clamp(0, 5) / 5;
    final percent = (normalized * 100).round();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primarySoft.withOpacity(0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          _StarRow(rating: rating),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  totalReviews > 0
                      ? '$percent% de satisfaccion'
                      : 'Sin calificaciones registradas',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: totalReviews > 0 ? normalized : 0,
                    minHeight: 6,
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  final double rating;

  const _StarRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    final fullStars = rating.floor().clamp(0, 5);
    final hasHalf = rating - fullStars >= 0.5 && fullStars < 5;
    final emptyStars = 5 - fullStars - (hasHalf ? 1 : 0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < fullStars; i++)
          Icon(Icons.star, color: Colors.amber.shade700, size: 18),
        if (hasHalf)
          Icon(Icons.star_half, color: Colors.amber.shade700, size: 18),
        for (var i = 0; i < emptyStars; i++)
          Icon(Icons.star_border, color: Colors.amber.shade700, size: 18),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ProviderReview review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final dateLabel = review.createdAt != null
        ? DateFormat('dd MMM, yyyy', 'es_CO').format(review.createdAt!)
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
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
          _StarRow(rating: review.rating.toDouble()),
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
        ],
      ),
    );
  }
}
