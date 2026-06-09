import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:domora/core/theme/app_theme.dart';
import '../../domain/entities/service.dart';

class ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback? onTap;
  final bool showProposalSent;

  const ServiceCard({
    super.key,
    required this.service,
    this.onTap,
    this.showProposalSent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      service.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _StatusBadge(status: service.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('dd MMM, yyyy').format(service.createdAt),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.chat_bubble_outline, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    '${service.quotesCount} propuestas',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              if (showProposalSent) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 16, color: AppTheme.primary),
                      SizedBox(width: 6),
                      Text(
                        'Propuesta enviada',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (service.description != null && service.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  service.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bgColor;
    String label;

    switch (status.toLowerCase()) {
      case 'open':
        color = AppTheme.primary;
        bgColor = AppTheme.primarySoft;
        label = 'Abierto';
        break;
      case 'in_progress':
        color = Colors.blue;
        bgColor = Colors.blue.withOpacity(0.1);
        label = 'En curso';
        break;
      case 'completed':
        color = AppTheme.textSecondary;
        bgColor = AppTheme.divider;
        label = 'Completado';
        break;
      case 'cancelled':
        color = AppTheme.error;
        bgColor = AppTheme.error.withOpacity(0.1);
        label = 'Cancelado';
        break;
      default:
        color = AppTheme.textTertiary;
        bgColor = AppTheme.divider;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
