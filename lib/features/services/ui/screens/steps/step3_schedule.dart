import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:domora/core/theme/app_theme.dart';
import '../../bloc/service_publish_bloc.dart';

class Step3Schedule extends StatelessWidget {
  const Step3Schedule({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocBuilder<ServicePublishBloc, ServicePublishState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Cuándo lo necesitas?',
                style: theme.textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Elige la fecha y hora de inicio que más te convenga.',
                style: theme.textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 48),
              
              _ScheduleItem(
                label: 'Fecha preferida',
                value: DateFormat('EEEE, d ' 'MMMM', 'es_CO').format(state.preferredDate),
                icon: Icons.calendar_month_outlined,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: state.preferredDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppTheme.primary,
                            onPrimary: Colors.white,
                            onSurface: AppTheme.textPrimary,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null && context.mounted) {
                    context.read<ServicePublishBloc>().add(ServicePublishUpdateDraftEvent(preferredDate: picked));
                  }
                },
              ),
              
              const SizedBox(height: 24),
              
              _ScheduleItem(
                label: 'Hora de inicio',
                value: state.preferredTimeStart.substring(0, 5),
                icon: Icons.access_time_outlined,
                onTap: () async {
                  final parts = state.preferredTimeStart.split(':');
                  final initialTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
                  
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: initialTime,
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppTheme.primary,
                            onPrimary: Colors.white,
                            onSurface: AppTheme.textPrimary,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null && context.mounted) {
                    final timeStr = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
                    context.read<ServicePublishBloc>().add(ServicePublishUpdateDraftEvent(preferredTimeStart: timeStr));
                  }
                },
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _ScheduleItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppTheme.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 17,
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.border),
          ],
        ),
      ),
    );
  }
}
