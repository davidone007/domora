import 'package:dartz/dartz.dart';
import 'package:domora/core/error/error_context.dart';
import 'package:domora/core/error/failure_mapper.dart';
import 'package:domora/core/error/failures.dart';
import '../../domain/entities/proposal.dart';
import '../../domain/repo/proposal_repository.dart';
import '../models/proposal_model.dart';
import '../sources/proposal_remote_data_source.dart';

class ProposalRepositoryImpl implements ProposalRepository {
  final ProposalRemoteDataSource _remoteDataSource;
  final FailureMapper _errorMapper;

  ProposalRepositoryImpl(this._remoteDataSource, this._errorMapper);

  @override
  Future<Either<Failure, Unit>> sendProposal(Proposal proposal) async {
    try {
      final model = ProposalModel.fromEntity(proposal);
      await _remoteDataSource.sendProposal(model);
      return const Right(unit);
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(
          operation: 'sendProposal',
          userId: proposal.providerId,
        ).toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> hasUserProposed(String serviceId, String providerId) async {
    try {
      final exists = await _remoteDataSource.hasUserProposed(serviceId, providerId);
      return Right(exists);
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(
          operation: 'hasUserProposed',
          userId: providerId,
        ).toString(),
      ));
    }
  }
}
