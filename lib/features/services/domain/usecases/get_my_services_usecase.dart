import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../entities/service.dart';
import '../repo/service_repository.dart';

class GetMyServicesUseCase {
  final ServiceRepository repository;

  GetMyServicesUseCase(this.repository);

  Future<Either<Failure, List<Service>>> execute(String userId) {
    return repository.getMyServices(userId);
  }
}
