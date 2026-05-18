import 'package:equatable/equatable.dart';

/// Posición geográfica obtenida del dispositivo.
class DevicePosition extends Equatable {
  final double latitude;
  final double longitude;

  const DevicePosition({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}
