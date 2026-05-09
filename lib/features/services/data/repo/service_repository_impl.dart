import 'package:dartz/dartz.dart';
import 'package:domora/core/error/error_context.dart';
import 'package:domora/core/error/failure_mapper.dart';
import 'package:domora/core/error/failures.dart';
import '../../domain/entities/cleaning_service_request.dart';
import '../../domain/repo/service_repository.dart';
import '../sources/service_remote_data_source.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceRemoteDataSource _remoteDataSource;
  final FailureMapper _errorMapper;

  ServiceRepositoryImpl(this._remoteDataSource, this._errorMapper);

  @override
  Future<Either<Failure, Unit>> publishCleaningService(
      CleaningServiceRequest request) async {
    try {
      await _remoteDataSource.publishCleaningService(request);
      return const Right(unit);
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(
          operation: 'publishCleaningService',
          userId: request.clientId,
        ).toString(),
      ));
    }
  }
}
