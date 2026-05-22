import 'package:flutter/material.dart';
import 'package:domora/core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/proposal_with_provider.dart';

class ProposalCard extends StatelessWidget {
  final ProposalWithProvider proposalWithProvider;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final bool showAcceptButton;

  const ProposalCard({
    super.key,
    required this.proposalWithProvider,
    this.onTap,
    this.onAccept,
    this.showAcceptButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final proposal = proposalWithProvider.proposal;
    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.primarySoft,
                      backgroundImage: proposalWithProvider.providerAvatarUrl != null
                          ? NetworkImage(proposalWithProvider.providerAvatarUrl!)
                          : null,
                      child: proposalWithProvider.providerAvatarUrl == null
                          ? const Icon(Icons.person, color: AppTheme.primary)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            proposalWithProvider.providerFullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (proposalWithProvider.providerExperienceYears != null)
                            Text(
                              '${proposalWithProvider.providerExperienceYears} años de experiencia',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    _StatusBadge(status: proposal.status),
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
                        const Text(
                          'PRECIO OFERTADO',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1,
                            color: AppTheme.textTertiary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currencyFormat.format(proposal.price),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    if (proposal.estimatedHours != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'TIEMPO EST.',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1,
                              color: AppTheme.textTertiary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${proposal.estimatedHours} horas',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                if (proposal.message != null && proposal.message!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      proposal.message!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
                if (showAcceptButton && proposal.status == 'pending') ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Aceptar Propuesta',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ],
            ),
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
      case 'pending':
        color = Colors.orange;
        bgColor = Colors.orange.withOpacity(0.1);
        label = 'Pendiente';
        break;
      case 'accepted':
        color = AppTheme.primary;
        bgColor = AppTheme.primarySoft;
        label = 'Aceptada';
        break;
      case 'rejected':
        color = AppTheme.error;
        bgColor = AppTheme.error.withOpacity(0.1);
        label = 'Rechazada';
        break;
      default:
        color = AppTheme.textTertiary;
        bgColor = AppTheme.divider;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
