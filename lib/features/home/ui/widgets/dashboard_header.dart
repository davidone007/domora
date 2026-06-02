import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/features/notifications/ui/bloc/notification_bloc.dart';

/// Header oscuro del dashboard.
///
/// Estructura: icono de grid a la izquierda, logo + texto "Domora"
/// centrado, campana de notificaciones (con punto rojo) a la derecha.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    this.onMenuTap,
  });

  final VoidCallback? onMenuTap;

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

              // Campana con badge dinámico de no leídas.
              BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state) {
                  final unread = state.unreadCount;
                  final label = unread > 9 ? '9+' : '$unread';

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _IconButtonOnDark(
                        icon: Icons.notifications_outlined,
                        onTap: () => context.push('/notifications'),
                      ),
                      if (unread > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF3B30),
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(
                                color: AppTheme.surfaceDark,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
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
