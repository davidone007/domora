import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/utils/constants.dart';

/// Pestañas del bottom nav.
enum MainTab { home, requests, activity, profile }

/// Shell reutilizable que envuelve cualquier pantalla principal con un
/// bottom navigation bar oscuro y una píldora blanca elevada para la pestaña
/// activa.
class MainShell extends StatelessWidget {
  const MainShell({
    super.key,
    required this.activeTab,
    required this.body,
    this.role, // Opcional: client o provider
    this.onTabSelected,
    this.extendBodyBehindNav = false,
  });

  final MainTab activeTab;
  final Widget body;
  final String? role;
  final void Function(MainTab tab)? onTabSelected;
  final bool extendBodyBehindNav;

  void _handleTap(BuildContext context, MainTab tab) {
    if (tab == activeTab) {
      onTabSelected?.call(tab);
      return;
    }

    if (onTabSelected != null) {
      onTabSelected!(tab);
      return;
    }

    switch (tab) {
      case MainTab.home:
        if (role == AppConstants.roleProvider) {
          context.go(AppConstants.routeProviderHome);
        } else {
          context.go(AppConstants.routeClientHome);
        }
        break;
      case MainTab.profile:
        context.go(AppConstants.routeProfile);
        break;
      case MainTab.requests:
        context.go(AppConstants.routeMyServices);
        break;
      case MainTab.activity:
        context.go('/activity');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: extendBodyBehindNav,
      backgroundColor: AppTheme.background,
      body: body,
      bottomNavigationBar: _DomoraBottomNav(
        activeTab: activeTab,
        role: role,
        onTap: (tab) => _handleTap(context, tab),
      ),
    );
  }
}

class _DomoraBottomNav extends StatelessWidget {
  const _DomoraBottomNav({required this.activeTab, required this.onTap, this.role});

  final MainTab activeTab;
  final ValueChanged<MainTab> onTap;
  final String? role;

  @override
  Widget build(BuildContext context) {
    final isProvider = role == AppConstants.roleProvider;
    final requestsLabel = isProvider ? 'Servicios' : 'Solicitudes';

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 78,
          child: Row(
            children: [
              _NavItem(
                tab: MainTab.home,
                icon: Icons.home_rounded,
                label: 'Inicio',
                active: activeTab == MainTab.home,
                onTap: onTap,
              ),
              _NavItem(
                tab: MainTab.requests,
                icon: isProvider ? Icons.assignment_outlined : Icons.description_outlined,
                label: requestsLabel,
                active: activeTab == MainTab.requests,
                onTap: onTap,
              ),
              _NavItem(
                tab: MainTab.activity,
                icon: Icons.history_outlined,
                label: 'Actividad',
                active: activeTab == MainTab.activity,
                onTap: onTap,
              ),
              _NavItem(
                tab: MainTab.profile,
                icon: Icons.person_outline,
                label: 'Perfil',
                active: activeTab == MainTab.profile,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final MainTab tab;
  final IconData icon;
  final String label;
  final bool active;
  final ValueChanged<MainTab> onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () => onTap(tab),
        child: active ? _ActiveItem(icon: icon, label: label) : _InactiveItem(
          icon: icon,
          label: label,
        ),
      ),
    );
  }
}

class _ActiveItem extends StatelessWidget {
  const _ActiveItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Positioned(
          bottom: 8,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Positioned(
          top: -22,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.surfaceDark, width: 4),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 28),
          ),
        ),
      ],
    );
  }
}

class _InactiveItem extends StatelessWidget {
  const _InactiveItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.85), size: 26),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
