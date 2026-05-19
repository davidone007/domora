import 'package:equatable/equatable.dart';

class GeoCoordinates extends Equatable {
  final double latitude;
  final double longitude;

  const GeoCoordinates({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}
