import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/widgets/custom_button.dart';
import 'package:domora/core/widgets/error_state.dart';
import 'package:domora/core/widgets/loading_state.dart';
import 'package:domora/core/utils/constants.dart';
import 'package:domora/features/services/domain/entities/cleaning_service_detail.dart';
import '../bloc/service_detail_bloc.dart';
import '../widgets/map_display.dart';

class ServiceDetailScreen extends StatelessWidget {
  final String serviceId;

  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: BlocBuilder<ServiceDetailBloc, ServiceDetailState>(
        builder: (context, state) {
          if (state.status == ServiceDetailStatus.loading) {
            return const LoadingStateView();
          }

          if (state.status == ServiceDetailStatus.error) {
            return ErrorStateView(
              message: state.errorMessage ?? 'Error al cargar el detalle',
              onRetry: () => context
                  .read<ServiceDetailBloc>()
                  .add(FetchServiceDetailEvent(serviceId)),
            );
          }

          if (state.status == ServiceDetailStatus.success && state.serviceDetail != null) {
            final detail = state.serviceDetail!;
            final service = detail.service;
            final cleaning = detail.cleaningDetail;
            final address = detail.address;

            return CustomScrollView(
              slivers: [
                _ImageCarousel(imageUrls: detail.imageUrls),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                service.title,
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                            _StatusBadge(status: service.status),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _TechnicalDetailsGrid(cleaning: cleaning),
                        const SizedBox(height: 24),
                        Text('Descripción', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text(
                          service.description ?? 'Sin descripción',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 24),
                        Text('Programación', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        _ScheduleInfo(
                          date: service.preferredDate,
                          time: service.preferredTimeStart,
                        ),
                        const SizedBox(height: 24),
                        Text('Ubicación', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text(
                          '${address.addressLine1}${address.addressLine2 != null ? ', ${address.addressLine2}' : ''}\n${address.neighborhood != null ? '${address.neighborhood}, ' : ''}${address.city}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        if (address.latitude != null && address.longitude != null)
                          MapDisplay(latitude: address.latitude!, longitude: address.longitude!),
                        const SizedBox(height: 120), // Espacio para el botón inferior
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      bottomSheet: BlocBuilder<ServiceDetailBloc, ServiceDetailState>(
        builder: (context, state) {
          if (state.status != ServiceDetailStatus.success || state.serviceDetail == null) {
            return const SizedBox.shrink();
          }

          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: state.isProvider
                  ? state.hasProposed
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.primarySoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: AppTheme.primary),
                              SizedBox(width: 8),
                              Text(
                                'Propuesta enviada',
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      : CustomButton(
                          label: 'Enviar Propuesta',
                          onPressed: () async {
                            final result = await context.push('/send-proposal/${state.serviceDetail!.service.id}');
                            if (result == true && context.mounted) {
                              context.read<ServiceDetailBloc>().add(FetchServiceDetailEvent(serviceId));
                            }
                          },
                        )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${state.serviceDetail!.service.quotesCount}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const Text('Propuestas recibidas', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomButton(
                            label: 'Ver propuestas',
                            onPressed: () {
                              context.push('${AppConstants.routeServiceProposals}/${state.serviceDetail!.service.id}');
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;

  const _ImageCarousel({required this.imageUrls});

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return SliverAppBar(
        expandedHeight: 200,
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            color: AppTheme.primarySoft,
            child: const Icon(Icons.image_outlined, size: 48, color: AppTheme.primary),
          ),
        ),
      );
    }

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      leading: IconButton(
        icon: const CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(Icons.arrow_back, color: Colors.black, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            PageView.builder(
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                return Image.network(
                  widget.imageUrls[index],
                  fit: BoxFit.cover,
                );
              },
            ),
            if (widget.imageUrls.length > 1)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.imageUrls.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index ? AppTheme.primary : Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TechnicalDetailsGrid extends StatelessWidget {
  final CleaningServiceDetail cleaning;

  const _TechnicalDetailsGrid({required this.cleaning});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primarySoft.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _DetailItem(icon: Icons.bathtub_outlined, label: 'Baños', value: cleaning.bathrooms.toString()),
          _DetailItem(icon: Icons.king_bed_outlined, label: 'Hab.', value: cleaning.bedrooms.toString()),
          _DetailItem(icon: Icons.kitchen_outlined, label: 'Cocinas', value: cleaning.kitchens.toString()),
          _DetailItem(icon: Icons.chair_outlined, label: 'Salas', value: cleaning.livingRooms.toString()),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primary, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
      ],
    );
  }
}

class _ScheduleInfo extends StatelessWidget {
  final DateTime? date;
  final String? time;

  const _ScheduleInfo({this.date, this.time});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InfoTile(
            icon: Icons.calendar_today_outlined,
            title: 'Fecha',
            subtitle: date != null ? DateFormat('EEEE, dd MMMM', 'es_CO').format(date!) : 'No definida',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _InfoTile(
            icon: Icons.access_time_outlined,
            title: 'Hora',
            subtitle: time ?? 'No definida',
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 10, color: AppTheme.textTertiary)),
                Text(subtitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
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
