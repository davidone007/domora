import 'package:flutter/material.dart';

import 'package:domora/core/theme/app_theme.dart';

/// Header oscuro del dashboard.
///
/// Estructura: icono de grid a la izquierda, logo + texto "Domora"
/// centrado, campana de notificaciones (con punto rojo) a la derecha.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    this.onMenuTap,
    this.onNotificationsTap,
    this.hasNotifications = true,
  });

  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationsTap;
  final bool hasNotifications;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surfaceDark,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Row(
            children: [
              // Botón menú (grid).
              _IconButtonOnDark(
                icon: Icons.grid_view_rounded,
                onTap: onMenuTap,
              ),

              // Logo + nombre, centrado.
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.cottage_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Domora',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),

              // Campana con dot rojo.
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _IconButtonOnDark(
                    icon: Icons.notifications_outlined,
                    onTap: onNotificationsTap,
                  ),
                  if (hasNotifications)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF3B30),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconButtonOnDark extends StatelessWidget {
  const _IconButtonOnDark({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
