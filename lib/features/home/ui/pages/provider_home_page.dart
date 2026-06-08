import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/utils/constants.dart';
import 'package:domora/core/widgets/main_shell.dart';
import 'package:domora/features/home/ui/widgets/dashboard_header.dart';
import 'package:domora/features/home/ui/widgets/news_chip_filter.dart';
import 'package:domora/features/home/ui/widgets/promo_banner.dart';
import 'package:domora/features/profile/ui/bloc/profile_bloc.dart';
import 'package:domora/features/notifications/ui/bloc/notification_bloc.dart';
import 'package:domora/features/notifications/domain/entities/app_notification.dart';

/// Dashboard del proveedor.
class ProviderHomePage extends StatefulWidget {
  const ProviderHomePage({super.key});

  @override
  State<ProviderHomePage> createState() => _ProviderHomePageState();
}

class _ProviderHomePageState extends State<ProviderHomePage> {
  int _selectedNewsFilter = 0;

  /// Guarda la disponibilidad anterior para detectar cambios tras el toggle.
  bool? _previousAvailability;

  static const _newsFilters = ['Anuncios', 'Tips', 'Capacitación'];

  void _toggleAvailability() {
    context.read<ProfileBloc>().add(const ProfileToggleAvailabilityEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileErrorState) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.error,
            ));
        }

        if (state is ProfileLoadedState &&
            state.profile.providerProfile != null) {
          final isAvailable = state.profile.providerProfile!.isAvailable;
          // Notificar solo cuando el toggle cambió el valor (no en carga inicial).
          if (_previousAvailability != null &&
              _previousAvailability != isAvailable) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(isAvailable
                    ? 'Ahora estás disponible para recibir solicitudes'
                    : 'Ya no estás disponible para nuevas solicitudes'),
                backgroundColor: isAvailable
                    ? AppTheme.primary
                    : AppTheme.textSecondary,
                duration: const Duration(seconds: 2),
              ));
          }
          _previousAvailability = isAvailable;
        }

        // Si el toggle falla, restablecer a disponibilidad anterior.
        if (state is ProfileErrorState && _previousAvailability != null) {
          _previousAvailability = null;
        }
      },
      builder: (context, state) {
        // Obtener el perfil del estado actual (loaded o toggling).
        final profile = state is ProfileLoadedState
            ? state.profile
            : state is ProfileTogglingAvailabilityState
                ? state.profile
                : null;

        final isAvailable =
            profile?.providerProfile?.isAvailable ?? false;

        final isTogglingAvailability =
            state is ProfileTogglingAvailabilityState;

        return MainShell(
          activeTab: MainTab.home,
          role: AppConstants.roleProvider,
          body: Column(
            children: [
              const DashboardHeader(),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: BlocBuilder<NotificationBloc, NotificationState>(
                      builder: (context, notificationState) {
                        final unreadProposals = notificationState.notifications
                            .where((n) =>
                                !n.isRead && n.type == 'proposal_received')
                            .length;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isAvailable && unreadProposals > 0)
                              _UnavailableWarningBanner(
                                  count: unreadProposals),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Hola',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium,
                                ),
                                const SizedBox(width: 8),
                                const Text('🛠️',
                                    style: TextStyle(fontSize: 26)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '¿Listo para tu próximo servicio?',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: AppTheme.textSecondary),
                            ),

                            const SizedBox(height: 28),

                            Text('Mi panel',
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                _ProviderActionCard(
                                  icon: isAvailable
                                      ? Icons.event_available_outlined
                                      : Icons.event_busy_outlined,
                                  label: 'Disponibilidad',
                                  badgeText: isAvailable ? 'Activo' : 'Inactivo',
                                  badgeColor: isAvailable
                                      ? AppTheme.primary
                                      : AppTheme.textSecondary,
                                  isLoading: isTogglingAvailability,
                                  onTap: isTogglingAvailability
                                      ? null
                                      : _toggleAvailability,
                                ),
                                const SizedBox(width: 16),
                                _ProviderActionCard(
                                  icon: Icons.assignment_outlined,
                                  label: 'Solicitudes',
                                  onTap: () => context.push('/my-proposals'),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            Text('Novedades',
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 16),
                            NewsChipFilter(
                              filters: _newsFilters,
                              selectedIndex: _selectedNewsFilter,
                              onSelected: (i) =>
                                  setState(() => _selectedNewsFilter = i),
                            ),
                            const SizedBox(height: 16),
                            PromoBanner(
                              title: 'Bienvenido a Domora',
                              subtitle:
                                  'Completa tu perfil y empieza a recibir solicitudes',
                              tag: 'Para ti',
                              onTap: () =>
                                  context.go(AppConstants.routeProfile),
                            ),

                            const SizedBox(height: 24),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Tarjeta de acción para el panel del proveedor con badge de color
/// configurable e indicador de carga durante operaciones asíncronas.
class _ProviderActionCard extends StatelessWidget {
  const _ProviderActionCard({
    required this.icon,
    required this.label,
    this.badgeText,
    this.badgeColor,
    this.isLoading = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? badgeText;
  final Color? badgeColor;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 92,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  margin: const EdgeInsets.only(top: 14),
                  decoration: const BoxDecoration(
                    color: AppTheme.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: isLoading
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation(AppTheme.primary),
                            ),
                          ),
                        )
                      : Icon(icon, color: AppTheme.primary, size: 32),
                ),
                if (badgeText != null && !isLoading)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor ?? AppTheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeText!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Banner de advertencia que se muestra cuando el proveedor tiene solicitudes
/// pendientes pero su estado actual es 'Inactivo' (no disponible).
class _UnavailableWarningBanner extends StatelessWidget {
  const _UnavailableWarningBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tienes $count ${count == 1 ? 'propuesta pendiente' : 'propuestas pendientes'}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
                Text(
                  'Activa tu disponibilidad para que los clientes puedan contactarte.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.amber.shade900,
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
