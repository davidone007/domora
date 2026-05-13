import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../entities/service.dart';
import '../repo/service_repository.dart';

class GetAllServicesUseCase {
  final ServiceRepository _repository;

  GetAllServicesUseCase(this._repository);

  Future<Either<Failure, List<Service>>> execute() {
    return _repository.getAllAvailableServices();
  }
}
