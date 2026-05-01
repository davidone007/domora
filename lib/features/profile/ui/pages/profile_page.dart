import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:domora/core/utils/constants.dart';
import 'package:domora/features/profile/domain/model/full_profile.dart';
import 'package:domora/features/profile/ui/bloc/profile_bloc.dart';

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

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) context.go(AppConstants.routeLogin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoadingState || state is ProfileInitialState) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileErrorState) {
            return _ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<ProfileBloc>().add(const ProfileRefreshEvent()),
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
          return const SizedBox.shrink();
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
      padding: const EdgeInsets.all(20),
      children: [
        // Tarjeta principal
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                backgroundImage: (profile.avatarUrl != null &&
                        profile.avatarUrl!.isNotEmpty)
                    ? NetworkImage(profile.avatarUrl!)
                    : null,
                child: (profile.avatarUrl == null ||
                        profile.avatarUrl!.isEmpty)
                    ? Icon(Icons.person,
                        size: 56, color: theme.colorScheme.primary)
                    : null,
              ),
              const SizedBox(height: 14),
              Text(profile.user.fullName,
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: (isProvider
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.primary)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Text(
                  isProvider ? 'PROVEEDOR' : 'CLIENTE',
                  style: TextStyle(
                    color: isProvider
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.primary,
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

        // Información de contacto
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

        // Sección específica de proveedor
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
        ],

        // Acciones
        const SizedBox(height: 28),
        OutlinedButton.icon(
          icon: const Icon(Icons.logout),
          label: const Text('Cerrar sesión'),
          onPressed: () async {
            await Supabase.instance.client.auth.signOut();
            if (context.mounted) context.go(AppConstants.routeLogin);
          },
        ),
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
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
              color: theme.colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
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
            const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
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
