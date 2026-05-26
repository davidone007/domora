import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/utils/constants.dart';
import 'package:domora/core/widgets/main_shell.dart';
import 'package:domora/core/widgets/custom_button.dart';
import '../bloc/booking_activity_bloc.dart';
import '../../domain/entities/booking_with_service.dart';

class BookingActivityScreen extends StatefulWidget {
  const BookingActivityScreen({super.key});

  @override
  State<BookingActivityScreen> createState() => _BookingActivityScreenState();
}

class _BookingActivityScreenState extends State<BookingActivityScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BookingActivityBloc>().add(const FetchBookingActivityEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingActivityBloc, BookingActivityState>(
      builder: (context, state) {
        final isProvider = state.role == AppConstants.roleProvider;
        final title = isProvider ? 'Mis Trabajos' : 'Historial de Servicios';

        return MainShell(
          activeTab: MainTab.activity,
          role: state.role,
          body: Scaffold(
            appBar: AppBar(
              title: Text(title),
              automaticallyImplyLeading: false,
            ),
            body: _buildBody(state, isProvider),
          ),
        );
      },
    );
  }

  Widget _buildBody(BookingActivityState state, bool isProvider) {
    if (state.status == BookingActivityStatus.loading && state.bookings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == BookingActivityStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
              const SizedBox(height: 16),
              Text(state.errorMessage ?? 'Error al cargar actividad'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.read<BookingActivityBloc>().add(const FetchBookingActivityEvent()),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.status == BookingActivityStatus.success && state.bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_outlined, size: 80, color: AppTheme.divider),
            const SizedBox(height: 16),
            Text(
              isProvider ? 'No tienes trabajos activos' : 'No tienes servicios completados',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<BookingActivityBloc>().add(const FetchBookingActivityEvent());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: state.bookings.length,
        itemBuilder: (context, index) {
          final item = state.bookings[index];
          return _BookingActivityCard(
            item: item,
            isProvider: isProvider,
            onComplete: () => _showCompleteConfirm(item),
          );
        },
      ),
    );
  }

  void _showCompleteConfirm(BookingWithService item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Finalizar Servicio'),
        content: Text('¿Confirmas que has terminado el servicio "${item.service.title}"? El cliente podrá verlo en su historial.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BookingActivityBloc>().add(
                CompleteBookingRequestedEvent(
                  bookingId: item.booking.id,
                  serviceId: item.service.id,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
            child: const Text('Sí, Finalizar'),
          ),
        ],
      ),
    );
  }
}

class _BookingActivityCard extends StatelessWidget {
  final BookingWithService item;
  final bool isProvider;
  final VoidCallback onComplete;

  const _BookingActivityCard({
    required this.item,
    required this.isProvider,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    final bool canRate = !isProvider && 
                        item.booking.status == 'completed' && 
                        !item.hasReview;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primarySoft,
                backgroundImage: item.otherPartyAvatarUrl != null ? NetworkImage(item.otherPartyAvatarUrl!) : null,
                child: item.otherPartyAvatarUrl == null ? const Icon(Icons.person, color: AppTheme.primary) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isProvider ? 'Cliente: ${item.otherPartyName}' : 'Aseador: ${item.otherPartyName}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      item.service.title,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: item.booking.status),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PRECIO FINAL', style: TextStyle(fontSize: 10, color: AppTheme.textTertiary, fontWeight: FontWeight.bold)),
                  Text(currencyFormat.format(item.booking.finalPrice), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('FECHA', style: TextStyle(fontSize: 10, color: AppTheme.textTertiary, fontWeight: FontWeight.bold)),
                  Text(dateFormat.format(item.booking.createdAt), style: const TextStyle(fontSize: 11)),
                ],
              ),
            ],
          ),
          if (isProvider && item.booking.status != 'completed') ...[
            const SizedBox(height: 16),
            CustomButton(
              label: 'Finalizar Servicio',
              onPressed: onComplete,
            ),
          ],
          if (canRate) ...[
            const SizedBox(height: 16),
            CustomButton(
              label: 'Calificar Servicio',
              onPressed: () async {
                final result = await context.push(
                  '/rate-service/${item.booking.id}',
                  extra: {
                    'serviceTitle': item.service.title,
                    'providerName': item.otherPartyName,
                  },
                );
                if (result == true && context.mounted) {
                  context.read<BookingActivityBloc>().add(const FetchBookingActivityEvent());
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = AppTheme.primary;
    String label = status;

    if (status == 'completed') {
      color = AppTheme.primary;
      label = 'Completado';
    } else if (status == 'pending' || status == 'confirmed') {
      color = Colors.orange;
      label = 'Activo';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
