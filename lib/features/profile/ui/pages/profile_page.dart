import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/utils/constants.dart';
import 'package:domora/core/widgets/main_shell.dart';
import 'package:domora/core/widgets/rating_stars.dart';
import 'package:domora/features/profile/domain/entities/full_profile.dart';
import 'package:domora/features/profile/domain/entities/provider_review.dart';
import 'package:domora/features/profile/ui/bloc/profile_bloc.dart';
import 'package:domora/features/profile/ui/bloc/profile_signout_bloc.dart';
import 'package:domora/features/profile/ui/widgets/review_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const ProfileLoadEvent());
  }

  /// Decide a qué dashboard regresar según el rol cargado.
  void _goToHome() {
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoadedState) {
      final route = state.profile.isProvider
          ? AppConstants.routeProviderHome
          : AppConstants.routeClientHome;
      context.go(route);
    } else {
      // Fallback: home de cliente si aún no hemos cargado el perfil.
      context.go(AppConstants.routeClientHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileSignOutBloc, ProfileSignOutState>(
      listener: (context, state) {
        if (state is ProfileSignOutFailState) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is ProfileSignOutSuccessState) {
          context.go(AppConstants.routeLogin);
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          String? currentRole;
          if (state is ProfileLoadedState) {
            currentRole = state.profile.role;
          } else if (state is ProfileTogglingAvailabilityState) {
            currentRole = state.profile.role;
          }

          return MainShell(
            activeTab: MainTab.profile,
            role: currentRole,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // AppBar manual (no usamos Scaffold.appBar porque el MainShell ya
                  // posee el Scaffold raíz; añadir otro daría doble AppBar).
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _goToHome,
                          icon: const Icon(Icons.arrow_back, size: 22),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'Mi perfil',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ),
                        BlocBuilder<ProfileSignOutBloc, ProfileSignOutState>(
                          builder: (context, signOutState) {
                            final isLoading =
                                signOutState is ProfileSignOutLoadingState;
                            return IconButton(
                              tooltip: 'Cerrar sesión',
                              onPressed: isLoading
                                  ? null
                                  : () => context
                                      .read<ProfileSignOutBloc>()
                                      .add(const ProfileSignOutSubmitEvent()),
                              icon: const Icon(Icons.logout, size: 22),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (state is ProfileLoadingState ||
                            state is ProfileInitialState) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (state is ProfileErrorState) {
                          return _ErrorView(
                            message: state.message,
                            onRetry: () => context
                                .read<ProfileBloc>()
                                .add(const ProfileRefreshEvent()),
                          );
                        }
                        if (state is ProfileLoadedState) {
                          return RefreshIndicator(
                            onRefresh: () async => context
                                .read<ProfileBloc>()
                                .add(const ProfileRefreshEvent()),
                            child: _ProfileContent(profile: state.profile),
                          );
                        }
                        if (state is ProfileTogglingAvailabilityState) {
                          return RefreshIndicator(
                            onRefresh: () async => context
                                .read<ProfileBloc>()
                                .add(const ProfileRefreshEvent()),
                            child: _ProfileContent(profile: state.profile),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
class _ProfileContent extends StatelessWidget {
  final FullProfile profile;
  const _ProfileContent({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isProvider = profile.isProvider;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        // Tarjeta principal con avatar y nombre.
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppTheme.textSecondary, size: 20),
                  onPressed: () async {
                    await context.push(AppConstants.routeProfileEdit, extra: profile);
                    if (context.mounted) {
                      context.read<ProfileBloc>().add(const ProfileRefreshEvent());
                    }
                  },
                  tooltip: 'Editar Perfil',
                ),
              ),
              CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.primarySoft,
                backgroundImage:
                    (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty)
                        ? NetworkImage(profile.avatarUrl!)
                        : null,
                child: (profile.avatarUrl == null || profile.avatarUrl!.isEmpty)
                    ? const Icon(Icons.person,
                        size: 56, color: AppTheme.primary)
                    : null,
              ),
              const SizedBox(height: 14),
              Text(profile.user.fullName,
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primarySoft,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Text(
                  isProvider ? 'PROVEEDOR' : 'CLIENTE',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  profile.bio!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Información de contacto.
        _InfoSection(
          title: 'Información de contacto',
          children: [
            _InfoRow(
              icon: Icons.alternate_email,
              label: 'Correo',
              value: profile.user.email,
            ),
            if (profile.user.phone != null && profile.user.phone!.isNotEmpty)
              _InfoRow(
                icon: Icons.phone_outlined,
                label: 'Teléfono',
                value: profile.user.phone!,
              ),
          ],
        ),

        // Sección específica de proveedor.
        if (isProvider && profile.providerProfile != null) ...[
          const SizedBox(height: 20),
          _InfoSection(
            title: 'Información profesional',
            children: [
              _InfoRow(
                icon: Icons.timeline_outlined,
                label: 'Años de experiencia',
                value: '${profile.providerProfile!.yearsExperience} años',
              ),
              _InfoRow(
                icon: Icons.attach_money,
                label: 'Tarifa por hora',
                value: NumberFormat.currency(
                  locale: 'es_CO',
                  symbol: r'$',
                  decimalDigits: 0,
                ).format(profile.providerProfile!.hourlyRate),
              ),
              _InfoRow(
                icon: profile.providerProfile!.isAvailable
                    ? Icons.check_circle_outline
                    : Icons.do_not_disturb_on_outlined,
                label: 'Disponibilidad',
                value: profile.providerProfile!.isAvailable
                    ? 'Disponible para trabajos'
                    : 'No disponible',
              ),
            ],
          ),
          if (profile.primaryAddress != null) ...[
            const SizedBox(height: 20),
            _InfoSection(
              title: 'Ubicación',
              children: [
                _InfoRow(
                  icon: Icons.home_outlined,
                  label: 'Dirección',
                  value: profile.primaryAddress!.formatted,
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          _InfoSection(
            title: 'Mis reseñas',
            children: [
              if (profile.reviews.isEmpty)
                const _EmptyReviews()
              else
                Column(
                  children: profile.reviews
                      .map((review) => ReviewCard(
                            review: review,
                            showShadow: false,
                            padding: 14,
                            starsSize: 16,
                          ))
                      .toList(),
                ),
            ],
          ),
        ],

        // Acciones.
        const SizedBox(height: 28),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _InfoSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 2),
                Text(value,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppTheme.error),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyReviews extends StatelessWidget {
  const _EmptyReviews();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.rate_review_outlined, size: 20, color: AppTheme.textTertiary),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Aún no tienes reseñas registradas.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}


