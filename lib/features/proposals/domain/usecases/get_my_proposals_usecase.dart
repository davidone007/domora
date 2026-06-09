import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../entities/proposal_with_service.dart';
import '../repo/proposal_repository.dart';

class GetMyProposalsUseCase {
  final ProposalRepository _repository;

  GetMyProposalsUseCase(this._repository);

  Future<Either<Failure, List<ProposalWithService>>> execute(String providerId) {
    return _repository.getMyProposalsWithServices(providerId);
  }
}
