import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/utils/constants.dart';
import 'package:domora/core/widgets/main_shell.dart';
import 'package:domora/features/home/ui/widgets/dashboard_header.dart';
import 'package:domora/features/home/ui/widgets/news_chip_filter.dart';
import 'package:domora/features/home/ui/widgets/promo_banner.dart';
import 'package:domora/features/home/ui/widgets/service_card.dart';

/// Dashboard del proveedor.
///
/// Reutiliza el mismo "shell" que el cliente para mantener consistencia
/// visual, pero el contenido cambia: en lugar de servicios para contratar,
/// el proveedor ve accesos a su disponibilidad y a las solicitudes que
/// recibe.
class ProviderHomePage extends StatefulWidget {
  const ProviderHomePage({super.key});

  @override
  State<ProviderHomePage> createState() => _ProviderHomePageState();
}

class _ProviderHomePageState extends State<ProviderHomePage> {
  int _selectedNewsFilter = 0;

  static const _newsFilters = ['Anuncios', 'Tips', 'Capacitación'];

  void _onTilePressed(String name) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$name disponible próximamente')));
  }

  @override
  Widget build(BuildContext context) {
    return MainShell(
      activeTab: MainTab.home,
      onTabSelected: (tab) {
        if (tab == MainTab.profile) context.go(AppConstants.routeProfile);
        if (tab == MainTab.requests || tab == MainTab.coupons) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Disponible próximamente')),
            );
        }
      },
      body: Column(
        children: [
          DashboardHeader(
            onNotificationsTap: () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                      content: Text('No tienes notificaciones nuevas')),
                );
            },
          ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Hola',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(width: 8),
                        const Text('🛠️', style: TextStyle(fontSize: 26)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '¿Listo para tu próximo servicio?',
                      style:
                          Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                    ),

                    const SizedBox(height: 28),

                    // Accesos del proveedor.
                    Text('Mi panel',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ServiceCard(
                          icon: Icons.event_available_outlined,
                          label: 'Disponibilidad',
                          onTap: () => _onTilePressed('Disponibilidad'),
                        ),
                        const SizedBox(width: 16),
                        ServiceCard(
                          icon: Icons.assignment_outlined,
                          label: 'Solicitudes',
                          badgeText: '0',
                          onTap: () => _onTilePressed('Solicitudes'),
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
                      onTap: () => context.go(AppConstants.routeProfile),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
