import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../entities/proposal_with_provider.dart';
import '../repo/proposal_repository.dart';

class GetProposalsByServiceUseCase {
  final ProposalRepository _repository;

  GetProposalsByServiceUseCase(this._repository);

  Future<Either<Failure, List<ProposalWithProvider>>> execute({
    required String serviceId,
    required String clientId,
  }) {
    return _repository.getProposalsByServiceId(
      serviceId: serviceId,
      clientId: clientId,
    );
  }
}
