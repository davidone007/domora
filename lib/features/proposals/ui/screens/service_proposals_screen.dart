import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:domora/core/theme/app_theme.dart';
import '../bloc/service_proposals_bloc.dart';
import '../widgets/proposal_card.dart';

class ServiceProposalsScreen extends StatefulWidget {
  final String serviceId;

  const ServiceProposalsScreen({super.key, required this.serviceId});

  @override
  State<ServiceProposalsScreen> createState() => _ServiceProposalsScreenState();
}

class _ServiceProposalsScreenState extends State<ServiceProposalsScreen> {
  bool _ascending = true;

  @override
  void initState() {
    super.initState();
    context.read<ServiceProposalsBloc>().add(FetchServiceProposalsEvent(widget.serviceId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Propuestas Recibidas'),
        actions: [
          IconButton(
            icon: Icon(_ascending ? Icons.south_outlined : Icons.north_outlined, size: 20),
            onPressed: () {
              setState(() => _ascending = !_ascending);
              context.read<ServiceProposalsBloc>().add(SortProposalsByPriceEvent(ascending: _ascending));
            },
            tooltip: 'Ordenar por precio',
          ),
        ],
      ),
      body: BlocBuilder<ServiceProposalsBloc, ServiceProposalsState>(
        builder: (context, state) {
          if (state.status == ServiceProposalsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ServiceProposalsStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
                  const SizedBox(height: 16),
                  Text(state.errorMessage ?? 'Error al cargar propuestas'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context
                        .read<ServiceProposalsBloc>()
                        .add(FetchServiceProposalsEvent(widget.serviceId)),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state.status == ServiceProposalsStatus.success) {
            if (state.proposals.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.description_outlined, size: 80, color: AppTheme.divider),
                    const SizedBox(height: 16),
                    const Text(
                      'Aún no hay propuestas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Te avisaremos cuando alguien cotice tu servicio.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textTertiary),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ServiceProposalsBloc>().add(FetchServiceProposalsEvent(widget.serviceId));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: state.proposals.length,
                itemBuilder: (context, index) {
                  final proposal = state.proposals[index];
                  return ProposalCard(
                    proposalWithProvider: proposal,
                    onTap: () {
                      context.push('/provider-profile/${proposal.proposal.providerId}');
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
