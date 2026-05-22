import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/utils/constants.dart';
import 'package:domora/core/widgets/main_shell.dart';
import 'package:domora/features/home/ui/widgets/dashboard_header.dart';
import 'package:domora/features/home/ui/widgets/news_chip_filter.dart';
import 'package:domora/features/home/ui/widgets/promo_banner.dart';
import 'package:domora/features/home/ui/widgets/service_card.dart';

/// Dashboard del cliente.
///
/// Estructura visual:
///   1. Header oscuro con app icon, nombre "Domora" y campana de notificaciones.
///   2. Sheet blanca redondeada con saludo, sección de Servicios, sección de
///      Noticias y Ofertas (chips + banner promocional).
///   3. Bottom nav del MainShell.
class ClientHomePage extends StatefulWidget {
  final String? userId;
  const ClientHomePage({super.key, this.userId});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  int _selectedNewsFilter = 0;

  static const _newsFilters = ['Cupones', 'Promoción', 'Ofertas de Verano'];

  void _onServiceTap(String name) {
    if (name == 'Limpieza') {
      context.push('/publish-service');
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$name disponible próximamente')));
  }

  void _onNotificationsTap() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('No tienes notificaciones nuevas')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return MainShell(
      activeTab: MainTab.home,
      role: AppConstants.roleClient, // Añadido rol explícito
      body: Column(
        children: [
          // Header oscuro pegado al top.
          DashboardHeader(onNotificationsTap: _onNotificationsTap),

          // Sheet blanca con curva superior.
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
                    // Saludo.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Bienvenido',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(width: 8),
                        const Text('👋', style: TextStyle(fontSize: 26)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '¿Necesitas ayuda hoy?',
                      style:
                          Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                    ),

                    const SizedBox(height: 28),

                    // Sección Servicios.
                    Text('Servicios',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ServiceCard(
                          icon: Icons.cleaning_services_outlined,
                          label: 'Limpieza',
                          badgeText: 'Nuevo',
                          onTap: () => _onServiceTap('Limpieza'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Sección Noticias y Ofertas.
                    Text('Noticias y Ofertas',
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
                      title: '40% OFF',
                      subtitle: 'En el primer servicio de limpieza',
                      tag: 'Unidades limitadas',
                      onTap: () => _onServiceTap('Promoción'),
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

  // Mantiene la firma con Supabase por si más adelante mostramos el nombre
  // del usuario en el saludo. Por ahora dejamos el saludo genérico para que
  // sea consistente.
}
