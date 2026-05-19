import 'package:dartz/dartz.dart';
import 'package:domora/core/error/error_context.dart';
import 'package:domora/core/error/failure_mapper.dart';
import 'package:domora/core/error/failures.dart';
import '../../domain/entities/cleaning_service_request.dart';
import '../../domain/entities/service.dart';
import '../../domain/entities/service_detail.dart';
import '../../domain/repo/service_repository.dart';
import '../models/publish_service_request_model.dart';
import '../sources/service_remote_data_source.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceRemoteDataSource _remoteDataSource;
  final FailureMapper _errorMapper;

  ServiceRepositoryImpl(this._remoteDataSource, this._errorMapper);

  @override
  Future<Either<Failure, List<Service>>> getMyServices(String userId) async {
    try {
      final services = await _remoteDataSource.getMyServices(userId);
      return Right(services);
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(
          operation: 'getMyServices',
          userId: userId,
        ).toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, List<Service>>> getAllAvailableServices() async {
    try {
      final services = await _remoteDataSource.getAllAvailableServices();
      return Right(services);
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(
          operation: 'getAllAvailableServices',
        ).toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, ServiceDetail>> getServiceById(String id) async {
    try {
      final detail = await _remoteDataSource.getServiceById(id);
      return Right(detail);
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(
          operation: 'getServiceById',
          userId: id,
        ).toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> publishCleaningService(
      CleaningServiceRequest request) async {
    try {
      final model = PublishServiceRequestModel.fromEntity(request);
      final serviceId = await _remoteDataSource.publishCleaningService(model);
      
      if (request.images.isNotEmpty) {
        await _remoteDataSource.uploadServiceImages(
          serviceId: serviceId,
          images: request.images,
          primaryIndex: request.primaryImageIndex,
        );
      }
      
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
