import 'package:geolocator/geolocator.dart';
import 'package:domora/core/error/failures.dart';
import '../../domain/entities/geo_coordinates.dart';

abstract class LocationDataSource {
  Future<GeoCoordinates> getCurrentCoordinates();
}

class LocationDataSourceImpl implements LocationDataSource {
  @override
  Future<GeoCoordinates> getCurrentCoordinates() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw PermissionFailure(
        message: 'Activa los servicios de ubicacion para continuar',
        permissionType: PermissionType.location,
        permanentlyDenied: false,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw _locationPermissionFailure();
    }

    if (permission == LocationPermission.deniedForever) {
      throw _locationPermissionFailure(permanentlyDenied: true);
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return GeoCoordinates(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  PermissionFailure _locationPermissionFailure({bool permanentlyDenied = false}) {
    return PermissionFailure(
      message: permanentlyDenied
          ? 'Necesitamos acceso a tu ubicacion. Ve a Configuracion para otorgar el permiso'
          : 'Necesitamos acceso a tu ubicacion. Acepta el permiso cuando se te solicite',
      permissionType: PermissionType.location,
      permanentlyDenied: permanentlyDenied,
    );
  }
}
