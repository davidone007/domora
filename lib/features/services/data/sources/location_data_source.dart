import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/device_position.dart';
import '../../domain/entities/service_address.dart';

/// Excepción lanzada cuando el permiso de ubicación está denegado.
class LocationPermissionDeniedException implements Exception {
  final bool permanentlyDenied;
  const LocationPermissionDeniedException({this.permanentlyDenied = false});
}

/// Excepción lanzada cuando el servicio de GPS está desactivado.
class LocationServiceDisabledException implements Exception {
  const LocationServiceDisabledException();
}

abstract class LocationDataSource {
  Future<DevicePosition> getCurrentPosition();
  Future<ServiceAddress> reverseGeocode(DevicePosition position);
}

class LocationDataSourceImpl implements LocationDataSource {
  final http.Client _httpClient;

  LocationDataSourceImpl(this._httpClient);

  @override
  Future<DevicePosition> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceDisabledException();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationPermissionDeniedException(permanentlyDenied: false);
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationPermissionDeniedException(permanentlyDenied: true);
    }

    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );

    return DevicePosition(latitude: pos.latitude, longitude: pos.longitude);
  }

  @override
  Future<ServiceAddress> reverseGeocode(DevicePosition position) async {
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
      '?lat=${position.latitude}&lon=${position.longitude}&format=json&accept-language=es',
    );

    final response = await _httpClient.get(uri, headers: {
      'User-Agent': 'Domora/1.0',
      'Accept': 'application/json',
    });

    if (response.statusCode != 200) {
      throw Exception('Geocoding error: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final addr = json['address'] as Map<String, dynamic>? ?? {};

    final road = addr['road'] as String? ?? '';
    final houseNumber = addr['house_number'] as String? ?? '';
    final addressLine1 = [road, houseNumber]
        .where((s) => s.isNotEmpty)
        .join(' # ');

    final city = (addr['city'] ??
            addr['town'] ??
            addr['municipality'] ??
            addr['county'] ??
            '') as String;

    final neighborhood = (addr['neighbourhood'] ??
            addr['suburb'] ??
            addr['quarter'] ??
            '') as String;

    return ServiceAddress(
      addressLine1: addressLine1.isEmpty ? 'Dirección desconocida' : addressLine1,
      city: city.isEmpty ? 'Ciudad desconocida' : city,
      neighborhood: neighborhood.isEmpty ? null : neighborhood,
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}
