import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../entities/proposal.dart';
import '../repo/proposal_repository.dart';

class SendProposalUseCase {
  final ProposalRepository repository;

  SendProposalUseCase(this.repository);

  Future<Either<Failure, Unit>> execute(Proposal proposal) {
    return repository.sendProposal(proposal);
  }
}
