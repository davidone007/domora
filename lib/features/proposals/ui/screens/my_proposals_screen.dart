import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:domora/core/theme/app_theme.dart';
import 'package:domora/core/widgets/empty_state.dart';
import 'package:domora/core/widgets/error_state.dart';
import 'package:domora/core/widgets/loading_state.dart';
import '../../domain/entities/proposal_with_service.dart';
import '../bloc/my_proposals_bloc.dart';

class MyProposalsScreen extends StatefulWidget {
  const MyProposalsScreen({super.key});

  @override
  State<MyProposalsScreen> createState() => _MyProposalsScreenState();
}

class _MyProposalsScreenState extends State<MyProposalsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MyProposalsBloc>().add(const FetchMyProposalsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Mis Propuestas Enviadas'),
      ),
      body: BlocBuilder<MyProposalsBloc, MyProposalsState>(
        builder: (context, state) {
          if (state.status == MyProposalsStatus.loading) {
            return const LoadingStateView();
          }

          if (state.status == MyProposalsStatus.error) {
            return ErrorStateView(
              message: state.errorMessage ?? 'Error al cargar las propuestas',
              onRetry: () => context
                  .read<MyProposalsBloc>()
                  .add(const FetchMyProposalsEvent()),
            );
          }

          if (state.status == MyProposalsStatus.success &&
              state.proposals.isEmpty) {
            return const EmptyState(
              icon: Icons.assignment_outlined,
              title: 'Aún no has enviado propuestas',
              subtitle:
                  'Cuando envíes una cotización para un servicio, aparecerá aquí.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final bloc = context.read<MyProposalsBloc>();
              bloc.add(const FetchMyProposalsEvent());
              await bloc.stream.firstWhere(
                (s) => s.status != MyProposalsStatus.loading,
              );
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: state.proposals.length,
              itemBuilder: (context, index) {
                return _ProposalCard(item: state.proposals[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ProposalCard extends StatelessWidget {
  final ProposalWithService item;

  const _ProposalCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM yyyy', 'es_CO');
    final proposal = item.proposal;

    return GestureDetector(
      onTap: () => context.push('/service-detail/${proposal.serviceId}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.serviceTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _ProposalStatusBadge(status: proposal.status),
              ],
            ),
            if (proposal.message != null && proposal.message!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                proposal.message!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TU PRECIO',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.textTertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      currencyFormat.format(proposal.price),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                if (proposal.createdAt != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'ENVIADA EL',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.textTertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        dateFormat.format(proposal.createdAt!),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 10),
            const Row(
              children: [
                Icon(Icons.arrow_forward_ios,
                    size: 12, color: AppTheme.primary),
                SizedBox(width: 4),
                Text(
                  'Ver detalle del servicio',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProposalStatusBadge extends StatelessWidget {
  final String status;

  const _ProposalStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;

    switch (status) {
      case 'accepted':
        color = AppTheme.primary;
        label = 'Aceptada';
      case 'rejected':
        color = AppTheme.error;
        label = 'Rechazada';
      default:
        color = Colors.orange;
        label = 'Pendiente';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
