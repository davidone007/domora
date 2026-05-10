import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../entities/service_detail.dart';
import '../repo/service_repository.dart';

class GetServiceDetailUseCase {
  final ServiceRepository repository;

  GetServiceDetailUseCase(this.repository);

  Future<Either<Failure, ServiceDetail>> execute(String id) {
    return repository.getServiceById(id);
  }
}
