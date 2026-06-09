import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/widgets/rating_stars.dart';
import 'package:domora/features/profile/ui/widgets/review_card.dart';
import '../bloc/client_public_profile_bloc.dart';

class ClientPublicProfileScreen extends StatefulWidget {
  final String userId;

  const ClientPublicProfileScreen({super.key, required this.userId});

  @override
  State<ClientPublicProfileScreen> createState() =>
      _ClientPublicProfileScreenState();
}

class _ClientPublicProfileScreenState
    extends State<ClientPublicProfileScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<ClientPublicProfileBloc>()
        .add(FetchClientPublicProfileEvent(widget.userId));
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
      body: BlocBuilder<ClientPublicProfileBloc, ClientPublicProfileState>(
        builder: (context, state) {
          if (state.status == ClientPublicProfileStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ClientPublicProfileStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: AppTheme.error),
                  const SizedBox(height: 16),
                  Text(state.errorMessage ?? 'Error al cargar perfil'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context
                        .read<ClientPublicProfileBloc>()
                        .add(FetchClientPublicProfileEvent(widget.userId)),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state.status == ClientPublicProfileStatus.success &&
              state.profile != null) {
            final profile = state.profile!;
            final user = profile.user;
            final client = profile.clientProfile;
            final stats = profile.stats;

            return SingleChildScrollView(
              child: Column(
                children: [
                  _ClientProfileHeader(
                    fullName: user.fullName,
                    avatarUrl: client?.avatarUrl,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rating card
                        _RatingCard(
                          averageRating: stats?.averageRating ?? 0.0,
                          totalReviews: stats?.totalReviewsCount ?? 0,
                        ),
                        const SizedBox(height: 32),

                        // Bio (si existe)
                        if (client?.bio != null &&
                            client!.bio!.isNotEmpty) ...[
                          _SectionTitle(title: 'Sobre mí'),
                          const SizedBox(height: 12),
                          Text(
                            client.bio!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],

                        // Reseñas recibidas
                        _SectionTitle(title: 'Calificaciones recibidas'),
                        const SizedBox(height: 4),
                        Text(
                          'Opiniones de proveedores que han trabajado con este cliente.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (profile.reviews.isEmpty)
                          const _PlaceholderInfo(
                            icon: Icons.rate_review_outlined,
                            text: 'Este cliente aún no tiene calificaciones.',
                          )
                        else
                          Column(
                            children: profile.reviews
                                .map((review) => ReviewCard(review: review))
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

// ─── Widgets privados ────────────────────────────────────────────────────────

class _ClientProfileHeader extends StatelessWidget {
  final String fullName;
  final String? avatarUrl;

  const _ClientProfileHeader({required this.fullName, this.avatarUrl});

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
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 56,
              backgroundColor: AppTheme.background,
              backgroundImage:
                  avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null
                  ? const Icon(Icons.person, size: 50, color: AppTheme.primary)
                  : null,
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
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade600,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'CLIENTE',
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

class _RatingCard extends StatelessWidget {
  final double averageRating;
  final int totalReviews;

  const _RatingCard({
    required this.averageRating,
    required this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    final hasRating = totalReviews > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Icon(Icons.star_outline,
                  color: Colors.amber, size: 28),
              const SizedBox(height: 4),
              Text(
                hasRating ? averageRating.toStringAsFixed(1) : 'N/A',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Text(
                'Promedio',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ),
          Container(height: 40, width: 1, color: AppTheme.border),
          Column(
            children: [
              if (hasRating) ...[
                RatingStars(
                  rating: averageRating,
                  size: 20,
                ),
                const SizedBox(height: 4),
              ],
              Text(
                '$totalReviews reseñas',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Text(
                'de proveedores',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 48, color: AppTheme.textTertiary),
            const SizedBox(height: 12),
            Text(
              text,
              style: const TextStyle(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
