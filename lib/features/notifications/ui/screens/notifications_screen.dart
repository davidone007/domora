import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:domora/core/theme/app_theme.dart';
import '../bloc/notification_bloc.dart';
import '../../domain/entities/app_notification.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notificaciones'),
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state.status == NotificationStatus.loading && state.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == NotificationStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
                    const SizedBox(height: 16),
                    Text(state.errorMessage ?? 'Error al cargar notificaciones'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.read<NotificationBloc>().add(const FetchNotificationsEvent()),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 80, color: AppTheme.divider),
                  const SizedBox(height: 16),
                  const Text(
                    'No tienes notificaciones aún',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<NotificationBloc>().add(const FetchNotificationsEvent());
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return _NotificationTile(notification: notification);
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM, hh:mm a');

    return ListTile(
      onTap: () {
        context.read<NotificationBloc>().add(MarkAsReadRequestedEvent(notification.id));
        
        // Navegación dinámica según el tipo
        if (notification.relatedServiceId != null) {
          if (notification.type == 'new_service_available' || notification.type == 'proposal_received') {
            context.push('/service-detail/${notification.relatedServiceId}');
          } else if (notification.type == 'service_accepted' && notification.relatedBookingId != null) {
            // El proveedor va a ver su actividad
            context.go('/activity');
          }
        }
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: notification.isRead ? AppTheme.background : AppTheme.primarySoft,
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getIconForType(notification.type),
          color: notification.isRead ? AppTheme.textTertiary : AppTheme.primary,
        ),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          fontSize: 14,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            notification.message,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            dateFormat.format(notification.createdAt),
            style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary),
          ),
        ],
      ),
      trailing: !notification.isRead
          ? Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'new_service_available':
        return Icons.campaign_outlined;
      case 'proposal_received':
        return Icons.description_outlined;
      case 'service_accepted':
        return Icons.check_circle_outline;
      case 'payment_confirmed':
        return Icons.payments_outlined;
      default:
        return Icons.notifications_none_rounded;
    }
  }
}
