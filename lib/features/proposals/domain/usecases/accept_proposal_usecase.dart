import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../entities/proposal.dart';
import '../repo/proposal_repository.dart';

class AcceptProposalUseCase {
  final ProposalRepository _repository;

  AcceptProposalUseCase(this._repository);

  Future<Either<Failure, Unit>> execute(Proposal proposal) {
    return _repository.acceptProposal(proposal);
  }
}
