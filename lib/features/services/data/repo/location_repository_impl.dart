import 'package:dartz/dartz.dart';
import 'package:domora/core/error/error_context.dart';
import 'package:domora/core/error/failure_mapper.dart';
import 'package:domora/core/error/failures.dart';
import '../../domain/entities/device_position.dart';
import '../../domain/entities/service_address.dart';
import '../../domain/repo/location_repository.dart';
import '../sources/location_data_source.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationDataSource _dataSource;
  final FailureMapper _errorMapper;

  LocationRepositoryImpl(this._dataSource, this._errorMapper);

  @override
  Future<Either<Failure, DevicePosition>> getCurrentPosition() async {
    try {
      final position = await _dataSource.getCurrentPosition();
      return Right(position);
    } on LocationPermissionDeniedException catch (e) {
      return Left(PermissionFailure(
        message: e.permanentlyDenied
            ? 'Permiso de ubicación denegado permanentemente. Habilítalo en la configuración del dispositivo.'
            : 'Se necesita permiso de ubicación para usar esta función.',
        permissionType: PermissionType.location,
        permanentlyDenied: e.permanentlyDenied,
      ));
    } on LocationServiceDisabledException {
      return const Left(ServerFailure(
        'El servicio de ubicación está desactivado. Actívalo en la configuración del dispositivo.',
      ));
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(operation: 'getCurrentPosition').toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, ServiceAddress>> reverseGeocode(DevicePosition position) async {
    try {
      final address = await _dataSource.reverseGeocode(position);
      return Right(address);
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(operation: 'reverseGeocode').toString(),
      ));
    }
  }
}
