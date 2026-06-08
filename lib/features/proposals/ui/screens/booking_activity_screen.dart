import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/utils/constants.dart';
import 'package:domora/core/widgets/main_shell.dart';
import 'package:domora/core/widgets/custom_button.dart';
import 'package:domora/core/widgets/empty_state.dart';
import 'package:domora/core/widgets/error_state.dart';
import 'package:domora/core/widgets/loading_state.dart';
import 'package:domora/core/widgets/rating_stars.dart';
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
      return const LoadingStateView();
    }

    if (state.status == BookingActivityStatus.error) {
      return ErrorStateView(
        message: state.errorMessage ?? 'Error al cargar actividad',
        onRetry: () => context
            .read<BookingActivityBloc>()
            .add(const FetchBookingActivityEvent()),
      );
    }

    if (state.status == BookingActivityStatus.success && state.bookings.isEmpty) {
      return EmptyState(
        icon: Icons.history_outlined,
        title: isProvider
            ? 'Aún no tienes trabajos'
            : 'Aún no tienes servicios completados',
        subtitle: isProvider
            ? 'Cuando te acepten una propuesta, tus trabajos aparecerán aquí.'
            : 'Cuando uno de tus servicios se complete, aparecerá aquí.',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final bloc = context.read<BookingActivityBloc>();
        bloc.add(const FetchBookingActivityEvent());
        await bloc.stream.firstWhere(
          (s) => s.status != BookingActivityStatus.loading,
        );
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: state.bookings.length,
        itemBuilder: (context, index) {
          final item = state.bookings[index];
          return _BookingActivityCard(
            item: item,
            isProvider: isProvider,
            userId: state.userId,
            isAvailable: state.isAvailable,
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
  final String? userId;
  final bool isAvailable;
  final VoidCallback onComplete;

  const _BookingActivityCard({
    required this.item,
    required this.isProvider,
    required this.onComplete,
    this.userId,
    this.isAvailable = true,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    final bool canRate = !isProvider &&
        item.booking.status == 'completed' &&
        !item.hasReview;

    final bool canRateAsProvider = isProvider &&
        item.booking.status == 'completed' &&
        !item.hasProviderReview;

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
                    if (!isProvider)
                      GestureDetector(
                        onTap: () {
                          context.push('/provider-profile/${item.booking.providerId}');
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Aseador: ${item.otherPartyName}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.open_in_new, size: 13, color: AppTheme.primary),
                          ],
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () {
                          context.push('/client-profile/${item.booking.clientId}');
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Cliente: ${item.otherPartyName}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.open_in_new, size: 13, color: AppTheme.primary),
                          ],
                        ),
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
            if (!isAvailable)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Debes estar disponible para finalizar servicios',
                  style: TextStyle(
                    color: AppTheme.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            CustomButton(
              label: 'Finalizar Servicio',
              onPressed: isAvailable ? onComplete : null,
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
                    'otherPartyName': item.otherPartyName,
                    'reviewerType': 'client',
                    'reviewerId': userId,
                  },
                );
                if (result == true && context.mounted) {
                  context.read<BookingActivityBloc>().add(const FetchBookingActivityEvent());
                }
              },
            ),
          ],
          if (canRateAsProvider) ...[
            const SizedBox(height: 16),
            CustomButton(
              label: 'Calificar Cliente',
              onPressed: () async {
                final result = await context.push(
                  '/rate-service/${item.booking.id}',
                  extra: {
                    'serviceTitle': item.service.title,
                    'otherPartyName': item.otherPartyName,
                    'reviewerType': 'provider',
                    'reviewerId': userId,
                  },
                );
                if (result == true && context.mounted) {
                  context.read<BookingActivityBloc>().add(const FetchBookingActivityEvent());
                }
              },
            ),
          ],
          if (!isProvider && item.hasReview && item.reviewRating != null) ...[
            const SizedBox(height: 12),
            _ExistingReviewBadge(
              rating: item.reviewRating!,
              comment: item.reviewComment,
            ),
          ],
          if (isProvider && item.hasProviderReview) ...[
            const SizedBox(height: 12),
            _AlreadyRatedBadge(),
          ],
        ],
      ),
    );
  }
}

/// Muestra el rating ya enviado para un servicio completado.
class _ExistingReviewBadge extends StatelessWidget {
  final int rating;
  final String? comment;

  const _ExistingReviewBadge({required this.rating, this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primarySoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rate_review_outlined,
                  size: 16, color: AppTheme.primary),
              const SizedBox(width: 6),
              const Text(
                'Tu calificación',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
              const Spacer(),
              RatingStars(rating: rating.toDouble(), size: 14),
            ],
          ),
          if (comment != null && comment!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              comment!,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Badge compacto que indica al proveedor que ya calificó a este cliente.
class _AlreadyRatedBadge extends StatelessWidget {
  const _AlreadyRatedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline,
              size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 6),
          Text(
            'Ya calificaste a este cliente',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
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
