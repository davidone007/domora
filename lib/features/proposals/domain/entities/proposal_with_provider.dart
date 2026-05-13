import 'package:equatable/equatable.dart';
import 'proposal.dart';

/// Entidad que combina una propuesta con la información del proveedor que la envió.
class ProposalWithProvider extends Equatable {
  final Proposal proposal;
  final String providerFirstName;
  final String providerLastName;
  final String? providerAvatarUrl;
  final double? providerRating; // Futuro: Calificación promedio
  final int? providerExperienceYears;

  const ProposalWithProvider({
    required this.proposal,
    required this.providerFirstName,
    required this.providerLastName,
    this.providerAvatarUrl,
    this.providerRating,
    this.providerExperienceYears,
  });

  String get providerFullName => '$providerFirstName $providerLastName';

  @override
  List<Object?> get props => [
        proposal,
        providerFirstName,
        providerLastName,
        providerAvatarUrl,
        providerRating,
        providerExperienceYears,
      ];
}
