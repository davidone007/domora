import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/utils/constants.dart';
import 'package:domora/core/widgets/empty_state.dart';
import 'package:domora/core/widgets/error_state.dart';
import 'package:domora/core/widgets/loading_state.dart';
import 'package:domora/core/widgets/main_shell.dart';
import '../bloc/my_services_bloc.dart';
import '../widgets/service_card.dart';

class MyServicesScreen extends StatefulWidget {
  const MyServicesScreen({super.key});

  @override
  State<MyServicesScreen> createState() => _MyServicesScreenState();
}

class _MyServicesScreenState extends State<MyServicesScreen> {
  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  void _fetchServices() {
    // Ya no extraemos el ID aquí. El BLoC lo obtendrá de la sesión oficial.
    context.read<MyServicesBloc>().add(const FetchMyServicesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyServicesBloc, MyServicesState>(
      builder: (context, state) {
        final isProvider = state.role == AppConstants.roleProvider;
        final title = isProvider ? 'Servicios Disponibles' : 'Mis Solicitudes';
        final emptyMessage = isProvider
            ? 'No hay servicios disponibles en este momento'
            : 'Aún no has publicado solicitudes';

        return MainShell(
          activeTab: MainTab.requests,
          role: state.role, // Pasamos el rol aquí
          body: Scaffold(
            appBar: AppBar(
              title: Text(title),
              automaticallyImplyLeading: false,
            ),
            body: Column(
              children: [
                const _StatusFilterList(),
                Expanded(
                  child: BlocBuilder<MyServicesBloc, MyServicesState>(
                    builder: (context, state) {
                      if (state.status == MyServicesStatus.loading &&
                          state.allServices.isEmpty) {
                        return const LoadingStateView();
                      }

                      if (state.status == MyServicesStatus.error) {
                        return ErrorStateView(
                          message: state.errorMessage ??
                              'Ocurrió un error al cargar los servicios',
                          onRetry: _fetchServices,
                        );
                      }

                      if (state.allServices.isEmpty &&
                          state.status == MyServicesStatus.success) {
                        return EmptyState(
                          icon: Icons.description_outlined,
                          title: emptyMessage,
                          subtitle: isProvider
                              ? 'Cuando haya solicitudes abiertas, aparecerán aquí.'
                              : 'Publica una solicitud para que los aseadores coticen.',
                        );
                      }

                      final services = state.filteredServices;

                      if (services.isEmpty && state.selectedStatus != null) {
                        return const EmptyState(
                          icon: Icons.filter_alt_off_outlined,
                          title: 'Sin resultados',
                          subtitle: 'No hay servicios con este estado.',
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          final bloc = context.read<MyServicesBloc>();
                          bloc.add(const FetchMyServicesEvent());
                          await bloc.stream.firstWhere(
                            (s) => s.status != MyServicesStatus.loading,
                          );
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: services.length,
                          itemBuilder: (context, index) {
                            return ServiceCard(
                              service: services[index],
                              onTap: () {
                                context.push(
                                    '/service-detail/${services[index].id}');
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusFilterList extends StatelessWidget {
  const _StatusFilterList();

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'label': 'Todos', 'value': null},
      {'label': 'Abiertos', 'value': 'open'},
      {'label': 'En curso', 'value': 'in_progress'},
      {'label': 'Completados', 'value': 'completed'},
    ];

    return BlocBuilder<MyServicesBloc, MyServicesState>(
      buildWhen: (prev, curr) => prev.selectedStatus != curr.selectedStatus,
      builder: (context, state) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: filters.map((filter) {
              final isSelected = state.selectedStatus == filter['value'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(filter['label']!.toString()),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      context.read<MyServicesBloc>().add(
                            FilterMyServicesEvent(filter['value']),
                          );
                    }
                  },
                  selectedColor: AppTheme.primary,
                  backgroundColor: AppTheme.background,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primary : AppTheme.border,
                    ),
                  ),
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
