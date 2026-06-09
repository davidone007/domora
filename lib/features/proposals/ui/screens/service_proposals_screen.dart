import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/widgets/empty_state.dart';
import 'package:domora/core/widgets/error_state.dart';
import 'package:domora/core/widgets/loading_state.dart';
import '../../domain/entities/proposal_with_provider.dart';
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
      body: BlocConsumer<ServiceProposalsBloc, ServiceProposalsState>(
        listener: (context, state) {
          if (state.status == ServiceProposalsStatus.acceptSuccess) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Propuesta aceptada con éxito. Procede con el pago.'),
                backgroundColor: AppTheme.primary,
              ),
            );

            context.push(
              '/payment/${state.acceptedBookingId}',
              extra: {'amount': state.acceptedAmount},
            );
          }

          if (state.status == ServiceProposalsStatus.error && state.errorMessage != null) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppTheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == ServiceProposalsStatus.loading ||
              state.status == ServiceProposalsStatus.accepting) {
            return const LoadingStateView();
          }

          if (state.status == ServiceProposalsStatus.error) {
            return ErrorStateView(
              message: state.errorMessage ?? 'Error al cargar propuestas',
              onRetry: () => context
                  .read<ServiceProposalsBloc>()
                  .add(FetchServiceProposalsEvent(widget.serviceId)),
            );
          }

          if (state.status == ServiceProposalsStatus.success) {
            if (state.proposals.isEmpty) {
              return const EmptyState(
                icon: Icons.description_outlined,
                title: 'Aún no hay propuestas',
                subtitle:
                    'Te avisaremos cuando un aseador cotice tu servicio.',
              );
            }

            final bool hasAcceptedProposal = state.proposals.any((p) => p.proposal.status == 'accepted');

            return RefreshIndicator(
              onRefresh: () async {
                final bloc = context.read<ServiceProposalsBloc>();
                bloc.add(FetchServiceProposalsEvent(widget.serviceId));
                await bloc.stream.firstWhere(
                  (s) => s.status != ServiceProposalsStatus.loading,
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: state.proposals.length,
                itemBuilder: (context, index) {
                  final proposal = state.proposals[index];
                  return ProposalCard(
                    proposalWithProvider: proposal,
                    showAcceptButton: !hasAcceptedProposal,
                    onAccept: () => _showConfirmDialog(context, proposal),
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

  void _showConfirmDialog(BuildContext context, ProposalWithProvider proposal) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Aceptar Propuesta'),
        content: Text(
          '¿Estás seguro que deseas aceptar la propuesta de ${proposal.providerFirstName} por un valor de ${NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0).format(proposal.proposal.price)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ServiceProposalsBloc>().add(AcceptProposalRequestedEvent(proposal.proposal));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Sí, Aceptar'),
          ),
        ],
      ),
    );
  }
}
