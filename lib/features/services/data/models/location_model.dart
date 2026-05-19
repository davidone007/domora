/// Raw coordinates returned by the platform location API.
/// This is a data-layer model — it must NOT depend on any domain entity.
class LocationModel {
  final double latitude;
  final double longitude;

  const LocationModel({
    required this.latitude,
    required this.longitude,
  });
}
