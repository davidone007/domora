import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../repo/proposal_repository.dart';

class CheckUserProposalUseCase {
  final ProposalRepository repository;

  CheckUserProposalUseCase(this.repository);

  Future<Either<Failure, bool>> execute(String serviceId, String providerId) {
    return repository.hasUserProposed(serviceId, providerId);
  }
}
